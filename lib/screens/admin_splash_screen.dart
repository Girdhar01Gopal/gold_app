import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/admin_splash_controller.dart';

class AdminSplashScreen extends StatelessWidget {
  const AdminSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AdminSplashController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ensures the image is centered vertically and horizontally
              Image.asset(
                'assets/images/FIITJEE_Logo.png',  // Corrected image path
                height: 250.h,
              ),
              SizedBox(height: 20.h),  // Optional: Add space below the logo if needed
            ],
          ),
        ),
      ),
    );
  }
}
