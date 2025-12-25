import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/admin_splash_controller.dart';

class AdminSplashScreen extends StatelessWidget {
  const AdminSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AdminSplashController());

    // Get the current theme brightness
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white, // Adjust background based on theme
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
              // You can add a text to indicate which theme is active for debugging purposes
              // if (isDarkMode)
              //   Text(
              //     'Dark Mode',
              //     style: TextStyle(color: Colors.white, fontSize: 18.sp),
              //   )
              // else
              //   Text(
              //     'Light Mode',
              //     style: TextStyle(color: Colors.black, fontSize: 18.sp),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
