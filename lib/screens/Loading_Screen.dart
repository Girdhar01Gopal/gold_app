// screens/Loading_Screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/Loading_Controller.dart';
import '../utils/constants/color_constants.dart'; // Add your color definitions

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize LoadingController
    Get.put(LoadingController());

    return Scaffold(
      backgroundColor: AppColor.White,
      body: SafeArea(
        child: Center(
          child: Row(
            children: [
              // Left Section (Purple background and loading text/logo)
              Container(
                width: 150.w, // Adjust based on your design
                color: Color(0xFF9B1313), // Adjust to your color
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/FIITJEE_Logo.png', // Correct image path
                        height: 300.h, // Adjust image size
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right Section (White background and Circular Loading Indicator)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF9B1313), // Adjust color as needed
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
