// controllers/testscreencontroller.dart
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gold_app/screens/submitscreenview.dart';

class Testscreencontroller extends GetxController {
  // 🔹 Subjects
  final subjects = ['Physics', 'Chemistry', 'Mathematics'].obs;
  final selectedSubject = 'Physics'.obs;

  // 🔹 Current Question Index
  final currentIndex = 0.obs;

  // 🔹 Answer Tracking
  // Supports both single and multiple answers
  final selectedAnswers = <int, dynamic>{}.obs;

  // 🔹 Question States
  final markedForReview = <int>{}.obs;
  final visitedQuestions = <int>{}.obs;

  // 🔹 All Questions Data
  final allQuestions = <String, List<Map<String, dynamic>>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDemoQuestions();
  }

  // =======================================
  // 🔹 DEMO QUESTIONS
  // =======================================
  void _loadDemoQuestions() {
    allQuestions['Physics'] = [
      {
        'id': 1,
        'question': 'What is Newton’s 2nd Law?',
        'options': ['F=ma', 'E=mc²', 'V=IR', 'P=IV'],
      },
      {
        'id': 2,
        'question': 'Select all scalar quantities:',
        'options': ['Speed', 'Force', 'Mass', 'Momentum'],
      },
    ];

    allQuestions['Chemistry'] = [
      {
        'id': 3,
        'question': 'Atomic number of Oxygen?',
        'options': ['6', '7', '8', '9'],
      },
      {
        'id': 4,
        'question': 'Which of the following are diatomic molecules?',
        'options': ['H₂', 'O₂', 'CO₂', 'N₂'],
     
      },
    ];

    allQuestions['Mathematics'] = [
      {
        'id': 5,
        'question': 'Derivative of sinx?',
        'options': ['cosx', '-cosx', '-sinx', 'tanx'],
      },
      {
        'id': 6,
        'question': 'Which are trigonometric identities?',
        'options': ['sin²x + cos²x = 1', 'tanx = sinx/cosx', 'a² + b² = c²', 'cotx = 1/tanx'],
      },
    ];
  }

  List<Map<String, dynamic>> get currentQuestions =>
      allQuestions[selectedSubject.value] ?? [];

  // =======================================
  // 🔹 ANSWER SELECTION HANDLERS
  // =======================================

  /// For single-choice questions
  void selectAnswer(String value) {
    final qId = currentQuestions[currentIndex.value]['id'];
    selectedAnswers[qId] = value;
    selectedAnswers.refresh();
  }

  /// For multiple-choice questions
  void toggleMultiSelect(int questionId, String option, bool selected) {
    final selectedList = List<String>.from(selectedAnswers[questionId] ?? []);

    if (selected) {
      if (!selectedList.contains(option)) selectedList.add(option);
    } else {
      selectedList.remove(option);
    }

    selectedAnswers[questionId] = selectedList;
    selectedAnswers.refresh();
  }

  // =======================================
  // 🔹 NAVIGATION
  // =======================================
  void nextQuestion() {
    if (currentIndex.value < currentQuestions.length - 1) {
      currentIndex.value++;
      visitedQuestions.add(currentQuestions[currentIndex.value]['id']);
    } else {
      AwesomeDialog(
        context: Get.context!,
        dialogType: DialogType.info,
        animType: AnimType.bottomSlide,
        title: 'End of Questions',
        desc:
            'You have reached the end of the questions. Please submit your test.',
        btnOkText: 'OK',
        btnOkOnPress: () {},
      ).show();
    }
  }

  void previousQuestion() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      visitedQuestions.add(currentQuestions[currentIndex.value]['id']);
    }
  }

  void toggleMarkForReview() {
    final id = currentQuestions[currentIndex.value]['id'];
    markedForReview.contains(id)
        ? markedForReview.remove(id)
        : markedForReview.add(id);
  }

  void changeSubject(String subject) {
    selectedSubject.value = subject;
    currentIndex.value = 0;
  }

  // =======================================
  // 🔹 SUBMIT TEST
void submitTest(BuildContext context) {
  final total = allQuestions.values.fold<int>(0, (a, b) => a + b.length);
  final attempted = selectedAnswers.length;
  final reviewed = markedForReview.length;
  final notAttempted = total - attempted;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
           
          ],
        ),
      ),
    ),
  );

  Future.delayed(const Duration(seconds: 4), () {
    Navigator.pop(context);
    Get.offAll(() => ResultScreen(
          total: total,
          attempted: attempted,
          reviewed: reviewed,
          notAttempted: notAttempted,
        ));
  });
}

  // =======================================
  // 🔹 REPORT QUESTION (Bottom Sheet)
  // =======================================
  void reportQuestion(
      BuildContext context, String questionText, int questionId) {
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  color: Colors.black87,
                ),
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
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    label: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
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

                      // 🔹 Optional: Store in DB or send API
                      // saveReport(questionId, message);
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
