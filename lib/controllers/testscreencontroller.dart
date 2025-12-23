import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gold_app/Model/exammodel.dart';
import 'package:gold_app/appurl/adminurl.dart';
import 'package:gold_app/infrastructure/routes/admin_routes.dart';
import 'package:gold_app/localstorage.dart';
import 'package:gold_app/prefconst.dart';
import 'package:gold_app/screens/submitscreenview%20copy.dart';
import 'package:gold_app/utils/localStorage/hivemodel.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

class Testscreencontroller extends GetxController {
  // ------------ SUBJECT / QUESTIONS ------------
  final subjects = <String>[].obs;
  final selectedSubject = ''.obs;
 Timer? _timer;
  var remainingSeconds = 0.obs;
  var timerDisplay = '00:00'.obs;
  var schoolId = ''.obs;
  var courseId = ''.obs;
  var testId = ''.obs;
 var studentid = ''.obs;
 var examtestid = ''.obs;
  var studentidd = ''.obs;
  var passcode = ''.obs;
  var batchid = ''.obs;

  // ------------ TIMER ------------
  RxInt viewsecond = 0.obs;        // total minutes from API
  RxInt totalSeconds = 0.obs;      // total seconds
  RxBool isTimerRunning = false.obs;
var time = ''.obs;
   var assignmenttopicid = ''.obs;
   var assignmentchapterid = ''.obs;
  Timer? quizTimer;

  // ------------ QUESTION STATE ------------
  final currentIndex = 0.obs;
final questionTestId = ''.obs;
  /// Stores ONLY option key "A"/"B"/"C"/"D" or List<String> for multi-select
  final selectedAnswers = <int, dynamic>{}.obs;

  final markedForReview = <int>{}.obs;
  final visitedQuestions = <int>{}.obs;

  /// subject → list of questions
  final allQuestions = <String, List<Map<String, dynamic>>>{}.obs;

  // Getter for current questions based on selected subject
  List<Map<String, dynamic>> get currentQuestions {
    if (selectedSubject.value.isEmpty) return [];
    return allQuestions[selectedSubject.value] ?? [];
  }

  // ===================================================
  // INIT
  // ===================================================
  // Generate unique question test ID
  String generateQuestionTestId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(99999999);
    return '$random';
  }

@override
void onInit() async {
  super.onInit();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

 questionTestId.value = generateQuestionTestId();

  schoolId.value   = await PrefManager().readValue(key: PrefConst.SchoolId) ?? '';
  studentid.value  = await PrefManager().readValue(key: PrefConst.CourseId) ?? '';
   studentidd.value  = await PrefManager().readValue(key: PrefConst.StudentId) ?? '';
   time.value = Get.arguments['timelimit'] ?? '';
       assignmenttopicid.value = Get.arguments['assignmenttopicid'] ?? '';
    assignmentchapterid.value = Get.arguments['assignmentchapterid'] ?? '';

 // BatchId.value    = await PrefManager().readValue(key: PrefConst.CourseId) ?? ''; 
  testId.value     = Get.arguments['testId'] ?? '';
  passcode.value   = Get.arguments['passcode'] ?? '';

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
      final int minutes = (firstSubjectList.first['viewsecond'] as int?) ?? 0;
      viewsecond.value = minutes;

      if (viewsecond.value > 0) {
        startTimer(viewsecond.value);
      } else {
        print("⚠️ viewsecond is 0 → Timer not started");
      }
    }
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
      headers: {
        'Content-Type': 'application/json',
       
      },
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
        "FeedBackType": "ExamTest"
      }),
    );
    print(jsonEncode);

    if (response.statusCode == 200) {
      print("✅ Feedback submitted successfully");
      Get.offAllNamed(AdminRoutes.LOADING_SCREEN);
      print(response.body);
      Get.snackbar("Success", "Feedback submitted",
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      print("❌ Server error: ${response.statusCode}");
      print(response.body);
      Get.snackbar("Error", "Failed to submit feedback",
          backgroundColor: Colors.red, colorText: Colors.white);
    }

  } catch (e) {
    print("❌ Exception while submitting feedback: $e");
    Get.snackbar("Error", "Something went wrong",
        backgroundColor: Colors.red, colorText: Colors.white);
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

    print("⏱ Timer started for $minutes minutes (${totalSeconds.value} seconds)");
  }

  void autoSubmit() {
    // AUTO SUBMIT WHEN TIME FINISHES
    if (Get.context != null) {
      AwesomeDialog(
        context: Get.context!,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: "Time's Up!",
        desc: "Your exam time has ended. Your answers are being submitted automatically.",
        autoHide: const Duration(seconds: 3),
        onDismissCallback: (type) {
          submitTest(Get.context);
        },
      ).show();
      
      // Also submit after 3 seconds regardless of dialog state
      Future.delayed(const Duration(seconds: 3), () {
        submitTest(Get.context);
      });
    } else {
      submitTest(Get.context);
    }
  }



  // ===================================================
  // LOAD QUESTIONS FROM API
  // ===================================================
  Future<void> _loadQuestions() async {
    final topicId = assignmenttopicid.value.isEmpty ? '' : assignmenttopicid.value;
  final chapterId = assignmentchapterid.value.isEmpty ? '' : assignmentchapterid.value;
    final url =
      '${Adminurl.testurl}/${schoolId.value}/${studentid.value}/$topicId/$chapterId/${testId.value}/${passcode.value}';
    print("🔗 Fetching questions from: $url");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"MobAppAssignmentKey": "bdty93Y-HSFxe8-133fec-yDgK63-5gsHNs6",
},
      );

      if (response.statusCode != 200) {
        print(response.body);
        Get.snackbar("Error", "Server error: ${response.statusCode}");
        return;
      }

      print(response.body);

      final parsed = exammodel.fromJson(jsonDecode(response.body));

      // **Save data to offline Hive**
      await _saveToOffline(parsed.data!);  // Store questions offline first

      // **Do not load questions into the UI yet, let it be stored in Hive**
      print("Questions saved to offline Hive!");

    } catch (e) {
      print("❌ Error during API fetch. Falling back to offline...");
      // **Load questions from Hive if no internet**
      return _loadFromOffline();
    }
  }

// ===================================================
// SAVE QUESTIONS TO OFFLINE HIVE
// ===================================================
Future<void> _saveToOffline(List<Data> questions) async {
  try {
    // ✅ Close the box if it's already open
    if (Hive.isBoxOpen('offlineexam${testId.value}')) {
      await Hive.box('offlineexam${testId.value}').close();
    }
    
    var box = await Hive.openBox<Hivemodel>('offlineexam${testId.value}');
    await box.clear();  // Clear existing data

    for (var q in questions) {
      await box.add(
        Hivemodel()
          ..questionId = q.questionId
          ..subjectName = q.subjectName
          ..questions = q.questions
          ..optionA = q.optionA
          ..ansOptionA = q.ansOptionA
          ..optionB = q.optionB
          ..ansOptionB = q.ansOptionB
          ..optionC = q.optionC
          ..ansOptionC = q.ansOptionC
          ..optionD = q.optionD
          ..ansOptionD = q.ansOptionD
          ..optionCorrect = q.optionCorrect
          ..correctOptionText = q.correctOptionText
          ..questionRating = q.questionRating
          ..questionMarks = q.questionMarks
          ..totalMinutes = q.totalMinutes
          ..schoolId = q.schoolId?.toString()
          ..batchId = q.batchId
          ..examTestId = q.examTestId,
      );
    }

    print("Questions saved to offline Hive!");
  } catch (e) {
    print("❌ Error saving to Hive: $e");
  }
}

// ===================================================
// LOAD QUESTIONS FROM OFFLINE HIVE
// ===================================================
Future<void> _loadFromOffline() async {
  try {
    // ✅ Check if box is already open, if not open it
    Box<Hivemodel> questionBox;
    if (Hive.isBoxOpen('offlineexam${testId.value}')) {
      questionBox = Hive.box<Hivemodel>('offlineexam${testId.value}');
    } else {
      questionBox = await Hive.openBox<Hivemodel>('offlineexam${testId.value}');
    }

    if (questionBox.isEmpty) {
      Get.snackbar("Error", "No offline questions available");
      return;
    }

    allQuestions.clear();

    int fallbackId = 1; // ✅ ensures unique IDs

    for (final q in questionBox.values) {
      final subject = q.subjectName ?? 'General';
      allQuestions.putIfAbsent(subject, () => []);

      // store ids for submit
      batchid.value = (q.batchId ?? 0).toString();
      examtestid.value = (q.examTestId ?? 0).toString();

      // ✅ FIX: QuestionId from API is 0, so generate unique id
      int id = (q.questionId ?? 0);
      if (id == 0) id = fallbackId++;

      allQuestions[subject]!.add({
        // ✅ normalized keys (USE THESE IN VIEW)
        'id': id,
        'question': q.questions ?? '',

        // ✅ normalized options list used by view
        'options': [
          {'key': 'A', 'text': q.optionA ?? q.ansOptionA ?? ''},
          {'key': 'B', 'text': q.optionB ?? q.ansOptionB ?? ''},
          {'key': 'C', 'text': q.optionC ?? q.ansOptionC ?? ''},
          {'key': 'D', 'text': q.optionD ?? q.ansOptionD ?? ''},
        ].where((e) => (e['text'] ?? '').toString().trim().isNotEmpty).toList(),

        // ✅ normalized correct option (the API uses "D", you want just key)
        'correctKey': (q.optionCorrect ?? '').toString().trim(),

        'viewsecond': q.totalMinutes ?? 0,
        'rating': int.tryParse(q.questionRating ?? '0') ?? 0,

        'marks': q.questionMarks ?? 0,

        // keep server ids separately if needed later
        'serverQuestionId': q.questionId ?? 0,
        'batchId': q.batchId ?? 0,
        'examTestId': q.examTestId ?? 0,
      });
    }

    subjects.value = allQuestions.keys.toList();
    if (subjects.isNotEmpty) {
      selectedSubject.value = subjects.first;
    }

    // visited
    final list = currentQuestions;
    if (list.isNotEmpty) {
      visitedQuestions.add(list.first['id'] as int);
    }

    allQuestions.refresh();
    print("✅ Loaded questions from offline Hive.");
  } catch (e) {
    print("❌ Error loading from offline Hive: $e");
    Get.snackbar("Error", "Failed to load offline questions");
  }
}

// ===================================================
// SAVE ANSWER TO OFFLINE HIVE
// ===================================================
Future<void> _saveAnswerOffline(int qid, String ans) async {
  try {
    Box answerBox;
    if (Hive.isBoxOpen('offline_answers_${testId.value}')) {
      answerBox = Hive.box('offline_answers_${testId.value}');
    } else {
      answerBox = await Hive.openBox('offline_answers_${testId.value}');
    }
    await answerBox.put(qid, ans);
  } catch (e) {
    print("❌ Error saving answer offline: $e");
  }
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
  ) async {
    try {
    final response = await http.post(
      Uri.parse(Adminurl.submitquestion),
      headers: {
        "MobAppStdAssign": "Mg97kdw-jm47r0t-lxn2mg-jdrtcs3-jk22mer",
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "StudentId": StudentId,
        "QuestionId": QuestionId,
        "BatchId": BatchId,
        "ExamTestId": ExamTestId,
        "AssigtChapterId": int.tryParse(assignmentchapterid.value) ?? 0,
        "AssigtTopicId": int.tryParse(assignmenttopicid.value) ?? 0,
        "ChoiceOption": ChoiceOption,
        "OptionCorrect": OptionCorrect,
        "OptionStatus": OptionStatus,
        "QuestionTestId": questionTestId.value,
        "SchoolId": SchoolId,
        "CreateBy": StudentId
      }),
    );
    
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
    if (markedForReview.contains(id)) {
      markedForReview.remove(id);
    } else {
      markedForReview.add(id);
    }
  }

  // ===================================================
  // SUBMIT TEST
  // ===================================================
  void showSubmitDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      title: "Submit Test?",
      desc: "Are you sure you want to submit your answers?",
      btnOkText: "Submit",
      btnCancelText: "Review",
      btnOkOnPress: () => submitTest(context),
    ).show();
  }

  // Submit Report Question
  Future<void> report(
    var questionId,
    var text,
    var schoolId,
    var createdby,
  ) async {
    try {
      final response = await http.post(
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
        Get.snackbar("Success", "Report Submitted Successfully", colorText: Colors.white, backgroundColor: Colors.green);
      } else {
        print("❌ API Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception submitting report: $e");
    }
  }

  // Report Question
  void reportQuestion(BuildContext context, String questionText, int questionId) {
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
                      Get.snackbar("Error", "Please enter a message",
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.black);
                      return;
                    }

                    /// Show Loading
                    Get.dialog(
                       Center(
                        child:LoadingAnimationWidget.newtonCradle (
                            color: Colors.redAccent,
                            size: 80.h),
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
          )
        ],
      ),
    ),

    isScrollControlled: true,
    enableDrag: true,
  );
}

  Future<void> submitTest(BuildContext? context) async {
  final reviewData = <Map<String, dynamic>>[]; 
  int attempted = 0;
  int totalMarks = 0;
  int obtainedMarks = 0;

  // Show loading dialog
  if (context != null) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: LoadingAnimationWidget.newtonCradle(
          color: Colors.red,
          size: 80,
        ),
      ),
    );
  }

  // Check connectivity
  final conn = await Connectivity().checkConnectivity();
  bool isOnline = conn != ConnectivityResult.none;

  // ✅ SUBMIT EACH ANSWER TO API
  for (var subject in allQuestions.keys) {
    final list = allQuestions[subject]!;
    
    for (var q in list) {
      final id = q['id'] as int;
      final ans = selectedAnswers[id];
      final studentAns = (ans != null && ans.toString().isNotEmpty) ? ans.toString() : "";
      final correct = q['correctKey']?.toString() ?? "";

      final int marks = (q['marks'] ?? 0) as int;
      totalMarks += marks;

      bool isCorrect = studentAns == correct;
      
      // ✅ Determine OptionStatus
      String optionStatus;
      if (studentAns.isEmpty) {
        optionStatus = "Not Attempted";
      } else if (isCorrect) {
        optionStatus = "Correct";
      } else {
        optionStatus = "Incorrect";
      }

      // Count attempted questions (exclude marked for review without answer)
      if (studentAns.isNotEmpty && !markedForReview.contains(id)) {
        attempted++;
      }

      if (isCorrect && studentAns.isNotEmpty) {
        obtainedMarks += marks;
      }

      // Prepare review data
      reviewData.add({
        'subject': subject,
        'question': q['question'],
        'studentAnswer': studentAns.isEmpty ? "—" : studentAns,
        'correctAnswer': correct,
        'isCorrect': isCorrect,
        'marks': marks,
      });

      // ✅ Submit to API (online or save offline)
      if (isOnline) {
        await submitquestion(
          studentidd.value,
          q['serverQuestionId'] ?? id,
          q['batchId'] ?? batchid.value,  // ✅ BatchId from question
          q['examTestId'] ?? examtestid.value,  // ✅ ExamTestId from question
          studentAns.isEmpty ? "" : studentAns,  // ✅ Empty string instead of "NotAttempted"
          correct,
          optionStatus,  // ✅ Pass "Not Attempted", "Correct", or "Incorrect"
          schoolId.value,
        );
      } else {
        // Save offline if no internet
        if (studentAns.isNotEmpty) {
          await _saveAnswerOffline(id, studentAns);
        }
      }
    }
  }

  // Calculate not attempted and reviewed
  final total = reviewData.length;
  final reviewed = markedForReview.length;
  final notAttempted = total - attempted - reviewed;

  // Close loading dialog
  if (context != null) Navigator.pop(context);

  // Show result screen
  Get.offAll(() => ResultScreen(
    total: total,
    attempted: attempted,
    reviewed: reviewed,
    notAttempted: notAttempted,
    totalMarks: totalMarks,
    obtainedMarks: obtainedMarks,
    questionReviewData: reviewData,
  ));

  // Show sync message if offline
  if (!isOnline) {
    Get.snackbar(
      "Offline Submission", 
      "Answers saved offline. Will sync when online.",
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }
}

// ===================================================
// SYNC OFFLINE ANSWERS TO SERVER
// ===================================================
Future<void> syncAnswersOnline() async {
  try {
    Box answerBox;
    if (Hive.isBoxOpen('offline_answers_${testId.value}')) {
      answerBox = Hive.box('offline_answers_${testId.value}');
    } else {
      answerBox = await Hive.openBox('offline_answers_${testId.value}');
    }

    if (answerBox.isEmpty) {
      print("✅ No offline answers to sync");
      return;
    }

    print("📤 Syncing ${answerBox.length} offline answers...");

    for (var key in answerBox.keys) {
      final qid = key as int;
      final ans = answerBox.get(qid);

      // Find the question details from allQuestions
      Map<String, dynamic>? questionData;
      for (var list in allQuestions.values) {
        questionData = list.firstWhere(
          (q) => q['id'] == qid,
          orElse: () => {},
        );
        if (questionData.isNotEmpty) break;
      }

      if (questionData == null || questionData.isEmpty) continue;

      final correctKey = questionData['correctKey']?.toString() ?? '';
      final isCorrect = ans == correctKey;

      await submitquestion(
          studentidd.value,
        questionData['serverQuestionId'] ?? qid,
        questionData['batchId'] ?? batchid.value,
        questionData['examTestId'] ?? examtestid.value,
        ans,
        correctKey,
        isCorrect ? "Correct" : "Not-Attempted",
        schoolId.value,
      );
    }

    // Clear offline answers after successful sync
    await answerBox.clear();
    print("✅ All offline answers synced and cleared");
  } catch (e) {
    print("❌ Error syncing offline answers: $e");
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
        'student_answer': selectedAnswers[id] ?? 'Not Attempted',
        'is_correct': selectedAnswers[id] == q['correct_option'],
        'is_marked_for_review': markedForReview.contains(id),
        'is_visited': visitedQuestions.contains(id),
      };
    }).toList(),
    'answers_summary': selectedAnswers.map((key, value) => MapEntry(key.toString(), value)),
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


void selectOption(int questionId, String optionKey) {
  selectedAnswers[questionId] = optionKey;
  visitedQuestions.add(questionId);
  update();
}}