import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/usage_controller.dart';

class UsageScreen extends StatelessWidget {
  final UsageController controller = Get.find(); // Accessing the controller using Get.find()

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsive design
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF682D91), // Purple color
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false, // Disable default back button
        title: Row(
          children: [
            Text(
              '  Usage',
              style: TextStyle(fontSize: 20.sp, color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close action: Navigate back or close screen
              Get.back();
            },
            child: Text(
              'Close',
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w), // Use ScreenUtil for padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usage Details',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              Text(
                'This section provides details on the usage of the application, including resources, usage stats, and more. The app tracks your usage for various features, ensuring that you have an optimized experience. For better performance, try using it within optimal usage limits.',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
