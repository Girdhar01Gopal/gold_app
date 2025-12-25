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

    // Check if dark mode is enabled
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : AppColor.White, // Dark mode background color
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Color(0xFF121212), Color(0xFF1D1D1D)] // Dark background gradient
                : [Color(0xFF0D47A1), Color(0xFF4CA1AF)], // Original gradient for light mode
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
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black, // Text color for dark mode
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 12.h), 

            // Loading Text
            Text(
              "Loading, please wait...",
              style: TextStyle(
                fontSize: 16.sp,
                color: isDarkMode ? Colors.white.withOpacity(0.85) : Colors.black.withOpacity(0.85), // Adjust text color for dark mode
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 40.h),

            // Circular Progress Indicator
            SizedBox(
              height: 10.h,
              width: 10.h,
              child: LoadingAnimationWidget.fourRotatingDots(
                color: isDarkMode ? Colors.white : Colors.black, // Color for the loading animation
                size: 120,
              ),
            ),

            SizedBox(height: 60.h), 

            // Footer Text
            Text(
              "© MGEPL",
              style: TextStyle(
                color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
