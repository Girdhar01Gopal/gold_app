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
          body: OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.landscape) {
                return _buildLandscape(context, controller, isDarkMode);
              }
              return _buildPortrait(context, controller, isDarkMode);
            },
          ),
        );
      },
    );
  }

  Widget _buildLandscape(
    BuildContext context,
    LoginController controller,
    bool isDarkMode,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDarkMode ? Colors.black : const Color(0xFFA10D52),
                  isDarkMode ? Colors.grey.shade800 : const Color(0xFF1565C0),
                  isDarkMode ? Colors.grey.shade700 : const Color(0xFF4CA1AF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -60,
                  left: -60,
                  child: _circle(210, Colors.white.withOpacity(0.05)),
                ),
                Positioned(
                  bottom: -80,
                  right: -50,
                  child: _circle(240, Colors.white.withOpacity(0.05)),
                ),
                Positioned(
                  top: 40,
                  right: -35,
                  child: _circle(120, Colors.white.withOpacity(0.07)),
                ),
                Positioned(
                  bottom: 55,
                  left: 15,
                  child: _circle(75, Colors.white.withOpacity(0.06)),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 70.h,
                          width: 86.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(9.h),
                            child: Image.asset(
                              'assets/images/FIITJEE_Logo1.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          "Maharishi Learn",
                          style: TextStyle(
                            fontSize: 7.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Your digital learning companion",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 6.sp,
                            color: Colors.white70,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 26.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 7.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.28)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.school_rounded,
                                  color: Colors.white70, size: 5.sp),
                              SizedBox(width: 4.5.w),
                              Text(
                                "MGE ",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 4.sp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Positioned(
                //   bottom: 16.h,
                //   left: 0,
                //   right: 0,
                //   child: Text(
                //     "\u00a9 MGE",
                //     textAlign: TextAlign.center,
                //     style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                //   ),
                // ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
            color: isDarkMode
                ? const Color(0xFF1A1A2E)
                : const Color(0xFFF3F5FB),
            child: Center(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.symmetric(horizontal: 48.w, vertical: 20.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 460.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Welcome Back!",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "Sign in to access your courses",
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: isDarkMode
                              ? Colors.white54
                              : Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 28.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(28.w),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF16213E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(22.r),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black45
                                  : const Color(0xFFA10D52).withOpacity(0.10),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.08)
                                : const Color(0xFFA10D52).withOpacity(0.12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFA10D52)
                                        .withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Icon(
                                    Icons.lock_outline_rounded,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : const Color(0xFFA10D52),
                                    size: 10.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  "Login to Continue",
                                  style: TextStyle(
                                    fontSize: 5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isDarkMode
                                        ? Colors.white
                                        : const Color(0xFFA10D52),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              "Enrollment Number",
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.white60
                                    : Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 7.h),
                            TextField(
                              controller: controller.passwordController,
                              decoration: InputDecoration(
                                hintText: "Enter your enrollment number",
                                hintStyle: TextStyle(
                                    fontSize: 4.sp,
                                    color: Colors.grey.shade400),
                                prefixIcon: Icon(
                                  CupertinoIcons.number_circle,
                                  color: isDarkMode
                                      ? Colors.white38
                                      : Colors.black45,
                                  size: 6.sp,
                                ),
                                filled: true,
                                fillColor: isDarkMode
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.grey.shade50,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 14.h, horizontal: 16.w),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: isDarkMode
                                        ? Colors.white12
                                        : const Color(0xFFA10D52)
                                            .withOpacity(0.25),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: isDarkMode
                                        ? Colors.white12
                                        : const Color(0xFFA10D52)
                                            .withOpacity(0.25),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFA10D52),
                                    width: 1.8,
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 5.sp,
                              ),
                            ),
                            SizedBox(height: 22.h),
                            Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () => controller.login(
                                        enrollmentNo: controller
                                            .passwordController.text
                                            .trim()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode
                                      ? Colors.grey.shade700
                                      : const Color(0xFFA10D52),
                                  minimumSize: Size(double.infinity, 48.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 2,
                                ),
                                child: controller.isLoading.value
                                    ? LoadingAnimationWidget.fourRotatingDots(
                                        color: Colors.white,
                                        size: 34,
                                      )
                                    : Text(
                                        "Continue",
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortrait(
    BuildContext context,
    LoginController controller,
    bool isDarkMode,
  ) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 300.h),
          painter: GradientCurvePainter(isDarkMode),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 60.h),
                Container(
                  height: 100.h,
                  width: 100.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode ? Colors.grey[800] : Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5.h),
                    child: Image.asset(
                      'assets/images/FIITJEE_Logo1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 75.h),
                Text(
                  "Welcome to Maharishi Learn",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white
                        : const Color(0xFF2B2B2B),
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
                          : const Color(0xFFA10D52).withOpacity(0.4),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 6),
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
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFFA10D52),
                        ),
                      ),
                      SizedBox(height: 25.h),
                      TextField(
                        controller: controller.passwordController,
                        decoration: InputDecoration(
                          hintText: "Enter Enrollment Number",
                          prefixIcon: const Icon(
                            CupertinoIcons.number_circle,
                            color: Colors.black54,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15.h,
                            horizontal: 18.w,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: BorderSide(
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFFA10D52),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: BorderSide(
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFFA10D52),
                              width: 1.5,
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 30.h),
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.login(
                                  enrollmentNo: controller
                                      .passwordController.text
                                      .trim()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode
                                ? Colors.grey.shade800
                                : const Color(0xFFA10D52),
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
                                      : const Color(0xFFA10D52),
                                  size: 50,
                                )
                              : Text(
                                  "Continue",
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50.h),
                Text(
                  "\u00a9 MGE",
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
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class GradientCurvePainter extends CustomPainter {
  final bool isDarkMode;

  GradientCurvePainter(this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
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

    final gradient = LinearGradient(
      colors: [
        isDarkMode ? Colors.black : const Color(0xFFA10D52),
        isDarkMode ? Colors.grey.shade700 : const Color(0xFF4CA1AF),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawPath(path, paint);

    const icon = Icons.school;
    const iconSize = 120.0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white.withOpacity(0.30),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
        canvas, Offset(size.width - iconSize - 1, size.height * 0.1));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}