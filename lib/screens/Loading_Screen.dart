import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../controllers/Loading_Controller.dart';
import '../utils/constants/color_constants.dart'; // Your color definitions

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(LoadingController());

    return Scaffold(
      backgroundColor: AppColor.White,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFEB8A2A), // warm orange
                Color(0xFFFFC46B), // soft golden tint
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              Image.asset(
                'assets/images/FIITJEE_Logo.png',
                height: 160.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 40.h),

              // Title Text
              Text(
                "Maharishi Learn",
                style: TextStyle(
                  fontSize: 28.sp,  // Increased font size for better visibility
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0, // Enhanced letter spacing
                ),
              ),
              SizedBox(height: 12.h),  // Adjusted spacing

              // Loading Text
              Text(
                "Loading, please wait...",
                style: TextStyle(
                  fontSize: 16.sp,  // Slightly increased font size
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w500,  // Slightly bolder text
                ),
              ),
              SizedBox(height: 40.h),

              // Circular Progress Indicator
              SizedBox(
                height: 30.h,  // Increased size for better emphasis
                width: 30.h,  // Increased size for better emphasis
                child:  LoadingAnimationWidget.fourRotatingDots(
        color: Colors.white,
        size: 120,
      ),
              ),

              SizedBox(height: 60.h),  // Adjusted spacing for footer section

              // Footer Text
              Text(
                "© MGEPL",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),  // Slightly reduced opacity for a subtle effect
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
