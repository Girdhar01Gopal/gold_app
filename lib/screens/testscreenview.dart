import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gold_app/utils/constants/color_constants.dart';
import '../controllers/testscreencontroller.dart';

class Testscreenview extends GetView<Testscreencontroller> {
  const Testscreenview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(Testscreencontroller());
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 3,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.MAHARISHI_GOLD, AppColor.MAHARISHI_AMBER, AppColor.MAHARISHI_BRONZE],
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
      ),

      body: SafeArea(
        child: Obx(() {
          final currentQuestions = controller.currentQuestions;
          if (currentQuestions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ Safety check for index overflow
          if (controller.currentIndex.value >= currentQuestions.length) {
            controller.currentIndex.value = 0;
          }

          final question = currentQuestions[controller.currentIndex.value];

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Subject Tabs
                Center(
                  child: Obx(() => Wrap(
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
                            // ✅ Reset question index when subject changes
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectedSubject.value = subject;
                                controller.currentIndex.value = 0;
                              }
                            },
                          );
                        }).toList(),
                      )),
                ),
                SizedBox(height: 20.h),

                // 🔹 Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Q${controller.currentIndex.value + 1} / ${currentQuestions.length}",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColor.MAHARISHI_BRONZE,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        controller.selectedSubject.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Divider(color: Colors.grey.shade300),

                // 🔹 Question Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      question['question'],
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // 🔹 Options
                ...List.generate(question['options'].length, (index) {
                  final option = question['options'][index];
                  final selectedList =
                      controller.selectedAnswers[question['id']] ?? <String>[];
                  final isSelected = selectedList.contains(option);

                  return GestureDetector(
                    onTap: () => controller.toggleMultiSelect(
                        question['id'], option, !isSelected),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.symmetric(vertical: 6.h),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                              option,
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

                SizedBox(height: 25.h),

                // 🔹 Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => controller.reportQuestion(
                        context,
                        question['question'],
                        question['id'],
                      ),
                      icon: const Icon(Icons.report_problem_outlined,
                          color: Colors.red),
                      label: const Text(
                        "Report",
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    Obx(() {
                      final marked = controller.markedForReview
                          .contains(question['id']);
                      return OutlinedButton.icon(
                        icon: Icon(
                          marked ? Icons.flag : Icons.outlined_flag,
                          color: marked ? Colors.purple : Colors.grey.shade700,
                        ),
                        label: Text(
                          marked ? "Unmark" : "Mark Review",
                          style: TextStyle(
                            color: marked ? Colors.purple : Colors.grey.shade800,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: marked
                                  ? Colors.purple
                                  : Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: controller.toggleMarkForReview,
                      );
                    }),
                  ],
                ),
                SizedBox(height: 25.h),

                // 🔹 Navigation Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: Colors.white),
                      label: const Text("Previous",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 22.w, vertical: 10.h),
                      ),
                      onPressed: controller.previousQuestion,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward_ios,
                          size: 18, color: Colors.white),
                      label: const Text("Next",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.MAHARISHI_BRONZE,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 22.w, vertical: 10.h),
                      ),
                      onPressed: () => controller.nextQuestion(context),
                    ),
                  ],
                ),
                SizedBox(height: 25.h),

                // 🔹 Submit Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.showSubmitDialog(context),
                    icon: const Icon(Icons.check_circle_outline,
                        color: Colors.white),
                    label: const Text(
                      "Submit Test",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(230.w, 48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),

                // 🔹 Question Palette
                const Divider(thickness: 1.2),
                Text(
                  "Question Palette",
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.MAHARISHI_BRONZE,
                    ),
                ),
                SizedBox(height: 10.h),

                Obx(() {
                  final questions = controller.currentQuestions;
                  return Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    alignment: WrapAlignment.center,
                    children: questions.map((q) {
                      final id = q['id'];
                      final answered = controller.selectedAnswers.containsKey(id);
                      final marked =
                          controller.markedForReview.contains(id);
                      final visited =
                          controller.visitedQuestions.contains(id);

                      Color color;
                      if (marked) {
                        color = Colors.purple;
                      } else if (answered) {
                        color = Colors.green;
                      } else if (visited && !answered) {
                        color = Colors.red;
                      } else if (visited) {
                        color = Colors.orange;
                      } else {
                        color = Colors.grey;
                      }

                      return GestureDetector(
                        onTap: () {
                          controller.currentIndex.value =
                              questions.indexOf(q);
                          controller.visitedQuestions.add(id);
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: color,
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
                  );
                }),
                SizedBox(height: 25.h),
              ],
            ),
          );
        }),
      ),
    );
  }
}
