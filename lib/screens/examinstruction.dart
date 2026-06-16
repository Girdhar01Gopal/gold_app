import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gold_app/controllers/ContinueScreenController.dart';
import 'package:gold_app/controllers/examinstructioncontroller.dart';
import 'package:gold_app/infrastructure/routes/admin_routes.dart';
import 'package:gold_app/screens/ContinueScreen.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class examinstructionview extends GetView<examinstructioncontroller> {
  const examinstructionview({Key? key}) : super(key: key);

  static const Color _primary = Color(0xFFA10D52);
  static const Color _accent  = Color(0xFF4CA1AF);

  @override
  Widget build(BuildContext context) {
    Future<void> openAssignment(dynamic assignment) async {
      final selectedMode = await Get.dialog<String>(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Set the time limit to solve this assignment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ContinueScreenController.questionModeOptions
                .map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: option.value),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: option.color ?? ColorPainter.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(option.label,
                            style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
                onPressed: () => Get.back(), child: const Text('Cancel')),
          ],
        ),
        barrierDismissible: false,
      );

      if (selectedMode == null) return;

      controller.voidtest(selectedMode);
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: controller.testid.value == "test"
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Get.back(),
              )
            : null,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? null
                : const LinearGradient(
                    colors: [_primary, _accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isDarkMode ? const Color(0xFF1A1F2E) : null,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(22),
            ),
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Instructions',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Text(
              'Read carefully before starting',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: LoadingAnimationWidget.newtonCradle(
              color: _primary,
              size: 80.h,
            ),
          );
        }

        if (controller.instructions.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 48, color: _primary.withValues(alpha: 0.5)),
                SizedBox(height: 12.h),
                Text(
                  'No instructions available.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[400] : Colors.black54,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                itemCount: controller.instructions.length,
                itemBuilder: (context, index) {
                  final instruction = controller.instructions[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1A1F2E) : Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border(
                        left: BorderSide(
                          color: index.isEven ? _primary : _accent,
                          width: 4,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(14.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_primary, _accent],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  instruction.subjectName ?? "Subject",
                                  style: TextStyle(
                                    fontSize: 6.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (instruction.testId != null)
                                Text(
                                  "ID: ${instruction.testId}",
                                  style: TextStyle(
                                    fontSize: 5.sp,
                                    color: isDarkMode ? Colors.grey[500] : Colors.grey.shade400,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            instruction.examInstruction ?? "No instructions provided.",
                            style: TextStyle(
                              fontSize: 7.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              color: isDarkMode ? Colors.grey[300] : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Start button
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 20.h),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1A1F2E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: controller.instructions.isNotEmpty
                    ? () => openAssignment(controller.instructions[0])
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: controller.instructions.isNotEmpty
                        ? const LinearGradient(
                            colors: [_primary, _accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: controller.instructions.isEmpty
                        ? Colors.grey.shade300
                        : null,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: _primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_circle_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Start Assignment",
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
