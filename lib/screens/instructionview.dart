import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:gold_app/controllers/instructioncontroller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Instructionview extends GetView<Instructioncontroller> {
  const Instructionview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   // final controller = Get.put(Instructioncontroller());
  //  controller.fetchInstructions(); // Fetch instructions on view load
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        leading: controller.testid.value == "test"
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              )
            : null,
        centerTitle: true,
        title: const Text('Instructions',style: TextStyle(color: Colors.white),),
        backgroundColor: isDarkMode ? Colors.grey[850] : const Color(0xFF8B2D28),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Get.isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
        //       color: Colors.white,
        //     ),
        //     onPressed: () {
        //       Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
        //     },
        //   ),
        // ],
      ),
      body: Obx(() {
        // Check if data is loading
        if (controller.isLoading.value) {
          return Center(
            child: LoadingAnimationWidget.newtonCradle(
              color: isDarkMode ? Colors.grey[400]! : const Color(0xFF8B2D28),
              size: 80.h,
            ),
          );
        }

        // Check if instructions are available
        if (controller.instructions.isEmpty) {
          return Center(
            child: Text(
              'No instructions available.',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey[300] : Colors.black,
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: controller.instructions.length,
                  itemBuilder: (context, index) {
                    final instruction = controller.instructions[index];

                    return Card(
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      elevation: isDarkMode ? 2 : 5,
                      margin: EdgeInsets.symmetric(vertical: 6.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        side: BorderSide(
                          color: isDarkMode ? Colors.grey[700]! : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(6.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              instruction.subjectName ?? "No Subject",
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.grey[300] : const Color(0xFF8B2D28),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              instruction.examInstruction ?? "No instructions provided.",
                              style: TextStyle(
                                fontSize: 7.sp,
                                fontWeight: FontWeight.w400,
                                color: isDarkMode ? Colors.grey[300] : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Test ID: ${instruction.testId ?? 'N/A'}",
                                  style: TextStyle(
                                    fontSize: 6.sp,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 8.h),
              if (controller.testid.value == "test")
                ElevatedButton(
                  onPressed: controller.voidtest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B2D28),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Text(
                    "Start Test",
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              
  ],
          ),
        );
      }),
    );
  }
}
