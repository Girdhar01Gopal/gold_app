import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gold_app/Model/exammodel.dart';
import 'package:gold_app/appurl/adminurl.dart';
import 'package:gold_app/screens/submitscreenview%20copy.dart';
import 'package:http/http.dart' as http;


class Testscreencontroller extends GetxController {
  // 🔹 Reactive variables
  final subjects = <String>[].obs;
  final selectedSubject = ''.obs;

  var schoolId = ''.obs;
  var courseId = ''.obs;
  var testId = ''.obs;
  var passcode = ''.obs;

  final currentIndex = 0.obs;
  final selectedAnswers = <int, List<String>>{}.obs;
  final markedForReview = <int>{}.obs;
  final visitedQuestions = <int>{}.obs;
  final allQuestions = <String, List<Map<String, dynamic>>>{}.obs;

  @override
  void onInit() async {
    super.onInit();
   // courseId.value = await PrefManager().readValue(key: 'CourseId') ?? '';
   // schoolId.value = await PrefManager().readValue(key: 'SchoolId') ?? '';
  //  testId.value = Get.arguments['testId'] ?? '';
    //passcode.value = Get.arguments['passcode'] ?? '';

    await _loadQuestions();
  }

  // =======================================
  // 🔹 Fetch Questions
  // =======================================
  Future<void> _loadQuestions() async {
    final url =
        '${Adminurl.testurl}/8/69/86567583/8338525112';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'MobAppQuestionKey': 'bdui93Y-HLwxe8-11fehc-AyuK63-96yjc736',
        },
      );

      if (response.statusCode == 200) {
        final parsed = exammodel.fromJson(jsonDecode(response.body));
        allQuestions.clear();

        if (parsed.data != null) {
          for (var q in parsed.data!) {
            final subject = q.subjectName ?? 'General';
            allQuestions.putIfAbsent(subject, () => []);

            allQuestions[subject]!.add({
              'id': q.questionId ?? 0,
              'question': q.questions ?? '',
              'options': [
                q.ansOptionA ?? '',
                q.ansOptionB ?? '',
                q.ansOptionC ?? '',
                q.ansOptionD ?? '',
              ].where((opt) => opt.isNotEmpty).toList(),
              'correctOption': q.correctOptionText ?? '',
            });
          }

          subjects.value = allQuestions.keys.toList();
          selectedSubject.value = subjects.first;
          if (currentQuestions.isNotEmpty) {
            visitedQuestions.add(currentQuestions.first['id']);
          }
          allQuestions.refresh();
        } else {
          Get.snackbar("Error", "No questions found.");
        }
      } else {
        Get.snackbar(
          "Server Error ${response.statusCode}",
          "Unable to fetch questions.",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.black,
        );
      }
    } catch (e) {
      print("❌ Error fetching questions: $e");
      Get.snackbar(
        "Error",
        "Failed to load questions. Please try again later.",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }

  void toggleMultiSelect(int questionId, String option, bool selected) {
    final selectedList = List<String>.from(selectedAnswers[questionId] ?? <String>[]);
    if (selected) {
      if (!selectedList.contains(option)) selectedList.add(option);
    } else {
      selectedList.remove(option);
    }
    selectedAnswers[questionId] = selectedList;
    selectedAnswers.refresh();
  }

  // =======================================
  // 🔹 Current Questions Getter
  // =======================================
  List<Map<String, dynamic>> get currentQuestions =>
      allQuestions[selectedSubject.value] ?? [];

  // =======================================
  // 🔹 Answer Handling
  // =======================================
  void selectAnswer(String value) {
    final qId = currentQuestions[currentIndex.value]['id'];
    selectedAnswers[qId] = [value];
    selectedAnswers.refresh();
  }

  // =======================================
  // 🔹 Navigation
  // =======================================
  void nextQuestion(BuildContext context) {
    final total = currentQuestions.length;
    final subjectIndex = subjects.indexOf(selectedSubject.value);

    if (currentIndex.value < total - 1) {
      currentIndex.value++;
      visitedQuestions.add(currentQuestions[currentIndex.value]['id']);
    } else if (subjectIndex < subjects.length - 1) {
      final nextSubj = subjects[subjectIndex + 1];
      selectedSubject.value = nextSubj;
      currentIndex.value = 0;
      Get.snackbar("Next Subject", "Moved to $nextSubj",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      showSubmitDialog(context);
    }
  }

  void previousQuestion() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      visitedQuestions.add(currentQuestions[currentIndex.value]['id']);
    }
  }

  // =======================================
  // 🔹 Submit Test
  // =======================================
  void showSubmitDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: "Submit Test?",
      desc: "Are you sure you want to submit your answers?",
      btnOkText: "Submit",
      btnCancelText: "Review Again",
      btnCancelOnPress: () {},
      btnOkOnPress: () => submitTest(context),
    ).show();
  }

  void submitTest(BuildContext context) {
    final total = allQuestions.values.fold<int>(0, (a, b) => a + b.length);
    final attempted = selectedAnswers.length;
    final reviewed = markedForReview.length;
    final notAttempted = total - attempted;

    // Build review data
    final reviewData = <Map<String, dynamic>>[];
    allQuestions.forEach((subject, questions) {
      for (var q in questions) {
        final id = q['id'];
        final ansList = selectedAnswers[id];
        final studentAns = (ansList != null && ansList.isNotEmpty) ? ansList.join(', ') : '—';
        final correctAns = q['correctOption'] ?? '—';
        reviewData.add({
          'subject': subject,
          'question': q['question'],
          'studentAnswer': studentAns,
          'correctAnswer': correctAns,
          'isCorrect': studentAns == correctAns,
        });
      }
    });

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      Get.offAll(() => ResultScreen(
            total: total,
            attempted: attempted,
            reviewed: reviewed,
            notAttempted: notAttempted,
            questionReviewData: reviewData,
          ));
    });
  }

  // =======================================
  // 🔹 Mark / Report
  // =======================================
  void toggleMarkForReview() {
    final id = currentQuestions[currentIndex.value]['id'];
    if (markedForReview.contains(id)) {
      markedForReview.remove(id);
    } else {
      markedForReview.add(id);
    }
  }


  void reportQuestion(BuildContext context, String questionText, int questionId) {
    final TextEditingController reportController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                "Report Question",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                "Q. $questionText",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reportController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Describe your issue",
                  border: OutlineInputBorder(),
                  hintText: "Example: Wrong question or unclear option",
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey)),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton.icon(
                    icon:
                        const Icon(Icons.send, color: Colors.white, size: 18),
                    label: const Text("Submit",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      final message = reportController.text.trim();
                      if (message.isEmpty) {
                        Get.snackbar(
                          "Error",
                          "Please describe your issue",
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.black,
                        );
                        return;
                      }

                      Navigator.pop(context);
                      Get.snackbar(
                        "Reported",
                        "Your issue has been submitted.",
                        backgroundColor: Colors.green.shade100,
                        colorText: Colors.black,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }
}
