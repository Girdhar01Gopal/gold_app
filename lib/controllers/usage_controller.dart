import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gold_app/controllers/logincontroller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ScreenUtilInit(
      builder: (context, child) {
        return Scaffold(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          body: Stack(
            children: [
              /// ---------- Curved Header Background ----------
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 300.h),
                painter: GradientCurvePainter(isDarkMode),
              ),

              /// ---------- Main Content ----------
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 60.h),

                      /// ---------- Logo ----------
                      Container(
                        height: 100.h,
                        width: 100.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5.h),
                          child: Image.asset(
                            'assets/images/FIITJEE_Logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      SizedBox(height: 75.h),

                      /// ---------- Title ----------
                      Text(
                        "Welcome to Maharishi Learn",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : const Color(0xFF2B2B2B),
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Your digital learning companion",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.grey[700],
                          fontSize: 14.sp,
                        ),
                      ),

                      SizedBox(height: 30.h),

                      /// ---------- Login Card (Glass Style) ----------
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.7)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(25.r),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.4)
                                : Color(0xFF0D47A1).withOpacity(0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Login to Continue",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : Color(0xFF0D47A1),
                              ),
                            ),
                            SizedBox(height: 25.h),

                            /// ---------- Input ----------
                        TextField(
  controller: controller.passwordController,
  decoration: InputDecoration(
    hintText: "Enter Enrollment Number",
    prefixIcon: const Icon(
      CupertinoIcons.number_circle,
      color: Colors.black54,
    ),
    filled: true,
    fillColor: isDarkMode ? Colors.white : Colors.white,
    contentPadding: EdgeInsets.symmetric(
      vertical: 15.h,
      horizontal: 18.w,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: isDarkMode ? Colors.white : Color(0xFF0D47A1),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: isDarkMode ? Colors.white : Color(0xFF0D47A1),
        width: 1.5,
      ),
    ),
  ),
  style: TextStyle(
    color: isDarkMode ? Colors.black : Colors.black,  // Adjusting text color
  ),
),
 SizedBox(height: 30.h),

                            /// ---------- Continue Button ----------
                            Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () => controller.login(enrollmentNo: controller.passwordController.text.trim()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode
                                      ? Colors.grey.shade800
                                      : Color(0xFF0D47A1),
                                  minimumSize: Size(double.infinity, 52.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  elevation: 3,
                                ),
                                child: controller.isLoading.value
                                    ? LoadingAnimationWidget.fourRotatingDots(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Color(0xFF0D47A1),
                                        size: 50,
                                      )
                                    : Text(
                                        "Continue",
                                        style: TextStyle(
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.white : Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 50.h),

                      /// ---------- Footer ----------
                      Text(
                        "© MGEPL",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.grey[700],
                          fontSize: 13.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ---------- Premium Curved Gold Background with Icon ----------
class GradientCurvePainter extends CustomPainter {
  final bool isDarkMode;

  GradientCurvePainter(this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    // ---------- Curve Shape ----------
    final path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.55,
      size.width * 0.5,
      size.height * 0.68,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width,
      size.height * 0.55,
    );
    path.lineTo(size.width, 0);
    path.close();

    // ---------- Gradient ----------
    final gradient = LinearGradient(
      colors: [
        isDarkMode ? Colors.black : Color(0xFF0D47A1), 
        isDarkMode ? Colors.grey.shade700 : Color(0xFF4CA1AF),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    // Draw gradient shape
    canvas.drawPath(path, paint);

    // ---------- Add Icon with Opacity ----------
    const icon = Icons.school; // You can change to any icon you prefer
    const iconSize = 120.0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white.withOpacity(0.30), // subtle opacity
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Position icon at bottom-right inside the design
    final offset = Offset(
      size.width - iconSize - 1,
      size.height * 0.1,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
