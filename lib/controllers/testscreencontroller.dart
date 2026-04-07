import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gold_app/Model/exammodel.dart' show Data, exammodel;
import 'package:gold_app/appurl/adminurl.dart';
import 'package:gold_app/infrastructure/routes/admin_routes.dart';
import 'package:gold_app/localstorage.dart';
import 'package:gold_app/oflinerepo/questionhivemodel.dart';
import 'package:gold_app/prefconst.dart';
import 'package:gold_app/screens/submitscreenview%20copy.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as Https;
import 'package:connectivity_plus/connectivity_plus.dart';

class Testscreencontroller extends GetxController {
  bool _isSubmittingTest = false;
  bool _isAutoSubmitTriggered = false;
  final RxDouble submitProgressPercent = 0.0.obs;
  final RxInt submitUploadedCount = 0.obs;
  final RxInt submitTotalToUpload = 0.obs;

  String _subjectQuestionKey(String subject, int questionId) =>
      '${subject}__$questionId';

  final RxMap<String, String> selectedNumericRangeAnswers =
      <String, String>{}.obs;

  String getNumericRangeAnswer(int questionId, {String? subject}) {
    final key = _subjectQuestionKey(
      subject ?? selectedSubject.value,
      questionId,
    );
    return selectedNumericRangeAnswers[key] ?? '';
  }

  bool hasNumericRangeAnswer(int questionId, {String? subject}) {
    return getNumericRangeAnswer(
      questionId,
      subject: subject,
    ).trim().isNotEmpty;
  }

  bool _hasAnyInMemoryAnswer(int questionId) {
    final hasOption = (selectedAnswers[questionId] ?? <String>{}).isNotEmpty;
    final hasInteger = selectedIntegerAnswers.containsKey(questionId);
    final hasNumeric = selectedNumericRangeAnswers.entries.any(
      (e) =>
          e.key.endsWith('__${questionId.toString()}') &&
          e.value.trim().isNotEmpty,
    );
    return hasOption || hasInteger || hasNumeric;
  }

  String _resolveAnswerFromMemory(int questionId, String subject) {
    final optionAnswer = selectedAnswers[questionId];
    if (optionAnswer != null && optionAnswer.isNotEmpty) {
      return optionAnswer.join(',');
    }

    final integerAnswer = selectedIntegerAnswers[questionId];
    if (integerAnswer != null) {
      return integerAnswer.toString();
    }

    final numericKey = _subjectQuestionKey(subject, questionId);
    final numericAnswer = selectedNumericRangeAnswers[numericKey];
    if (numericAnswer != null && numericAnswer.trim().isNotEmpty) {
      return numericAnswer.trim();
    }

    return '';
  }

  String _normalizeNumericForApi(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(value);
    if (match == null) return '';
    final token = match.group(0) ?? '';
    final parsed = double.tryParse(token);
    if (parsed == null) return token;
    if (parsed == parsed.roundToDouble()) {
      return parsed.round().toString();
    }
    return parsed.toString();
  }

  bool _isNumericRangeType(String questionTypeRaw) {
    final questionType = questionTypeRaw.toLowerCase();
    return questionType.contains('numeric range') ||
        questionType.contains('numerical') ||
        questionType.contains('numeric');
  }

  bool _numericEqualsForStatus(String studentRaw, String correctRaw) {
    final studentVal = double.tryParse(_normalizeNumericForApi(studentRaw));
    if (studentVal == null) return false;

    // Treat hyphen between digits as a range separator (9-10 => 9 and 10),
    // not as a negative sign for the second value.
    final sanitizedCorrect = correctRaw.replaceAll(
      RegExp(r'(?<=\d)-(?=\d)'),
      ' ',
    );

    final tokens = RegExp(r'-?\d+(?:\.\d+)?')
        .allMatches(sanitizedCorrect)
        .map((m) => double.tryParse(m.group(0) ?? ''))
        .whereType<double>()
        .toList();

    final looksLikeRange =
        correctRaw.contains('-') ||
        RegExp(r'\bto\b', caseSensitive: false).hasMatch(correctRaw);

    if (looksLikeRange && tokens.length >= 2) {
      final low = min(tokens[0], tokens[1]);
      final high = max(tokens[0], tokens[1]);
      return studentVal >= low && studentVal <= high;
    }

    final exactCorrectVal = double.tryParse(
      _normalizeNumericForApi(correctRaw),
    );
    if (exactCorrectVal != null) {
      return studentVal == exactCorrectVal;
    }

    if (tokens.length >= 2) {
      final low = min(tokens[0], tokens[1]);
      final high = max(tokens[0], tokens[1]);
      return studentVal >= low && studentVal <= high;
    }

    if (tokens.length == 1) {
      return studentVal == tokens.first;
    }

    return false;
  }

  /// Returns a map with counts for all question statuses across the entire paper
  /// Clears the selected answer for the current question
  void clearSelectedOption(int questionId) {
    selectedAnswers.remove(questionId);
    _committedSelectedAnswers.remove(questionId);
    _dirtyOptionQuestions.remove(questionId);
    selectedAnswers.refresh();
    final numericKey = _subjectQuestionKey(selectedSubject.value, questionId);
    selectedNumericRangeAnswers.remove(numericKey);
    _committedNumericRangeAnswers.remove(numericKey);
    _dirtyNumericRangeQuestions.remove(numericKey);
    selectedNumericRangeAnswers.refresh();
    // Optionally, clear integer answer as well
    selectedIntegerAnswers.remove(questionId);
    _committedIntegerAnswers.remove(questionId);
    _dirtyIntegerQuestions.remove(questionId);
    selectedIntegerAnswers.refresh();
    // Also clear text controller for numeric answers
    controllerText.clear();

    // Keep clear action for API sync as Not Attempted.
    _forceNotAttemptedSyncQuestions.add(questionId);
    unawaited(_deleteAnswerOffline(questionId));
  }

  /// All unique question types for the selected subject
  final questionTypes = <String>[].obs;
  final selectedQuestionType = ''.obs;

  /// Sets the numeric answer for a question with the given [questionId].
  /// [value] is the user's input as a string.
  void setNumericAnswer(int questionId, String value) {
    final key = _subjectQuestionKey(selectedSubject.value, questionId);
    String cleaned = value.trim();
    // Extract first valid number (with optional decimal)
    final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(cleaned);
    String valid = '';
    if (match != null) {
      valid = match.group(0) ?? '';
      // Limit to 3 decimal places if present
      if (valid.contains('.')) {
        final parts = valid.split('.');
        final decimals = parts[1].substring(
          0,
          parts[1].length > 3 ? 3 : parts[1].length,
        );
        valid = parts[0] + '.' + decimals;
      }
    }
    if (valid.isEmpty) {
      selectedNumericRangeAnswers.remove(key);
    } else {
      _forceNotAttemptedSyncQuestions.remove(questionId);
      selectedNumericRangeAnswers[key] = valid;
      // Mark as visited when numeric answer entered
      visitedQuestions.add(questionId);
      visitedQuestions.refresh();
      // If this is the last question in the current type, mark as visited
      final curType = selectedQuestionType.value;
      final curQuestions =
          allQuestions[selectedSubject.value]
              ?.where((q) => (q['questionType'] ?? '') == curType)
              .toList() ??
          [];
      if (curQuestions.isNotEmpty && curQuestions.last['id'] == questionId) {
        visitedQuestions.add(questionId);
        visitedQuestions.refresh();
      }
    }
    _dirtyNumericRangeQuestions.add(key);
    selectedNumericRangeAnswers.refresh();
  }

  // ------------ QUESTION TIME TRACKING ------------
  /// Stores the total time spent (in seconds) for each question
  final questionTimes = <int, int>{}.obs;

  /// Stores the timestamp when the current question was shown
  DateTime? _questionStartTime;
  // ------------ SUBJECT / QUESTIONS ------------
  final subjects = <String>[].obs;
  final selectedSubject = ''.obs;

  var schoolId = ''.obs;
  var courseId = ''.obs;
  var testId = ''.obs;
  var studentid = ''.obs;
  var examtestid = ''.obs;
  var studentidd = ''.obs;
  var passcode = ''.obs;
  var batchid = ''.obs;
  var batchiid = ''.obs;

  // ------------ TIMER ------------
  RxInt viewsecond = 0.obs; // total minutes from API
  RxInt totalSeconds = 0.obs; // total seconds
  RxInt remainingSeconds = 0.obs; // remaining seconds
  RxBool isTimerRunning = false.obs;
  final RxDouble fontScale = 1.0.obs;

  Timer? quizTimer;
  final RxBool timerStarted = false.obs;

  void increaseFont() {
    fontScale.value = (fontScale.value + 0.05).clamp(0.85, 2.0);
  }

  void decreaseFont() {
    fontScale.value = (fontScale.value - 0.05).clamp(0.25, 2.0);
  }

  // ------------ QUESTION STATE ------------
  final currentIndex = 0.obs;
  final questionTestId = ''.obs;
  // Numeric answer controller for the current question
  TextEditingController controllerText = TextEditingController();

  /// Call this when the question changes to reset the numeric answer controller
  void resetNumericController() {
    controllerText.dispose();
    controllerText = TextEditingController();
    // Optionally, prefill with existing answer if present
    final currentQuestionsList = currentQuestions;
    if (currentQuestionsList.isNotEmpty) {
      final qId = currentQuestionsList[currentIndex.value]['id'] as int;
      final answer = getNumericRangeAnswer(qId);
      controllerText.text = answer;
    }
  }

  /// Stores selected option keys (e.g., "A", "B", "C", "D") for each question (multiple choice)
  final selectedAnswers = <int, Set<String>>{}.obs;
  final Map<int, Set<String>> _committedSelectedAnswers = <int, Set<String>>{};
  final Set<int> _dirtyOptionQuestions = <int>{};
  final Map<int, int> _committedIntegerAnswers = <int, int>{};
  final Set<int> _dirtyIntegerQuestions = <int>{};
  final Map<String, String> _committedNumericRangeAnswers = <String, String>{};
  final Set<String> _dirtyNumericRangeQuestions = <String>{};
  final Set<int> _forceNotAttemptedSyncQuestions = <int>{};

  Set<String> _cloneSet(Set<String> source) => Set<String>.from(source);

  Future<void> _commitOptionSelection(int questionId) async {
    final current = selectedAnswers[questionId] ?? <String>{};
    if (current.isEmpty) {
      _committedSelectedAnswers.remove(questionId);
      selectedAnswers.remove(questionId);
      try {
        await _deleteAnswerOffline(questionId);
      } catch (e) {
        print("❌ Failed to clear offline answer for Q:$questionId: $e");
      }
    } else {
      _forceNotAttemptedSyncQuestions.remove(questionId);
      final copy = _cloneSet(current);
      _committedSelectedAnswers[questionId] = copy;
      selectedAnswers[questionId] = copy;
      try {
        await _saveAnswerOffline(questionId, copy.join(','));
      } catch (e) {
        print(
          "❌ Failed to save committed answer offline for Q:$questionId: $e",
        );
      }
    }
    _dirtyOptionQuestions.remove(questionId);
    selectedAnswers.refresh();
  }

  Future<void> _commitIntegerSelection(int questionId) async {
    final current = selectedIntegerAnswers[questionId];
    if (current == null) {
      _committedIntegerAnswers.remove(questionId);
      selectedIntegerAnswers.remove(questionId);
      try {
        await _deleteAnswerOffline(questionId);
      } catch (e) {
        print("❌ Failed to clear offline integer answer for Q:$questionId: $e");
      }
    } else {
      _forceNotAttemptedSyncQuestions.remove(questionId);
      _committedIntegerAnswers[questionId] = current;
      selectedIntegerAnswers[questionId] = current;
      try {
        await _saveAnswerOffline(questionId, current.toString());
      } catch (e) {
        print("❌ Failed to save integer answer offline for Q:$questionId: $e");
      }
    }
    _dirtyIntegerQuestions.remove(questionId);
    selectedIntegerAnswers.refresh();
  }

  Future<void> _commitNumericRangeSelection(
    int questionId, {
    required String subject,
  }) async {
    final key = _subjectQuestionKey(subject, questionId);
    final current = (selectedNumericRangeAnswers[key] ?? '').trim();
    if (current.isEmpty) {
      _committedNumericRangeAnswers.remove(key);
      selectedNumericRangeAnswers.remove(key);
      try {
        await _deleteAnswerOffline(questionId);
      } catch (e) {
        print("❌ Failed to clear offline numeric answer for Q:$questionId: $e");
      }
    } else {
      _forceNotAttemptedSyncQuestions.remove(questionId);
      final normalized = _normalizeNumericForApi(current);
      _committedNumericRangeAnswers[key] = normalized;
      selectedNumericRangeAnswers[key] = normalized;
      try {
        await _saveAnswerOffline(questionId, normalized);
      } catch (e) {
        print("❌ Failed to save numeric answer offline for Q:$questionId: $e");
      }
    }
    _dirtyNumericRangeQuestions.remove(key);
    selectedNumericRangeAnswers.refresh();
  }

  Future<void> _commitCurrentAnswer({
    required int questionId,
    required String questionType,
    required String subject,
  }) async {
    await _commitOptionSelection(questionId);
    if (questionType.contains('integer type')) {
      await _commitIntegerSelection(questionId);
    }
    if (_isNumericRangeType(questionType)) {
      await _commitNumericRangeSelection(questionId, subject: subject);
    }
  }

  void discardUnsavedSelectionForCurrentQuestion() {
    final qList = currentQuestions;
    if (qList.isEmpty || currentIndex.value >= qList.length) return;
    final questionId = qList[currentIndex.value]['id'] as int;
    discardUnsavedSelectionForQuestion(questionId);
  }

  void discardUnsavedSelectionForQuestion(int questionId) {
    if (_dirtyOptionQuestions.contains(questionId)) {
      final committed = _committedSelectedAnswers[questionId];
      if (committed == null || committed.isEmpty) {
        selectedAnswers.remove(questionId);
      } else {
        selectedAnswers[questionId] = _cloneSet(committed);
      }
      _dirtyOptionQuestions.remove(questionId);
      selectedAnswers.refresh();
    }

    if (_dirtyIntegerQuestions.contains(questionId)) {
      final committedInteger = _committedIntegerAnswers[questionId];
      if (committedInteger == null) {
        selectedIntegerAnswers.remove(questionId);
      } else {
        selectedIntegerAnswers[questionId] = committedInteger;
      }
      _dirtyIntegerQuestions.remove(questionId);
      selectedIntegerAnswers.refresh();
    }

    final numericKey = _subjectQuestionKey(selectedSubject.value, questionId);
    if (_dirtyNumericRangeQuestions.contains(numericKey)) {
      final committedNumeric = _committedNumericRangeAnswers[numericKey];
      if (committedNumeric == null || committedNumeric.isEmpty) {
        selectedNumericRangeAnswers.remove(numericKey);
      } else {
        selectedNumericRangeAnswers[numericKey] = committedNumeric;
      }
      _dirtyNumericRangeQuestions.remove(numericKey);
      selectedNumericRangeAnswers.refresh();
    }
  }

  final markedForReview = <int>{}.obs;
  final visitedQuestions = <int>{}.obs;

  /// subject → list of questions
  final allQuestions = <String, List<Map<String, dynamic>>>{}.obs;

  // ===================================================
  // INIT
  // ===================================================
  void _onQuestionChanged() {
    final list = currentQuestions;
    if (list.isEmpty) return;

    final qId = list[currentIndex.value]['id'] as int;
    _startQuestionTimer(qId);
    resetNumericController();
  }

  void _startQuestionTimer(int questionId) {
    _saveCurrentQuestionTime();
    _questionStartTime = DateTime.now();
  }

  void _saveCurrentQuestionTime() {
    if (_questionStartTime == null) return;
    final currentQuestionsList = currentQuestions;
    if (currentQuestionsList.isEmpty) return;
    final qId = currentQuestionsList[currentIndex.value]['id'] as int;
    final now = DateTime.now();
    final seconds = now.difference(_questionStartTime!).inSeconds;
    questionTimes[qId] = (questionTimes[qId] ?? 0) + seconds;
    questionTimes.refresh();
    _questionStartTime = null;
  }

  @override
  void onInit() async {
    super.onInit();

    // Set landscape orientation for test screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    questionTestId.value = generateQuestionTestId();

    // Start timing the first question when questions are loaded
    ever(currentIndex, (_) => _onQuestionChanged());
    ever(selectedSubject, (_) {
      _updateQuestionTypes();
      currentIndex.value = 0;
      resetNumericController();
    });
    ever(selectedQuestionType, (_) {
      currentIndex.value = 0;
      resetNumericController();
    });

    schoolId.value =
        await PrefManager().readValue(key: PrefConst.SchoolId) ?? '';
    studentid.value =
        await PrefManager().readValue(key: PrefConst.CourseId) ?? '';
    studentidd.value =
        await PrefManager().readValue(key: PrefConst.StudentId) ?? '';
    batchiid.value =
        await PrefManager().readValue(key: PrefConst.batchiid) ?? '';

    // BatchId.value    = await PrefManager().readValue(key: PrefConst.CourseId) ?? '';
    testId.value = Get.arguments['testId'] ?? '';
    passcode.value = Get.arguments['passcode'] ?? '';

    // ✅🔥 NOW DELETE THE CORRUPTED BOX (AFTER testId EXISTS)
    try {
      await Hive.deleteBoxFromDisk('offlineexam${testId.value}');
      await Hive.deleteBoxFromDisk('offline_answers_${testId.value}');
      print("✅ Corrupted Hive boxes wiped");
    } catch (e) {
      print("⚠️ Hive cleanup skipped: $e");
    }

    await _loadQuestions();
    await _loadFromOffline();

    if (allQuestions.isNotEmpty) {
      final firstSubjectList = allQuestions.values.first;
      if (firstSubjectList.isNotEmpty) {
        // Force fixed exam duration: 180 minutes.
        viewsecond.value = 180;
        startTimer(viewsecond.value);
      }
    }

    monitorConnectivity();
  }

  bool hasValidImage(dynamic path) {
    if (path == null) return false;
    final p = path.toString().trim();
    if (p.isEmpty) return false;

    // If the backend sends "NO" marker, block it
    final lower = p.toLowerCase();
    if (lower.contains('upload/examtest/no')) return false;
    if (lower.endsWith('/no')) return false;

    return true;
  }

  String imgUrl(String path) => 'https://student.maharishiglobal.org/$path';

  /// Stores selected integer answer for each question (for Integer Type questions)

  final RxMap<int, int> selectedIntegerAnswers = <int, int>{}.obs;

  /// Set the selected integer answer for a question
  void setIntegerAnswer(int questionId, int value) {
    _forceNotAttemptedSyncQuestions.remove(questionId);
    selectedIntegerAnswers[questionId] = value;
    _dirtyIntegerQuestions.add(questionId);
    selectedIntegerAnswers.refresh();
    // Mark as visited when integer answer entered
    visitedQuestions.add(questionId);
    visitedQuestions.refresh();
    // If this is the last question in the current type, mark as visited
    final curType = selectedQuestionType.value;
    final curQuestions =
        allQuestions[selectedSubject.value]
            ?.where((q) => (q['questionType'] ?? '') == curType)
            .toList() ??
        [];
    if (curQuestions.isNotEmpty && curQuestions.last['id'] == questionId) {
      visitedQuestions.add(questionId);
      visitedQuestions.refresh();
    }
  }

  Future<void> submitFeedback({
    required answer1,
    required answer2,
    required answer3,
  }) async {
    try {
      final url = Uri.parse("${Adminurl.baseurl}/MobApp/AppFeedback");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "StudentId": studentidd.value,
          "CourseId": studentid.value,
          "ExamTestId": examtestid.value,
          "BatchId": batchid.value,

          "Question1Ans": answer1.toString(),
          "Question2Ans": answer2.toString(),
          "Question3Ans": answer3.toString(),
          "SchoolId": schoolId.value,
          "CreateBy": studentid.value,
          "FeedBackType": "ExamTest",
        }),
      );
      print(jsonEncode);

      if (response.statusCode == 200) {
        print("✅ Feedback submitted successfully");
        Get.offAllNamed(AdminRoutes.LOADING_SCREEN);
        print(response.body);
        Get.snackbar(
          "Success",
          "Feedback submitted",
          backgroundColor: Color(0xFF8b2d28),
          colorText: Colors.white,
        );
      } else {
        print("❌ Server error: ${response.statusCode}");
        print(response.body);
        Get.snackbar(
          "Error",
          "Failed to submit feedback",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("❌ Exception while submitting feedback: $e");
      Get.snackbar(
        "Error",
        "Something went wrong",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ===================================================
  // TIMER
  // ===================================================

  String get formattedTime {
    final s = remainingSeconds.value;
    final h = (s ~/ 3600).toString().padLeft(2, '0');
    final m = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return "$h:$m:$sec";
  }

  void startTimer(int minutes) {
    if (minutes <= 0) {
      print("⛔ startTimer called with minutes <= 0");
      return;
    }

    totalSeconds.value = minutes * 60;
    remainingSeconds.value = minutes * 60;
    isTimerRunning.value = true;

    quizTimer?.cancel(); // in case it was already running

    quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
        isTimerRunning.value = false;
        autoSubmit();
      }
    });

    print(
      "⏱ Timer started for $minutes minutes (${totalSeconds.value} seconds)",
    );
  }

  void autoSubmit() {
    if (_isAutoSubmitTriggered) return;
    _isAutoSubmitTriggered = true;

    // AUTO SUBMIT WHEN TIME FINISHES
    if (Get.context != null) {
      AwesomeDialog(
        context: Get.context!,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: "Time's Up!",
        desc:
            "Your exam time has ended. Your answers are being submitted automatically.",
        autoHide: const Duration(seconds: 3),
      ).show();

      Future.delayed(const Duration(seconds: 3), () {
        submitTest(Get.context);
      });
    } else {
      submitTest(Get.context);
    }
  }

  Future<void> _loadQuestions() async {
    final url =
        '${Adminurl.testurl}/${schoolId.value}/${studentid.value}/${testId.value}/${passcode.value}/${studentidd.value}/${batchiid.value}';
    print("🔗 Fetching questions from: $url");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'MobAppQuestionKey': 'bdui93Y-HLwxe8-11fehc-AyuK63-96yjc736'},
      );

      if (response.statusCode != 200) {
        print(response.body);
        Get.snackbar("Error", "Server error: ${response.statusCode}");
        return;
      }

      // ✅ IMPORTANT: force UTF-8 decoding (fixes ², √, π etc.)
      final body = utf8.decode(response.bodyBytes);
      print(body);

      final parsed = exammodel.fromJson(jsonDecode(body));

      if (parsed.data != null && parsed.data!.isNotEmpty) {
        final answerCount = parsed.data!.first.answerCount ?? 0;
        if (answerCount == 1) {
          Get.snackbar(
            "Already Attempted",
            "You already attempted this test.",
            backgroundColor: const Color(0xFF8B2D28),
            colorText: Colors.white,
          );
          return;
        }
      }

      await _saveToOffline(parsed.data!);
      print("Questions saved to offline Hive!");
    } catch (e) {
      print("❌ Error during API fetch. Falling back to offline... $e");
      return _loadFromOffline();
    }
  }

  // ===================================================
  // SAVE QUESTIONS TO OFFLINE HIVE
  // ===================================================
  Future<void> _saveToOffline(List<Data> questions) async {
    var box = await Hive.openBox('offlineexam${testId.value}');
    await box.clear(); // Clear existing data

    for (var q in questions) {
      // Robustly map all possible image fields
      final img = q.questionsimg ?? "";
      await box.add(
        hivequestion()
          ..questionId = q.questionId
          ..subjectName = q.subjectName
          ..testId = q.testId
          ..questions = q.questions
          ..questionsimg = img
          ..ansOptionA = q.ansOptionA
          ..ansOptionAimg = q.ansOptionAimg
          ..ansOptionB = q.ansOptionB
          ..ansOptionBimg = q.ansOptionBimg
          ..ansOptionC = q.ansOptionC
          ..ansOptionCimg = q.ansOptionCimg
          ..ansOptionD = q.ansOptionD
          ..ansOptionDimg = q.ansOptionDimg
          ..optionCorrect = q.optionCorrect
          ..correctOptionText = q.correctOptionText
          ..questionRating = q.questionRating
          ..questionMarks = q.questionMarks
          ..totalMinutes = q.totalMinutes
          ..batchId = q.batchId
          ..examTestId = q.examTestId
          ..negativeMarking = q.negativeMarking
          ..questionType = q.questionType
          ..integerTypeCorrecrt = q.integerTypeCorrecrt
          ..numericRangeCorrectAns = q.numericRangeCorrectAns
          ..optionCorrectA = q.optionCorrectA
          ..optionCorrectB = q.optionCorrectB
          ..optionCorrectC = q.optionCorrectC
          ..optionCorrectD = q.optionCorrectD
          ..correctOptionTextA = q.correctOptionTextA
          ..correctOptionTextB = q.correctOptionTextB
          ..correctOptionTextC = q.correctOptionTextC
          ..correctOptionTextD = q.correctOptionTextD
          ..quesNegativeMarking = q.quesNegativeMarking
          ..quesNegativeMarkingMarks = q.quesNegativeMarkingMarks,
      );
    }

    print("Questions saved to offline Hive!");
  }

  // ===================================================
  // LOAD QUESTIONS FROM OFFLINE HIVE
  // ===================================================
  Future<void> _loadFromOffline() async {
    try {
      var questionBox = await Hive.openBox('offlineexam${testId.value}');

      if (questionBox.isEmpty) {
        Get.snackbar("Error", "No offline questions available");
        return;
      }

      allQuestions.clear();

      for (var q in questionBox.values) {
        final subject = q.subjectName ?? 'General';

        allQuestions.putIfAbsent(subject, () => []);

        // Store batchId before adding to map
        batchid.value = q.batchId.toString();
        examtestid.value = q.examTestId.toString();

        allQuestions[subject]!.add({
          'id': q.questionId,
          'question': q.questions ?? '',
          // Robustly map question image from any possible field
          'questionImg':
              q.questionImg ?? q.questionsimg ?? q.Questionsimg ?? '',
          'negativeMarking': (q.negativeMarking ?? 'No'),
          'questionType': q.questionType ?? '',
          'integerTypeCorrecrt': q.integerTypeCorrecrt ?? '',
          'numericRangeCorrectAns': q.numericRangeCorrectAns ?? '',
          'quesNegativeMarking': q.quesNegativeMarking ?? '',
          'quesNegativeMarkingMarks': q.quesNegativeMarkingMarks ?? 0,
          'options':
              [
                    {
                      'key': 'A',
                      'value': q.ansOptionA ?? '',
                      'img': hasValidImage(q.ansOptionAimg)
                          ? (q.ansOptionAimg ?? '')
                          : '',
                    },
                    {
                      'key': 'B',
                      'value': q.ansOptionB ?? '',
                      'img': hasValidImage(q.ansOptionBimg)
                          ? (q.ansOptionBimg ?? '')
                          : '',
                    },
                    {
                      'key': 'C',
                      'value': q.ansOptionC ?? '',
                      'img': hasValidImage(q.ansOptionCimg)
                          ? (q.ansOptionCimg ?? '')
                          : '',
                    },
                    {
                      'key': 'D',
                      'value': q.ansOptionD ?? '',
                      'img': hasValidImage(q.ansOptionDimg)
                          ? (q.ansOptionDimg ?? '')
                          : '',
                    },
                  ]
                  .where(
                    (e) =>
                        (e['value'] ?? '').toString().trim().isNotEmpty ||
                        (e['img'] ?? '').toString().trim().isNotEmpty,
                  )
                  .toList(),
          'correctOption': q.optionCorrect ?? '',
          'correctOptionTextA': q.correctOptionTextA ?? '',
          'correctOptionTextB': q.correctOptionTextB ?? '',
          'correctOptionTextC': q.correctOptionTextC ?? '',
          'correctOptionTextD': q.correctOptionTextD ?? '',
          'optionCorrectA': q.optionCorrectA ?? '',
          'optionCorrectB': q.optionCorrectB ?? '',
          'optionCorrectC': q.optionCorrectC ?? '',
          'optionCorrectD': q.optionCorrectD ?? '',
          'viewsecond': q.totalMinutes ?? 0,
          'rating': double.tryParse(q.questionRating ?? '0') ?? 0.0,
          'marks': q.questionMarks ?? 0,
          'batchId': q.batchId ?? 0,
          'examTestId': q.examTestId ?? 0,
        });
      }

      subjects.value = allQuestions.keys.toList();
      selectedSubject.value = subjects.first;

      // Set question types for the first subject
      _updateQuestionTypes();

      allQuestions.refresh();
      print("✅ Loaded questions from offline Hive.");
    } catch (e) {
      print("❌ Error loading from offline Hive: $e");
      Get.snackbar("Error", "Failed to load offline questions");
    }
  }

  /// Update the list of question types for the selected subject
  void _updateQuestionTypes() {
    final questions = allQuestions[selectedSubject.value] ?? [];
    final types = questions
        .map((q) => (q['questionType'] ?? '').toString())
        .toSet()
        .toList();
    types.removeWhere((t) => t.isEmpty);
    questionTypes.value = types;
    selectedQuestionType.value = types.isNotEmpty ? types.first : '';
  }

  String fullImgUrl(String path) => 'https://student.maharishiglobal.org/$path';

  Widget buildRatingStars(double rating, bool isDarkMode) {
    return Row(
      children: List.generate(5, (index) {
        if (index + 1 <= rating) {
          return Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (rating > index && rating < index + 1) {
          return Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return Icon(
            Icons.star_border,
            color: isDarkMode ? Colors.grey[600] : Colors.grey,
            size: 20,
          );
        }
      }),
    );
  }

  String buildImgUrl(dynamic path) {
    if (path == null) return '';
    final p = path.toString().trim();
    if (p.isEmpty) return '';

    // If already absolute URL, return it as-is
    if (p.startsWith('http://') || p.startsWith('https://')) return p;

    // Otherwise build full URL
    return 'https://student.maharishiglobal.org/$p';
  }

  void showCustomSubmitDialog(BuildContext context) {
    final TextEditingController submitController = TextEditingController();
    final isTimeOver = remainingSeconds.value <= 0;
    if (isTimeOver) {
      submitTest(context);
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade400,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Submit Test?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "To confirm submission, please type 'submit' below.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: submitController,
                  decoration: InputDecoration(
                    labelText: "Type 'submit' to confirm",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                  minLines: 1,
                  maxLines: 1,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if (submitController.text.trim().toLowerCase() !=
                            'submit') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please type 'submit' to confirm."),
                            ),
                          );
                          return;
                        }

                        submitTest(context);
                      },
                      label: const Text("Submit"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void clearQuestionWithWarning(int questionId) {
    final hasSelection = (selectedAnswers[questionId] ?? <String>{}).isNotEmpty;
    final hasInteger = selectedIntegerAnswers.containsKey(questionId);
    final hasNumeric = getNumericRangeAnswer(
      questionId,
      subject: selectedSubject.value,
    ).trim().isNotEmpty;
    final hasAnyAnswer = hasSelection || hasInteger || hasNumeric;

    if (!hasAnyAnswer) {
      clearSelectedOption(questionId);
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Clear Response?'),
        content: const Text(
          'If You Proceed,the question will be cleared and marked as unattempted. Do you want to continue?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              clearSelectedOption(questionId);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void markForReviewWithWarning() {
    final qList = currentQuestions;
    if (qList.isEmpty) return;

    final currentQ = qList[currentIndex.value];
    final int questionId = currentQ['id'] as int;
    final questionType = (currentQ['questionType'] ?? '')
        .toString()
        .toLowerCase();
    final answeredByOptions =
        (selectedAnswers[questionId] ?? <String>{}).isNotEmpty;
    final answeredByInteger = selectedIntegerAnswers.containsKey(questionId);
    final answeredByNumeric = _isNumericRangeType(questionType)
        ? hasNumericRangeAnswer(questionId, subject: selectedSubject.value)
        : false;
    final hasAnswer =
        answeredByOptions || answeredByInteger || answeredByNumeric;

    final bool isAlreadyMarked = markedForReview.contains(questionId);
    final dialogTitle = isAlreadyMarked
        ? 'Remove Mark For Review?'
        : (hasAnswer
              ? 'Save Answer & Mark For Review?'
              : 'Mark For Review Without Answer?');
    final dialogBody = isAlreadyMarked
        ? 'This question will be removed from Marked For Review.'
        : (hasAnswer
              ? 'Do you want to review the question submitting the test.'
              : 'No response is selected. The question will be marked for review without an answer.');

    Get.dialog(
      AlertDialog(
        title: Text(dialogTitle),
        content: Text(dialogBody),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _commitCurrentAnswer(
                questionId: questionId,
                questionType: questionType,
                subject: selectedSubject.value,
              );

              // Save time on current question and move forward without API submit.
              _saveCurrentQuestionTime();

              toggleMarkForReview();

              final currentQuestionsList = currentQuestions;
              if (currentQuestionsList.isNotEmpty &&
                  currentIndex.value < currentQuestionsList.length - 1) {
                currentIndex.value++;
              }

              markedForReview.refresh();
              visitedQuestions.refresh();
              update();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAlreadyMarked ? Colors.grey : Colors.purple,
            ),
            child: Text(
              isAlreadyMarked ? 'Remove' : 'Confirm',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void showSubmitWarningLikeJeeMain(BuildContext context) {
    final isTimeOver = remainingSeconds.value <= 0;
    if (isTimeOver) {
      showCustomSubmitDialog(context);
      return;
    }

    final Map<String, int> attemptedByType = <String, int>{};
    final Map<String, int> totalByType = <String, int>{};

    allQuestions.forEach((subject, questions) {
      for (final q in questions) {
        final typeRaw = (q['questionType'] ?? '').toString().trim();
        final typeKey = typeRaw.isEmpty ? 'Unknown Type' : typeRaw;
        final int qid = q['id'] as int;

        totalByType[typeKey] = (totalByType[typeKey] ?? 0) + 1;

        final hasOptionAnswer = (selectedAnswers[qid] ?? <String>{}).isNotEmpty;
        final hasIntegerAnswer = selectedIntegerAnswers.containsKey(qid);
        final hasNumericAnswer = getNumericRangeAnswer(
          qid,
          subject: subject,
        ).trim().isNotEmpty;

        if (hasOptionAnswer || hasIntegerAnswer || hasNumericAnswer) {
          attemptedByType[typeKey] = (attemptedByType[typeKey] ?? 0) + 1;
        }
      }
    });

    final unattemptedTypes = totalByType.keys
        .where((type) => (attemptedByType[type] ?? 0) == 0)
        .toList();

    if (unattemptedTypes.isEmpty) {
      showCustomSubmitDialog(context);
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Warning Before Submit'),
        content: Text(
          'You have not attempted any question in:\n\n${unattemptedTypes.join('\n')}\n\nDo you still want to submit?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Go Back')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              showCustomSubmitDialog(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Submit Anyway',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ===================================================
  // SAVE ANSWER TO OFFLINE HIVE
  // ===================================================
  Future<void> _saveAnswerOffline(int qid, String ans) async {
    var box = await Hive.openBox('offline_answers_${testId.value}');
    box.put(qid, ans);
  }

  Future<void> _deleteAnswerOffline(int qid) async {
    final box = await Hive.openBox('offline_answers_${testId.value}');
    await box.delete(qid);
  }

  // ===================================================
  // SYNC ANSWERS ONLINE
  // ===================================================

  // Check internet connectivity and sync when online
  void monitorConnectivity() {
    // Accept dynamic because package version may emit ConnectivityResult or List<ConnectivityResult>
    Connectivity().onConnectivityChanged.listen((dynamic result) {
      bool connected = false;

      if (result is ConnectivityResult) {
        connected = result != ConnectivityResult.none;
      } else if (result is List<ConnectivityResult>) {
        connected = result.any((r) => r != ConnectivityResult.none);
      }

      if (connected) {
        print("🌐 Internet connected. Syncing answers...");
        // fire-and-forget to keep the listener signature synchronous
        syncAnswersOnline();
      }
    });
  }

  // ===================================================
  // CURRENT QUESTIONS
  // ===================================================
  List<Map<String, dynamic>> get currentQuestions =>
      (allQuestions[selectedSubject.value] ?? [])
          .where(
            (q) =>
                selectedQuestionType.value.isEmpty ||
                (q['questionType'] ?? '') == selectedQuestionType.value,
          )
          .toList();

  // ===================================================
  // SELECT OPTION (A/B/C/D)
  // ===================================================
  /// Toggle selection for a given option in a multiple choice question
  Future<void> selectOption(int questionId, String optionKey) async {
    // Only allow one selection for single correct, comprehension, match, or SCQ option type
    // Mark as visited when option selected
    visitedQuestions.add(questionId);
    visitedQuestions.refresh();

    // If this is the last question in the current type, mark as visited
    final curType = selectedQuestionType.value;
    final curQuestions =
        allQuestions[selectedSubject.value]
            ?.where((q) => (q['questionType'] ?? '') == curType)
            .toList() ??
        [];
    if (curQuestions.isNotEmpty && curQuestions.last['id'] == questionId) {
      visitedQuestions.add(questionId);
      visitedQuestions.refresh();
    }
    final currentQuestionsList = currentQuestions;
    final q = currentQuestionsList.firstWhereOrNull(
      (q) => q['id'] == questionId,
    );
    final type = (q != null && q['questionType'] != null)
        ? q['questionType'].toString().toLowerCase()
        : '';
    if (type.contains('single correct') ||
        type.contains('comprehension') ||
        type.contains('match') ||
        type.contains('s.c.q')) {
      // Only one option allowed: selecting a new one auto-removes the previous
      selectedAnswers[questionId] = {optionKey};
    } else {
      // Multi-select fallback (if needed in future)
      final currentSet = selectedAnswers[questionId] ?? <String>{};
      if (currentSet.contains(optionKey)) {
        currentSet.remove(optionKey);
      } else {
        currentSet.add(optionKey);
      }
      selectedAnswers[questionId] = currentSet;
    }
    if ((selectedAnswers[questionId] ?? <String>{}).isNotEmpty) {
      _forceNotAttemptedSyncQuestions.remove(questionId);
    }
    _dirtyOptionQuestions.add(questionId);
    selectedAnswers.refresh();
  }

  // ===================================================
  // NEXT / PREVIOUS QUESTION
  // ===================================================
  Future<void> nextQuestion(BuildContext context) async {
    final qList = currentQuestions;
    if (qList.isEmpty) return;

    final q = qList[currentIndex.value];
    final questionId = q['id'] as int;
    visitedQuestions.add(questionId);
    visitedQuestions.refresh();
    final currentSubject = selectedSubject.value;
    final questionType = (q['questionType'] ?? '').toString().toLowerCase();

    await _commitCurrentAnswer(
      questionId: questionId,
      questionType: questionType,
      subject: currentSubject,
    );

    // NTA-like flow: Save & Next should convert a reviewed question to normal answered/unanswered.
    if (markedForReview.contains(questionId)) {
      markedForReview.remove(questionId);
      markedForReview.refresh();
    }

    _saveCurrentQuestionTime();

    // navigation: find next unattempted question across all types and subjects
    final allSubjects = subjects;
    final allTypes = questionTypes;
    int subjectIdx = subjects.indexOf(selectedSubject.value);
    int typeIdx = questionTypes.indexOf(selectedQuestionType.value);
    int qIdx = currentIndex.value;

    // Always advance to the next question, even if not attempted
    final curSubject = selectedSubject.value;
    final curType = selectedQuestionType.value;
    final curQuestions =
        allQuestions[curSubject]
            ?.where((q) => (q['questionType'] ?? '') == curType)
            .toList() ??
        [];
    // If not last in current type, go to next question
    if (qIdx + 1 < curQuestions.length) {
      currentIndex.value = qIdx + 1;
      return;
    }
    // If last in current type, go to next type (first question)
    if (typeIdx + 1 < allTypes.length) {
      final nextType = allTypes[typeIdx + 1];
      final questionsOfType =
          allQuestions[curSubject]
              ?.where((q) => (q['questionType'] ?? '') == nextType)
              .toList() ??
          [];
      if (questionsOfType.isNotEmpty) {
        selectedQuestionType.value = nextType;
        currentIndex.value = 0;
        return;
      }
    }
    // If last type, go to next subject (first type, first question)
    if (subjectIdx + 1 < allSubjects.length) {
      final nextSubject = allSubjects[subjectIdx + 1];
      final nextTypes = questionTypes;
      if (nextTypes.isNotEmpty) {
        final firstType = nextTypes[0];
        final questionsOfType =
            allQuestions[nextSubject]
                ?.where((q) => (q['questionType'] ?? '') == firstType)
                .toList() ??
            [];
        if (questionsOfType.isNotEmpty) {
          selectedSubject.value = nextSubject;
          selectedQuestionType.value = firstType;
          currentIndex.value = 0;
          return;
        }
      }
    }
    // If all done, stay on last question
    // If all done, show submit prompt
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: "You have reached the end of the test.!",
      desc:
          "If you want to try the unattempted questions (if any), visit the relevant subject and section before submitting.If you want to finish and exit the test, click on Submit Test.",
      btnCancelText: "Cancel",
      btnCancelOnPress: () {},
    ).show();
  }

  // ===================================================
  // SYNC ANSWERS ONLINE
  // ===================================================
  Future<void> syncAnswersOnline({
    bool includeUnattempted = false,
    void Function(int processed, int total)? onProgress,
  }) async {
    var box = await Hive.openBox('offline_answers_${testId.value}');
    var questionBox = await Hive.openBox('offlineexam${testId.value}');

    // Build entries by checking memory first, then offline.
    // Only include '--' defaults when explicitly requested (final submit).
    final pendingEntries = <dynamic, dynamic>{};

    for (final subjectList in allQuestions.values) {
      for (final q in subjectList) {
        final qid = q['id'] as int;
        final subject =
            (q['subject'] ?? q['subjectName'] ?? selectedSubject.value)
                .toString();

        // Priority 1: Check in-memory answers (latest selections)
        final memoryAnswer = _resolveAnswerFromMemory(qid, subject);

        if (memoryAnswer != null && memoryAnswer.isNotEmpty) {
          pendingEntries[qid] = memoryAnswer;
          continue;
        }

        // Priority 2: Check offline box
        final offlineAnswer = box.get(qid)?.toString().trim();
        if (offlineAnswer != null && offlineAnswer.isNotEmpty) {
          pendingEntries[qid] = offlineAnswer;
          continue;
        }

        if (includeUnattempted) {
          // Final submit expects every question to be sent.
          pendingEntries[qid] = '--';
        }
      }
    }

    if (pendingEntries.isEmpty) {
      onProgress?.call(0, 0);
      print("🔁 No offline answers to sync");
      return;
    }

    final entries = pendingEntries.entries.toList();
    final totalEntries = entries.length;
    int processedEntries = 0;
    onProgress?.call(processedEntries, totalEntries);

    for (var entry in entries) {
      final rawKey = entry.key;
      final studentAnsRaw = entry.value?.toString() ?? "";
      final normalizedStudentAnsRaw = studentAnsRaw.trim();
      final isUnattemptedMarker =
          normalizedStudentAnsRaw.isEmpty || normalizedStudentAnsRaw == '--';
      int? questionId;
      if (rawKey is int) {
        questionId = rawKey;
      } else {
        questionId = int.tryParse(rawKey.toString());
      }

      dynamic question;
      try {
        for (var v in questionBox.values) {
          try {
            if (v.questionId == questionId ||
                v.questionId.toString() == rawKey.toString()) {
              question = v;
              break;
            }
          } catch (_) {}
        }
      } catch (e) {
        print("❌ Error while searching questionBox: $e");
      }

      final batchIdValue = question?.batchId ?? 0;
      final examtestidd = question?.examTestId ?? 0;
      final correctAns = question?.optionCorrect ?? "";
      final intcorrectAns = question?.integerTypeCorrecrt ?? "";
      final numericRangeCorrectAnss = question?.numericRangeCorrectAns ?? "";
      final questionType =
          question?.questionType?.toString().toLowerCase() ?? "";

      // Prepare answer values
      Set<String> studentAnsSet = {};
      if (!isUnattemptedMarker) {
        studentAnsSet = normalizedStudentAnsRaw.split(',').toSet();
      }
      String studentAns = studentAnsSet.isNotEmpty
          ? studentAnsSet.join(',')
          : '--';

      var integerTypeCorrectAns;
      var numericRangeCorrectAns;
      if (questionType.contains('integer type')) {
        final fromState = selectedIntegerAnswers[questionId]?.toString() ?? '';
        final fromOffline = isUnattemptedMarker ? '' : normalizedStudentAnsRaw;
        final resolved = fromState.isNotEmpty ? fromState : fromOffline;
        integerTypeCorrectAns = resolved.isNotEmpty ? resolved : null;
        studentAns = '--';
      }
      if (_isNumericRangeType(questionType)) {
        numericRangeCorrectAns = isUnattemptedMarker
            ? null
            : _normalizeNumericForApi(normalizedStudentAnsRaw);
        studentAns = '--';
      }

      final isMcqType =
          questionType.contains('m.c.q.') ||
          questionType.contains('m.c.q') ||
          questionType.contains('mcq');

      String status;
      if (studentAnsSet.isEmpty &&
          (integerTypeCorrectAns == null ||
              integerTypeCorrectAns.toString().isEmpty) &&
          (numericRangeCorrectAns == null ||
              numericRangeCorrectAns.toString().isEmpty)) {
        status = "Not Attempted";
      } else if (studentAnsSet.contains(correctAns)) {
        status = "Correct";
      } else if (integerTypeCorrectAns != null &&
          integerTypeCorrectAns.toString() == intcorrectAns.toString() &&
          questionType.contains('integer type')) {
        status = "Correct";
      } else if (integerTypeCorrectAns != null &&
          integerTypeCorrectAns.toString() != intcorrectAns.toString() &&
          questionType.contains('integer type')) {
        status = "Incorrect";
      } else if (numericRangeCorrectAns != null &&
          _isNumericRangeType(questionType) &&
          _numericEqualsForStatus(
            numericRangeCorrectAns.toString(),
            numericRangeCorrectAnss.toString(),
          )) {
        status = "Correct";
      } else if (numericRangeCorrectAns != null &&
          _isNumericRangeType(questionType) &&
          !_numericEqualsForStatus(
            numericRangeCorrectAns.toString(),
            numericRangeCorrectAnss.toString(),
          )) {
        status = "Incorrect";
      } else {
        status = "Incorrect";
      }

      try {
        bool success;
        if (isMcqType) {
          final normalizedAnsSet = studentAnsSet
              .map((e) => e.toString().trim().toUpperCase())
              .where((e) => e == 'A' || e == 'B' || e == 'C' || e == 'D')
              .toSet();

          final choiceA = normalizedAnsSet.contains('A')
              ? 'A'
              : (isUnattemptedMarker ? '--' : '');
          final choiceB = normalizedAnsSet.contains('B')
              ? 'B'
              : (isUnattemptedMarker ? '--' : '');
          final choiceC = normalizedAnsSet.contains('C')
              ? 'C'
              : (isUnattemptedMarker ? '--' : '');
          final choiceD = normalizedAnsSet.contains('D')
              ? 'D'
              : (isUnattemptedMarker ? '--' : '');

          final correctA = (question?.optionCorrectA ?? '').toString();
          final correctB = (question?.optionCorrectB ?? '').toString();
          final correctC = (question?.optionCorrectC ?? '').toString();
          final correctD = (question?.optionCorrectD ?? '').toString();

          bool _isAttemptedChoice(String choice) =>
              choice.isNotEmpty && choice != '--';

          final statusA = _isAttemptedChoice(choiceA)
              ? (choiceA == correctA ? 'Correct' : 'Incorrect')
              : 'Not Attempted';
          final statusB = _isAttemptedChoice(choiceB)
              ? (choiceB == correctB ? 'Correct' : 'Incorrect')
              : 'Not Attempted';
          final statusC = _isAttemptedChoice(choiceC)
              ? (choiceC == correctC ? 'Correct' : 'Incorrect')
              : 'Not Attempted';
          final statusD = _isAttemptedChoice(choiceD)
              ? (choiceD == correctD ? 'Correct' : 'Incorrect')
              : 'Not Attempted';

          success = await msubmitquestion(
            studentidd.value,
            questionId ?? rawKey,
            batchIdValue.toString(),
            examtestidd.toString(),
            choiceA,
            correctA,
            statusA,
            choiceB,
            correctB,
            statusB,
            choiceC,
            correctC,
            statusC,
            choiceD,
            correctD,
            statusD,
            questionTimes[questionId].toString(),
            questionTestId.value,
            schoolId.value,
            studentid.value,
          );
        } else {
          success = await submitquestion(
            studentidd.value,
            questionId ?? rawKey,
            batchIdValue.toString(),
            examtestidd.toString(),
            studentAns,
            correctAns,
            status,
            schoolId.value,
            questionTimes[questionId].toString(),
            numericRangeCorrectAns?.toString() ?? "",
            intcorrectAns,
            integerTypeCorrectAns,
          );
        }

        if (success) {
          await box.delete(entry.key);
          if (questionId != null) {
            _forceNotAttemptedSyncQuestions.remove(questionId);
          }
          print("✅ Synced Q:${questionId ?? rawKey}");
          if (isMcqType) {
            print(
              "📤 MCQ UPLOADED → Q:${questionId ?? rawKey} | Student=${studentidd.value} | examtestid:$examtestidd | time:${questionTimes[questionId] ?? 0}",
            );
          } else {
            print(
              "📤 UPLOADED → Q:${questionId ?? rawKey} | SA:$studentAns || NSA : ${numericRangeCorrectAns?.toString() ?? ""} | | ISA : ${integerTypeCorrectAns?.toString() ?? ""} | CA:$correctAns | | ICA : $intcorrectAns | | NCA : $numericRangeCorrectAnss | Status:$status | Student=${studentidd.value} | examtestid:$examtestidd | time:${questionTimes[questionId] ?? 0}",
            );
          }
        } else {
          print("❌ Failed to sync Q:${questionId ?? rawKey}, will retry later");
        }
      } catch (e) {
        print("❌ Exception while syncing Q:${questionId ?? rawKey}: $e");
      } finally {
        processedEntries++;
        onProgress?.call(processedEntries, totalEntries);
      }
    }

    if (box.isEmpty) {
      print("✅ All offline answers synced successfully");
    } else {
      print("⚠️ Some answers remain unsynced, will retry when online");
    }
  }

  void previousQuestion() {
    final qList = currentQuestions;
    if (qList.isNotEmpty && currentIndex.value < qList.length) {
      final qId = qList[currentIndex.value]['id'] as int;
      discardUnsavedSelectionForQuestion(qId);
      visitedQuestions.add(qId);
      visitedQuestions.refresh();
    }

    final curSubject = selectedSubject.value;
    final curType = selectedQuestionType.value;
    final allSubjects = subjects;

    if (curSubject.isEmpty || curType.isEmpty || allSubjects.isEmpty) {
      if (currentIndex.value > 0) {
        _saveCurrentQuestionTime();
        currentIndex.value--;
      }
      return;
    }

    List<String> typesForSubject(String subject) {
      final questions = allQuestions[subject] ?? [];
      final types = questions
          .map((q) => (q['questionType'] ?? '').toString())
          .toSet()
          .toList();
      types.removeWhere((t) => t.isEmpty);
      return types;
    }

    List<Map<String, dynamic>> questionsForType(String subject, String type) {
      return (allQuestions[subject] ?? [])
          .where((q) => (q['questionType'] ?? '') == type)
          .toList();
    }

    if (currentIndex.value > 0) {
      _saveCurrentQuestionTime();
      currentIndex.value--;
      return;
    }

    final curTypes = typesForSubject(curSubject);
    final typeIdx = curTypes.indexOf(curType);
    if (typeIdx > 0) {
      final prevType = curTypes[typeIdx - 1];
      final prevTypeQuestions = questionsForType(curSubject, prevType);
      if (prevTypeQuestions.isNotEmpty) {
        _saveCurrentQuestionTime();
        selectedQuestionType.value = prevType;
        currentIndex.value = prevTypeQuestions.length - 1;
        return;
      }
    }

    final subjectIdx = allSubjects.indexOf(curSubject);
    if (subjectIdx > 0) {
      final prevSubject = allSubjects[subjectIdx - 1];
      final prevSubjectTypes = typesForSubject(prevSubject);
      if (prevSubjectTypes.isNotEmpty) {
        final prevType = prevSubjectTypes.last;
        final prevTypeQuestions = questionsForType(prevSubject, prevType);
        if (prevTypeQuestions.isNotEmpty) {
          _saveCurrentQuestionTime();
          selectedSubject.value = prevSubject;
          selectedQuestionType.value = prevType;
          currentIndex.value = prevTypeQuestions.length - 1;
        }
      }
    }
  }

  String generateQuestionTestId() {
    final random = Random().nextInt(9999999);
    return "$random";
  }

  // ===================================================
  // SUBMIT SINGLE QUESTION TO API
  // ===================================================
  Future<bool> submitquestion(
    var StudentId,
    var QuestionId,
    var BatchId,
    var ExamTestId,
    var ChoiceOption,
    var OptionCorrect,
    var OptionStatus,
    var SchoolId,
    var timeTaken,
    var numbertext,
    var IntegerTypeCorrecrtAns,
    var integerTypeCorrecrt,
  ) async {
    try {
      // Determine if this is a Numeric Range question
      String numRangeAnsToSend = "0";
      // Try to get the question type from allQuestions
      try {
        int? qidInt;
        if (QuestionId is int) {
          qidInt = QuestionId;
        } else {
          qidInt = int.tryParse(QuestionId.toString());
        }
        bool isNumericRange = false;
        for (var subjectList in allQuestions.values) {
          for (var q in subjectList) {
            if (q['id'] == qidInt) {
              final type = (q['questionType'] ?? '').toString().toLowerCase();
              if (_isNumericRangeType(type)) {
                isNumericRange = true;
              }
              break;
            }
          }
          if (isNumericRange) break;
        }
        if (isNumericRange) {
          numRangeAnsToSend = numbertext;
        }
      } catch (_) {
        // fallback: send 0 if any error
        numRangeAnsToSend = "0";
      }
      // Determine if this is an Integer Type question

      final Map<String, dynamic> body = {
        "StudentId": StudentId,
        "QuestionId": QuestionId,
        "BatchId": BatchId,
        "QuestionTestId": questionTestId.value,
        "ExamTestId": ExamTestId,
        "ChoiceOption": ChoiceOption,
        "OptionCorrect": OptionCorrect,
        "OptionStatus": OptionStatus,
        "SchoolId": SchoolId,
        "TimeTaken": timeTaken,
        "NumbricRangeAns": numRangeAnsToSend.isEmpty || numRangeAnsToSend == "0"
            ? null
            : numRangeAnsToSend,
        "IntegerTypeCorrecrtAns": integerTypeCorrecrt.toString(),
        "IntegerTypeCorrecrt": IntegerTypeCorrecrtAns.toString(),
      };

      final response = await Https.post(
        Uri.parse(Adminurl.submitquestion),
        headers: {
          'MobAppStdExm': 'as97kdw-jmzq60t-lxh135g-jdbq83-jk56nxs',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        print("✅ Saved QID $QuestionId");
        return true;
      } else {
        print(
          "❌ API Error \u001b[31m${response.statusCode}\u001b[0m: ${response.body}",
        );
        return false;
      }
    } catch (e) {
      print("❌ Exception submitting question: $e");
      return false;
    }
  }

  // ===================================================
  // SUBMIT multi QUESTION TO API
  Future<bool> msubmitquestion(
    var StudentId,
    var QuestionId,
    var BatchId,
    var ExamTestId,
    var ChoiceOptionA,
    var OptionCorrectA,
    var OptionStatusA,
    var ChoiceOptionB,
    var OptionCorrectB,
    var OptionStatusB,
    var ChoiceOptionC,
    var OptionCorrectC,
    var OptionStatusC,
    var ChoiceOptionD,
    var OptionCorrectD,
    var OptionStatusD,
    var TimeTaken,
    var QuestionTestId,
    var SchoolId,
    var CreateBy,
  ) async {
    try {
      // ✅ FLAT body (matches your required JSON exactly)
      final Map<String, dynamic> body = {
        "StudentId": StudentId,
        "QuestionId": QuestionId,
        "BatchId": BatchId,
        "ExamTestId": ExamTestId,

        "ChoiceOptionA": ChoiceOptionA,
        "OptionCorrectA": OptionCorrectA,
        "OptionStatusA": OptionStatusA,

        "ChoiceOptionB": ChoiceOptionB,
        "OptionCorrectB": OptionCorrectB,
        "OptionStatusB": OptionStatusB,

        "ChoiceOptionC": ChoiceOptionC,
        "OptionCorrectC": OptionCorrectC,
        "OptionStatusC": OptionStatusC,

        "ChoiceOptionD": ChoiceOptionD,
        "OptionCorrectD": OptionCorrectD,
        "OptionStatusD": OptionStatusD,

        "TimeTaken": TimeTaken,
        "QuestionTestId": QuestionTestId,
        "SchoolId": SchoolId,
        "CreateBy": CreateBy,
      };

      final response = await Https.post(
        Uri.parse(Adminurl.submitquestion),
        headers: {
          'MobAppStdExm': 'as97kdw-jmzq60t-lxh135g-jdbq83-jk56nxs',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("📤 Request Body: ${jsonEncode(body)}");

      if (response.statusCode == 200) {
        print("✅ Saved QID $QuestionId");
        return true;
      } else {
        print("❌ API Error ${response.statusCode}: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Exception submitting question: $e");
      return false;
    }
  }

  void toggleMarkForReview() {
    final qList = currentQuestions;
    if (qList.isEmpty) return;

    final id = qList[currentIndex.value]['id'] as int;
    // Marking/unmarking from the current screen means the question has been visited.
    visitedQuestions.add(id);
    if (markedForReview.contains(id)) {
      markedForReview.remove(id);
    } else {
      markedForReview.add(id);
    }
  }

  // ===================================================
  // SUBMIT TEST
  // ===================================================

  // Submit Report Question
  Future<void> report(
    var questionId,
    var text,
    var schoolId,
    var createdby,
  ) async {
    try {
      final response = await Https.post(
        Uri.parse(Adminurl.reportquestion),
        headers: {
          'MobAppStdExm': 'as97kdw-jmzq60t-lxh135g-jdbq83-jk56nxs',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "QuestionId": questionId,
          "ReportText": text,
          "CreateBy": createdby,
          "SchoolId": schoolId,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Report Submitted for QID $questionId");
        Get.snackbar(
          "Success",
          "Report Submitted Successfully",
          colorText: Colors.white,
          backgroundColor: Color(0xFF8b2d28),
        );
      } else {
        print("❌ API Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception submitting report: $e");
    }
  }

  // Report Question
  void reportQuestion(
    BuildContext context,
    String questionText,
    int questionId,
  ) {
    final TextEditingController messageController = TextEditingController();
    final themeColor = const Color(0xFF8B2D28); // Premium deep red

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Title
            Text(
              "Report Question",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 12),
            // Question Text
            Text(
              "Q. $questionText",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Describe the issue",
                labelStyle: TextStyle(color: Colors.deepPurple),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: themeColor, width: 1.3),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Buttons Row
            Row(
              children: [
                /// Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: themeColor, width: 1.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// Submit Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final msg = messageController.text.trim();
                      if (msg.isEmpty) {
                        Get.snackbar(
                          "Error",
                          "Please enter a message",
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.black,
                        );
                        return;
                      }

                      /// Show Loading
                      Get.dialog(
                        Center(
                          child: LoadingAnimationWidget.newtonCradle(
                            color: Colors.redAccent,
                            size: 80.h,
                          ),
                        ),
                        barrierDismissible: false,
                      );

                      await report(
                        questionId,
                        msg,
                        schoolId.value,
                        studentidd.value,
                      );

                      /// Close loading first
                      Navigator.of(Get.context!).pop();
                      Navigator.of(Get.context!).pop();

                      /// Close Bottom Sheet

                      /// Success message
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      isScrollControlled: true,
      enableDrag: true,
    );
  }

  bool isAnswered(Map<String, dynamic> q) {
    final id = q['id'] as int;
    final type = (q['questionType'] ?? '').toString().toLowerCase();

    if (type.contains('integer type')) {
      final v = selectedIntegerAnswers[id];
      return v != null && v != -1;
    }

    if (_isNumericRangeType(type)) {
      return hasNumericRangeAnswer(id, subject: selectedSubject.value);
    }

    // numeric range stored in selectedAnswers as {value}
    final ans = selectedAnswers[id];
    return ans != null && ans.isNotEmpty;
  }

  Future<void> submitTest(BuildContext? context) async {
    if (_isSubmittingTest) return;
    _isSubmittingTest = true;
    submitProgressPercent.value = 0.0;
    submitUploadedCount.value = 0;
    submitTotalToUpload.value = 0;
    // Commit (not discard) the current question's answer so that typing an answer
    // and pressing Submit directly (without Save & Next) still registers it.
    final _curList = currentQuestions;
    if (_curList.isNotEmpty && currentIndex.value < _curList.length) {
      final _curQ = _curList[currentIndex.value];
      await _commitCurrentAnswer(
        questionId: _curQ['id'] as int,
        questionType: (_curQ['questionType'] ?? '').toString().toLowerCase(),
        subject: selectedSubject.value,
      );
    }

    void updateSubmitProgress(double value) {
      submitProgressPercent.value = value.clamp(0.0, 100.0);
    }

    try {
      final reviewData = <Map<String, dynamic>>[];
      updateSubmitProgress(10.0);

      int attemptedCount = 0;
      int reviewedCount = 0;
      int totalMarks = 0;
      double obtainedMarks = 0;

      allQuestions.forEach((subject, list) {
        for (var q in list) {
          final id = q['id'] as int;
          final ansSet = selectedAnswers[id] ?? <String>{};
          final questionType = (q['questionType'] ?? '')
              .toString()
              .toLowerCase();
          final numericAnswer = getNumericRangeAnswer(id, subject: subject);
          final bool isAnswered = _isNumericRangeType(questionType)
              ? numericAnswer.isNotEmpty
              : (ansSet.isNotEmpty || selectedIntegerAnswers.containsKey(id));
          final bool isMarked = markedForReview.contains(id);

          if (isAnswered && !isMarked) attemptedCount++;
          if (isMarked) reviewedCount++;

          final int marks = (q['marks'] ?? 0) as int;
          totalMarks += marks;
          final bool negative =
              (q['quesNegativeMarking'] ?? q['negativeMarking'] ?? 'No')
                  .toString()
                  .toLowerCase() ==
              'yes';
          final dynamic negativeRaw =
              q['quesNegativeMarkingMarks'] ?? q['negativeMarkingMarks'];
          final double configuredNegativeMarks = negativeRaw is num
              ? negativeRaw.toDouble().abs()
              : (double.tryParse(negativeRaw?.toString() ?? '0')?.abs() ?? 0.0);
          final double negativeMarksPerWrong = configuredNegativeMarks > 0
              ? configuredNegativeMarks
              : (marks * 0.25);

          String studentAnsDisplay = "—";
          String correctAnsDisplay = "—";
          bool isCorrect = false;
          int mcqCorrectCount = 0;
          int mcqTotalCorrect = 0;
          int mcqWrongSelectedCount = 0;
          List<Map<String, dynamic>> optionDetails = [];
          double questionObtainedMarks = 0;

          // MCQ multi-select (multiple correct)
          final bool isMcqType =
              questionType.contains('m.c.q.') ||
              questionType.contains('m.c.q') ||
              questionType.contains('mcq');
          if (isMcqType) {
            final options = (q['options'] as List<dynamic>?) ?? [];
            final normalizedAnsSet = ansSet
                .map((k) => k.toString().trim().toUpperCase())
                .where((k) => k.isNotEmpty)
                .toSet();

            final correctKeys = <String>{};
            final ocA = (q['optionCorrectA'] ?? '')
                .toString()
                .trim()
                .toUpperCase();
            final ocB = (q['optionCorrectB'] ?? '')
                .toString()
                .trim()
                .toUpperCase();
            final ocC = (q['optionCorrectC'] ?? '')
                .toString()
                .trim()
                .toUpperCase();
            final ocD = (q['optionCorrectD'] ?? '')
                .toString()
                .trim()
                .toUpperCase();

            String _normText(String v) {
              return v.toUpperCase().replaceAll(RegExp(r'\s+'), ' ').trim();
            }

            Iterable<String> _extractKeysFromRaw(dynamic raw) {
              final v = (raw ?? '').toString().trim().toUpperCase();
              if (v.isEmpty || v == 'NULL') return const <String>[];
              return v
                  .split(RegExp(r'[,/|]'))
                  .map((e) => e.trim().toUpperCase())
                  .where((e) => e == 'A' || e == 'B' || e == 'C' || e == 'D');
            }

            void _extractKeysFromTextMatch(dynamic raw) {
              final rawStr = (raw ?? '').toString().trim();
              if (rawStr.isEmpty || rawStr.toUpperCase() == 'NULL') return;

              final normalizedRaw = _normText(rawStr);
              final tokens = rawStr
                  .split(RegExp(r'[/|,]'))
                  .map((e) => _normText(e))
                  .where((e) => e.isNotEmpty)
                  .toList();

              for (final opt in options) {
                final key = (opt['key'] ?? '').toString().trim().toUpperCase();
                if (key.isEmpty) continue;
                final value = _normText((opt['value'] ?? '').toString());
                if (value.isEmpty) continue;

                // Exact full match
                if (normalizedRaw == value) {
                  correctKeys.add(key);
                  continue;
                }

                // Token-wise match for strings like "opt1 / opt2 / opt3"
                if (tokens.any((t) => t == value)) {
                  correctKeys.add(key);
                }
              }
            }

            // 1) Collect explicit key values from all correct fields.
            correctKeys.addAll(_extractKeysFromRaw(ocA));
            correctKeys.addAll(_extractKeysFromRaw(ocB));
            correctKeys.addAll(_extractKeysFromRaw(ocC));
            correctKeys.addAll(_extractKeysFromRaw(ocD));
            correctKeys.addAll(_extractKeysFromRaw(q['correctOption']));

            // 1b) Collect by matching text content against option values.
            _extractKeysFromTextMatch(ocA);
            _extractKeysFromTextMatch(ocB);
            _extractKeysFromTextMatch(ocC);
            _extractKeysFromTextMatch(ocD);
            _extractKeysFromTextMatch(q['correctOption']);

            // 2) Support boolean-style flags per option slot (true/yes/1).
            bool _isTrueFlag(String value) {
              return value == 'TRUE' ||
                  value == 'YES' ||
                  value == 'Y' ||
                  value == '1';
            }

            if (_isTrueFlag(ocA)) correctKeys.add('A');
            if (_isTrueFlag(ocB)) correctKeys.add('B');
            if (_isTrueFlag(ocC)) correctKeys.add('C');
            if (_isTrueFlag(ocD)) correctKeys.add('D');

            mcqTotalCorrect = correctKeys.length;

            final bool selectedA = normalizedAnsSet.contains('A');
            final bool selectedB = normalizedAnsSet.contains('B');
            final bool selectedC = normalizedAnsSet.contains('C');
            final bool selectedD = normalizedAnsSet.contains('D');

            final statusMap = <String, String>{
              'A': !selectedA
                  ? 'Not Attempted'
                  : (ocA == 'A' ? 'Correct' : 'Incorrect'),
              'B': !selectedB
                  ? 'Not Attempted'
                  : (ocB == 'B' ? 'Correct' : 'Incorrect'),
              'C': !selectedC
                  ? 'Not Attempted'
                  : (ocC == 'C' ? 'Correct' : 'Incorrect'),
              'D': !selectedD
                  ? 'Not Attempted'
                  : (ocD == 'D' ? 'Correct' : 'Incorrect'),
            };

            mcqCorrectCount = statusMap.values
                .where((s) => s == 'Correct')
                .length;
            mcqWrongSelectedCount = statusMap.values
                .where((s) => s == 'Incorrect')
                .length;
            final int mcqSelectedCount =
                mcqCorrectCount + mcqWrongSelectedCount;

            final double maxMarks = marks.toDouble();
            final bool exactAllCorrect =
                mcqTotalCorrect > 0 &&
                mcqCorrectCount == mcqTotalCorrect &&
                mcqWrongSelectedCount == 0;

            if (mcqSelectedCount == 0) {
              questionObtainedMarks = 0;
            } else if (exactAllCorrect) {
              questionObtainedMarks = maxMarks;
            } else if (mcqWrongSelectedCount > 0) {
              // MCQ rule: if any selected option is incorrect,
              // award only one negative penalty (no positive marks).
              questionObtainedMarks = -negativeMarksPerWrong;
            } else {
              // Partial for MCQ: +1 mark for each correctly selected option.
              questionObtainedMarks = mcqCorrectCount.toDouble();
              if (questionObtainedMarks > maxMarks) {
                questionObtainedMarks = maxMarks;
              }
            }

            obtainedMarks += questionObtainedMarks;

            // UI data
            optionDetails = options.map((opt) {
              final key = (opt['key'] ?? '').toString().trim().toUpperCase();
              final value = opt['value'] ?? '';
              final selected = normalizedAnsSet.contains(key);
              final isOptionCorrect = correctKeys.contains(key);
              return {
                'key': key,
                'value': value,
                'selected': selected,
                'isCorrect': isOptionCorrect,
                'status': statusMap[key] ?? 'Not Attempted',
              };
            }).toList();

            final sortedSelected = normalizedAnsSet.toList()..sort();
            studentAnsDisplay = sortedSelected.isNotEmpty
                ? sortedSelected.join(',')
                : '—';
            correctAnsDisplay = correctKeys.isNotEmpty
                ? (correctKeys.toList()..sort()).join(',')
                : '—';

            isCorrect = exactAllCorrect;
          }
          // Single correct, match, comprehension
          else if (questionType.contains('single correct') ||
              questionType.contains('match') ||
              questionType.contains('comprehension')) {
            final options = q['options'] as List<dynamic>? ?? [];
            final correctKey = (q['correctOption'] ?? "").toString();
            // Store correct and selected as keys for UI mapping
            correctAnsDisplay = correctKey.isNotEmpty ? correctKey : '—';
            studentAnsDisplay = ansSet.isNotEmpty ? ansSet.join(',') : '—';
            isCorrect = ansSet.contains(correctKey);
            optionDetails = options.map((opt) {
              final key = opt['key'] ?? '';
              final value = opt['value'] ?? '';
              final selected = ansSet.contains(key);
              final isOptionCorrect = key == correctKey;
              return {
                'key': key,
                'value': value,
                'selected': selected,
                'isCorrect': isOptionCorrect,
              };
            }).toList();
          }
          // Integer type
          else if (questionType.contains('integer type')) {
            final correctInt = (q['integerTypeCorrecrt'] ?? "").toString();
            final studentInt = selectedIntegerAnswers[id]?.toString() ?? "—";
            correctAnsDisplay = correctInt;
            studentAnsDisplay = studentInt;
            isCorrect = studentInt == correctInt && studentInt != "—";
          }
          // Numeric range
          else if (_isNumericRangeType(questionType)) {
            final correctNum = (q['numericRangeCorrectAns'] ?? "").toString();
            final studentNum = numericAnswer.isNotEmpty ? numericAnswer : "—";
            correctAnsDisplay = correctNum;
            studentAnsDisplay = studentNum;
            // Use _numericEqualsForStatus so both single values ("16") and
            // range values ("14-18") are handled correctly.
            isCorrect =
                studentNum != "—" &&
                _numericEqualsForStatus(studentNum, correctNum);
          }
          // Other types
          else {
            studentAnsDisplay = ansSet.isNotEmpty ? ansSet.join(',') : "—";
            correctAnsDisplay = (q['correctOption'] ?? "—").toString();
            isCorrect = ansSet.contains(correctAnsDisplay);
          }

          final bool isWrong = isAnswered && !isCorrect;
          double questionObtainedForReview = isMcqType
              ? questionObtainedMarks
              : (isCorrect
                    ? marks.toDouble()
                    : (isWrong && negative ? -negativeMarksPerWrong : 0.0));
          if (!isMcqType) {
            if (isCorrect) {
              obtainedMarks += marks;
            } else if (isWrong && negative) {
              obtainedMarks -= negativeMarksPerWrong;
            }
          }

          reviewData.add({
            'subject': subject,
            'question': q['question'],
            'questionType': q['questionType'] ?? '',

            // ✅ ADD THESE TWO
            'questionImg': q['questionImg'] ?? '',
            'options': q['options'] ?? [],

            'studentAnswer': studentAnsDisplay,
            'correctAnswer': correctAnsDisplay,
            'isCorrect': isCorrect,
            'marks': marks,
            'obtainedQuestionMarks': questionObtainedForReview,
            'negativeMarking': negative ? "Yes" : "No",
            'negativeMarkingMarks': negativeMarksPerWrong,
            'time': questionTimes[id] ?? 0,
            'rating': q['rating'] ?? 0.0,
            'optionDetails': optionDetails,
            'mcqCorrectCount': mcqCorrectCount,
            'mcqTotalCorrect': mcqTotalCorrect,
            'mcqWrongSelectedCount': mcqWrongSelectedCount,
            'isMcqPartial':
                isMcqType && !isCorrect && questionObtainedMarks > 0,
          });
        }
      });

      final total = reviewData.length;

      updateSubmitProgress(25.0);

      // Calculate not attempted questions (total questions - attempted - marked for review)
      final notAttemptedCount = total - attemptedCount - reviewedCount;

      // Check internet connectivity before finalizing submission
      final conn = await Connectivity().checkConnectivity();

      final dialogContext = Get.overlayContext ?? Get.context ?? context;
      if (dialogContext != null) {
        Get.dialog(
          Obx(
            () => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_upload_rounded, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Submitting Test',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Uploading answers to server. Please wait...',
                      style: TextStyle(fontSize: 13.sp, color: Colors.black54),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: submitProgressPercent.value / 100,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${submitProgressPercent.value.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${submitUploadedCount.value}/${submitTotalToUpload.value} uploaded',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          barrierDismissible: false,
        );
      }

      if (conn == ConnectivityResult.none) {
        try {
          updateSubmitProgress(60.0);
          var box = await Hive.openBox('offline_answers_${testId.value}');
          final totalToSave = allQuestions.values.fold<int>(
            0,
            (sum, list) => sum + list.length,
          );
          submitTotalToUpload.value = totalToSave;
          int saved = 0;
          for (final subjectList in allQuestions.values) {
            for (final q in subjectList) {
              final qid = q['id'] as int;
              final subject =
                  (q['subject'] ?? q['subjectName'] ?? selectedSubject.value)
                      .toString();
              final answer = _resolveAnswerFromMemory(qid, subject);
              await box.put(qid, answer.isNotEmpty ? answer : '--');
              saved++;
              submitUploadedCount.value = saved;
              if (totalToSave > 0) {
                updateSubmitProgress(60 + (saved / totalToSave) * 38);
              }
            }
          }
          print("💾 No internet — saved all answers offline");
          Get.snackbar(
            "Offline",
            "No internet. Answers saved and will sync when online",
          );
        } catch (e) {
          print("❌ Failed to save answers offline before submit: $e");
        }
      } else {
        updateSubmitProgress(35.0);
        await syncAnswersOnline(
          includeUnattempted: true,
          onProgress: (processed, total) {
            submitUploadedCount.value = processed;
            submitTotalToUpload.value = total;
            if (total <= 0) {
              updateSubmitProgress(98.0);
              return;
            }
            final uploadPercent = (processed / total) * 63.0;
            updateSubmitProgress(35.0 + uploadPercent);
          },
        );
      }

      updateSubmitProgress(100.0);

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.offAll(
        () => ResultScreen(
          total: total,
          attempted: attemptedCount,
          reviewed: reviewedCount,
          notAttempted: notAttemptedCount,
          totalMarks: totalMarks,
          obtainedMarks: obtainedMarks.toInt(),
          questionReviewData: reviewData,
        ),
      );

      // Show snackbar immediately after submit
      Get.snackbar(
        "Test Submitted",
        "Your test has been submitted successfully!",
        backgroundColor: Color(0xFF8b2d28),
        colorText: Colors.white,
      );
    } finally {
      _isSubmittingTest = false;
    }
  }

  // Add this method to print all test data in JSON format
  void printTestDataAsJson() {
    final questions = currentQuestions;
    final testData = {
      'test_info': {
        'selected_subject': selectedSubject.value,
        'current_question_index': currentIndex.value,
        'total_questions': questions.length,
        'remaining_time_seconds': remainingSeconds.value,
        'formatted_time': formattedTime,
      },
      'statistics': {
        'total_questions': questions.length,
        'attempted': selectedAnswers.length,
        'marked_for_review': markedForReview.length,
        'not_attempted': questions.length - selectedAnswers.length,
        'visited_questions': visitedQuestions.length,
      },
      'subjects': subjects,
      'questions': questions.map((q) {
        final id = q['id'];
        return {
          'id': id,
          'subject': q['subject'],
          'question': q['question'],
          'rating': q['rating'],
          'options': q['options'],
          'correct_option': q['correct_option'],
          'student_answer': (selectedAnswers[id]?.join(',') ?? 'Not Attempted'),
          'is_correct':
              (selectedAnswers[id]?.contains(q['correct_option']) ?? false),
          'is_marked_for_review': markedForReview.contains(id),
          'is_visited': visitedQuestions.contains(id),
        };
      }).toList(),
      'answers_summary': selectedAnswers.map(
        (key, value) => MapEntry(key.toString(), value.join(',')),
      ),
      'marked_questions': markedForReview.toList(),
      'visited_questions': visitedQuestions.toList(),
    };

    // Print formatted JSON
    final jsonString = JsonEncoder.withIndent('  ').convert(testData);
    print('=== TEST DATA JSON ===');
    print(jsonString);
    print('=== END TEST DATA ===');

    return;
  }

  /*
  Placeholder classes to satisfy compile-time reference to FlutterAppUsage().
  Replace these with the real app-usage package implementation or import
  the appropriate package when integrating actual usage tracking.
*/
}
