// screens/testscreenview.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/testscreencontroller.dart';

class Testscreenview extends GetView<Testscreencontroller> {
  const Testscreenview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(Testscreencontroller());

    ScreenUtil.init(context,
        designSize: const Size(375, 812), minTextAdapt: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B1313),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Assignment Test',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      // ===============================
      // 🔹 MAIN TWO-PANE BODY
      // ===============================
      body: SafeArea(
        child: Obx(() {
          final currentQuestions = controller.currentQuestions;
          if (currentQuestions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final question =
              currentQuestions[controller.currentIndex.value];
          final currentAnswer =
              controller.selectedAnswers[question['id']] ?? '';

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 LEFT SIDE — QUESTIONS (70%)
              Expanded(
                flex: 7,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject Tabs
                      Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: controller.subjects.map((subject) {
                              final isSelected = controller
                                      .selectedSubject.value ==
                                  subject;
                              return Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 6.w),
                                child: ChoiceChip(
                                  checkmarkColor: Colors.white,
                                  label: Text(subject),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF9B1313),
                                  backgroundColor: Colors.grey.shade200,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onSelected: (_) =>
                                      controller.changeSubject(subject),
                                ),
                              );
                            }).toList(),
                          )),
                      const SizedBox(height: 10),
                      Text(
                        "Question ${controller.currentIndex.value + 1}/${currentQuestions.length}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Divider(),
                      // Question Box
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          question['question'],
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    // 🔹 Multiple Choice Options
...List.generate(question['options'].length, (index) {
  final option = question['options'][index];
  // Maintain a list of selected options for this question
  final selectedList =
      controller.selectedAnswers[question['id']] ?? <String>[];
  final isSelected = selectedList.contains(option);
  return Card(
    elevation: 1,
    margin: EdgeInsets.symmetric(vertical: 4.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading, // ✅ Checkbox first
      title: Text(
        option,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      value: isSelected,
      activeColor: const Color(0xFF9B1313),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onChanged: (bool? value) {
        controller.toggleMultiSelect(
          question['id'],
          option,
          value ?? false,
        );
      },
    ),
  );
}),
 SizedBox(height: 15.h),
SizedBox(height: 10.h),
// 🔹 Report Button
Align(
  alignment: Alignment.centerRight,
  child: ElevatedButton.icon(
    onPressed: () => controller.reportQuestion(
      context,
      question['question'],
      question['id'],
    ),
    icon: const Icon(Icons.report_gmailerrorred, color: Colors.white),
    label: const Text(
      "Report Issue",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red, // Button color
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
    ),
  ),
),
SizedBox(height: 20.h),
                      // Mark for Review
                      Align(
                        alignment: Alignment.centerRight,
                        child: Obx(() {
                          final currentQuestionId =
                              question['id'];
                          final isMarked = controller.markedForReview
                              .contains(currentQuestionId);

                          return OutlinedButton.icon(
                            icon: Icon(
                              isMarked
                                  ? Icons.flag_outlined
                                  : Icons.flag,
                              color: isMarked
                                  ? Colors.red
                                  : Colors.purple,
                            ),
                            label: Text(
                              isMarked
                                  ? "Unmark Review"
                                  : "Mark for Review",
                              style: TextStyle(
                                  color: isMarked
                                      ? Colors.red
                                      : Color(0xFF4a4a4a)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: isMarked
                                      ? Colors.red
                                      : Color(0xFF4a4a4a)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: controller.toggleMarkForReview,
                          );
                        }),
                      ),
                      SizedBox(height: 20.h),
                      // Navigation Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            label: const Text("Previous",
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 22.w, vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: controller.previousQuestion,
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward,
                                color: Colors.white),
                            label: const Text("Next",
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9B1313),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 22.w, vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: controller.nextQuestion,
                          ),
                        ],
                      ),
                      SizedBox(height: 25.h),
                      // Submit Button
                      Center(
                        child: SizedBox(
                          height: 100.h,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                controller.submitTest(context),
                            icon: const Icon(Icons.check_circle_outline,
                                color: Colors.white),
                            label: const Text("Submit Test",
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: Size(200.w, 45.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 🔹 RIGHT SIDE — QUESTION PALETTE (30%)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.grey.shade100,
                      border: Border(
                        left: BorderSide(
                            color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    child: Obx(() {
                      final subjectQuestions = controller.currentQuestions;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Legend (2 per row)
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _legendItem("Answered", Colors.green),
                                  _legendItem("Marked", Colors.purple),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _legendItem("Visited", Colors.orange),
                                  _legendItem("Not Visited", Colors.grey),
                                ],
                              ),
                            ],
                          ),
                          const Divider(),
                          Text(
                            "${controller.selectedSubject.value} Palette",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF8B2D28),
                              fontSize: 10.sp,
                            ),
                          ),
                          const Divider(),
                          // Palette Grid
                          Expanded(
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: subjectQuestions.map((q) {
                                  final id = q['id'];
                                  final isAnswered = controller
                                      .selectedAnswers
                                      .containsKey(id);
                                  final isMarked = controller
                                      .markedForReview
                                      .contains(id);
                                  final isVisited = controller
                                      .visitedQuestions
                                      .contains(id);
                                  Color color;
                                  if (isMarked) {
                                    color = Colors.purple;
                                  } else if (isAnswered) {
                                    color = Colors.green;
                                  } else if (isVisited) {
                                    color = Colors.orange;
                                  } else {
                                    color = Colors.grey;
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      controller.currentIndex.value =
                                          subjectQuestions.indexOf(q);
                                      controller.visitedQuestions.add(id);
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: color,
                                      radius: 16,
                                      child: Text(
                                        id.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
  // 🔹 Legend Helper
  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        SizedBox(width: 3.w),
        Text(
          label,
          style: TextStyle(fontSize: 7.sp, color: Colors.black87),
        ),
      ],
    );
  }
}
