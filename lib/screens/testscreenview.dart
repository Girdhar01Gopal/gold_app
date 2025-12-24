import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gold_app/utils/constants/color_constants.dart';
import '../controllers/testscreencontroller.dart';

class Testscreenview extends GetView<Testscreencontroller> {
  const Testscreenview({super.key});

  // ✅ Safe converters (kills the "double is not a subtype of int" crash)
  int asInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  String asString(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ DO NOT create controller in build
    final controller = Get.find<Testscreencontroller>();

    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 3,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.MAHARISHI_GOLD,
                AppColor.MAHARISHI_AMBER,
                AppColor.MAHARISHI_BRONZE,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Maharishi Learn Assignment",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Obx(() {
              final isLowTime = controller.remainingSeconds.value < 300;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isLowTime
                      ? Colors.red.shade700
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      controller.formattedTime,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final currentQuestions = controller.currentQuestions;

          if (currentQuestions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.currentIndex.value >= currentQuestions.length) {
            controller.currentIndex.value = 0;
          }

          final question = currentQuestions[controller.currentIndex.value];

          // ✅ NO hard casts
          final int qid = asInt(question['id']);
          final String qText = asString(question['question']);
          final int rating = asInt(question['rating']);
          final List options = (question['options'] ?? []) as List;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Subject Tabs
                Center(
                  child: Obx(
                    () => Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      alignment: WrapAlignment.center,
                      children: controller.subjects.map((subject) {
                        final isSelected =
                            controller.selectedSubject.value == subject;
                        return ChoiceChip(
                          checkmarkColor: Colors.white,
                          label: Text(
                            subject,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColor.MAHARISHI_BRONZE,
                          backgroundColor: Colors.white,
                          elevation: 2,
                          pressElevation: 4,
                          side: BorderSide(
                            color: isSelected
                                ? AppColor.MAHARISHI_BRONZE
                                : Colors.grey.shade300,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              controller.selectedSubject.value = subject;
                              controller.currentIndex.value = 0;
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // 🔹 Question Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColor.MAHARISHI_GOLD.withOpacity(0.8),
                                  AppColor.MAHARISHI_AMBER,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.quiz_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Question ${controller.currentIndex.value + 1}",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  "${currentQuestions.length} Total Questions",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.MAHARISHI_BRONZE.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              controller.selectedSubject.value,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColor.MAHARISHI_BRONZE,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // ⭐ Rating
                      Row(
                        children: [
                          Text(
                            'Difficulty: ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          ...List.generate(5, (i) {
                            return Icon(
                              i < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber.shade600,
                              size: 16,
                            );
                          }),
                        ],
                      ),

                      SizedBox(height: 16.h),
                      Divider(color: Colors.grey.shade200, height: 1),
                      SizedBox(height: 16.h),

                      Text(
                        qText.isEmpty ? "No question text" : qText,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // ✅ OPTIONS (single select)
                ...List.generate(options.length, (index) {
                  final opt = options[index] as Map;
                  final String key = asString(opt['key']);
                  final String text = asString(opt['text']);

                  final selected = controller.selectedAnswers[qid];
                  final bool isSelected = selected == key;

                  return GestureDetector(
                    onTap: () => controller.selectOption(qid, key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.symmetric(vertical: 6.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.MAHARISHI_AMBER.withOpacity(0.12)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColor.MAHARISHI_BRONZE
                              : Colors.grey.shade300,
                          width: 1.2,
                        ),
                        boxShadow: [
                          if (isSelected)
                            const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: isSelected
                                ? AppColor.MAHARISHI_BRONZE
                                : Colors.grey,
                            size: 20,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              ' $text',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                SizedBox(height: 20.h),

                // 🔹 Action Buttons
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              controller.reportQuestion(context, qText, qid),
                          icon: Icon(
                            Icons.report_problem_outlined,
                            color: Colors.red.shade600,
                            size: 18,
                          ),
                          label: Text(
                            "Report",
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Obx(() {
                          final marked = controller.markedForReview.contains(
                            qid,
                          );
                          return OutlinedButton.icon(
                            icon: Icon(
                              marked ? Icons.flag : Icons.outlined_flag,
                              color: marked
                                  ? Colors.purple.shade600
                                  : Colors.grey.shade600,
                              size: 18,
                            ),
                            label: Text(
                              marked ? "Unmark" : "Mark",
                              style: TextStyle(
                                color: marked
                                    ? Colors.purple.shade600
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                            onPressed: controller.toggleMarkForReview,
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // 🔹 Navigation Buttons
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 16.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Previous Button
                      if (controller.currentIndex.value > 0)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (controller.currentIndex.value > 0) {
                                controller.currentIndex.value--;
                              }
                            },
                            icon: const Icon(Icons.arrow_back, size: 18),
                            label: Text(
                              "Previous",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: Colors.grey.shade800,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                      if (controller.currentIndex.value > 0)
                        SizedBox(width: 12.w),

                      // Next or Submit Button
                      Expanded(
                        child: Obx(() {
                          final isLastQuestion =
                              controller.currentIndex.value >=
                              currentQuestions.length - 1;
                          final isLastSubject =
                              controller.subjects.indexOf(
                                controller.selectedSubject.value,
                              ) >=
                              controller.subjects.length - 1;

                          final showSubmit = isLastQuestion && isLastSubject;

                          return ElevatedButton.icon(
                            onPressed: () async {
                              // Upload current answer before moving to next
                              await controller.uploadCurrentQuestionAnswer();

                              if (showSubmit) {
                                controller.submitTest(context);
                              } else {
                                if (controller.currentIndex.value <
                                    currentQuestions.length - 1) {
                                  controller.currentIndex.value++;
                                } else {
                                  // Move to next subject
                                  final currentSubjectIndex = controller
                                      .subjects
                                      .indexOf(
                                        controller.selectedSubject.value,
                                      );
                                  if (currentSubjectIndex <
                                      controller.subjects.length - 1) {
                                    controller.selectedSubject.value =
                                        controller
                                            .subjects[currentSubjectIndex + 1];
                                    controller.currentIndex.value = 0;
                                  }
                                }
                              }
                            },
                            icon: Icon(
                              showSubmit
                                  ? Icons.check_circle
                                  : Icons.arrow_forward,
                              size: 18,
                            ),
                            label: Text(
                              showSubmit ? "Submit Test" : "Next",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: showSubmit
                                  ? Colors.green.shade600
                                  : AppColor.MAHARISHI_BRONZE,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // ✅ PALETTE
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.grid_view_rounded,
                            color: AppColor.MAHARISHI_BRONZE,
                            size: 20,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "Question Palette",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Divider(color: Colors.grey.shade200, height: 1),
                      SizedBox(height: 12.h),
                      Obx(() {
                        final questions = controller.currentQuestions;

                        return Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          alignment: WrapAlignment.center,
                          children: List.generate(questions.length, (qIndex) {
                            final q = questions[qIndex];
                            final id = asInt(q['id']);

                            final answered =
                                controller.selectedAnswers[id] != null &&
                                controller.selectedAnswers[id]
                                    .toString()
                                    .isNotEmpty;

                            final marked = controller.markedForReview.contains(
                              id,
                            );
                            final visited = controller.visitedQuestions
                                .contains(id);

                            Color color;
                            if (marked) {
                              color = Colors.purple;
                            } else if (answered) {
                              color = Colors.green;
                            } else if (visited) {
                              color = Colors.red;
                            } else {
                              color = Colors.grey;
                            }

                            return GestureDetector(
                              onTap: () {
                                controller.currentIndex.value = qIndex;
                                controller.visitedQuestions.add(id);
                              },
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: color,
                                child: Text(
                                  '${qIndex + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                SizedBox(height: 20.h),
              ],
            ),
          );
        }),
      ),
    );
  }
}
