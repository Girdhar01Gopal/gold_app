import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path/path.dart';
import '../controllers/dashboard_controller.dart';
import '../infrastructure/routes/admin_routes.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  String? selectedYear = '2025'; // Default selected year

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(200.h),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: ColorPainter.boxDecoration,
            padding: EdgeInsets.only(top: 60.h, left: 25.w, right: 25.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    '${controller.studentname.value.replaceAll('"', '').trim()} ',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Obx(
                  () => Text(
                    '${controller.className.value.replaceAll('"', '').trim()} (AY ${controller.session.value.replaceAll('"', '').replaceAll('-', ' - ').trim()})',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                //  SizedBox(height: 1.h),
                Obx(
                  () => Text(
                    '${controller.enrollmentNo.value.replaceAll('"', '').trim()}',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Choose your assignments and academic year',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background image with opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/FIITJEE_Logo.png', // Replace with your image path
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Main content on top of the background image
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 25.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //  //   _buildActionButton('Reset', Icons.refresh, () => _showResetDialog(context)),
                    //     _buildActionButton('Change Year', Icons.calendar_today, () {
                    //       showYearDropdownDialog(
                    //         context: context,
                    //         selectedYear: selectedYear ?? '2025',
                    //         onYearSelected: (String year) {
                    //           Get.snackbar('Academic Year Changed', 'Selected $year', snackPosition: SnackPosition.BOTTOM);
                    //         },
                    //       );
                    //     }),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: ListView(
                    children: [
                      _buildSubjectCard('Chemistry', () {
                        Get.offAllNamed(AdminRoutes.CONTINUE_SCREEN);
                      }, context),
                      SizedBox(height: 20.h),
                      _buildSubjectCard('Maths', () {
                        Get.offAllNamed(AdminRoutes.mathscreen);
                      }, context),
                      SizedBox(height: 20.h),
                      _buildSubjectCard('Physics', () {
                        Get.offAllNamed(AdminRoutes.physics);
                      }, context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Action button (Reset, Change Year) widget
  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: ColorPainter.secondaryColor,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 8,
        shadowColor: Colors.black26,
        side: BorderSide(color: Colors.white, width: 1.5),
      ),
      icon: Icon(icon, size: 22.sp),
      label: Text(
        label,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Subject card widget (Chemistry, Maths, Physics)
  Widget _buildSubjectCard(
    String subject,
    VoidCallback onPressed,
    BuildContext context,
  ) {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: () {
          _showLoadingDialog(context);
          // Simulate a delay (5 seconds) before navigating
          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pop(); // Close the loading dialog
            onPressed(); // Navigate to the next screen
          });
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 213, 103, 103),
                ColorPainter.secondaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.all(25.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.book, color: Colors.white, size: 60.sp),
              SizedBox(height: 15.h),
              Text(
                subject,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show the loading dialog with circular progress bar
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(30.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: ColorPainter.primaryColor.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: ColorPainter.secondaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorPainter.primaryColor,
                        ColorPainter.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ColorPainter.secondaryColor.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: LoadingAnimationWidget.inkDrop(
                    color: Colors.white,
                    size: 50.w,
                  ),
                ),
                SizedBox(height: 25.h),
                Text(
                  'Please wait...',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: ColorPainter.primaryColor,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Loading your content',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to show the Reset Confirmation Dialog
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          titlePadding: EdgeInsets.fromLTRB(25.w, 25.h, 25.w, 0),
          contentPadding: EdgeInsets.fromLTRB(25.w, 10.h, 25.w, 0),
          actionsPadding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 15.h),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 26.sp),
              SizedBox(width: 12.w),
              Text(
                'Confirm Reset',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            'If you continue, the app will reset to its initial state as if it’s being used for the first time.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.restart_alt_rounded, size: 18.sp),
              label: Text('Reset Now', style: TextStyle(fontSize: 14.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showYearDropdownDialog({
    required BuildContext context,
    required String selectedYear,
    required Function(String) onYearSelected,
  }) async {
    String tempSelectedYear = selectedYear;
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: ColorPainter.secondaryColor.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: ColorPainter.secondaryColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 25.h,
                        horizontal: 25.w,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorPainter.primaryColor,
                            ColorPainter.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.r),
                          topRight: Radius.circular(24.r),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                          ),
                          SizedBox(width: 15.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Academic Year',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20.sp,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Select your current session',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets.all(25.w),
                      child: Column(
                        children: [
                          // Year selection cards
                          ...['2025', '2026'].map((year) {
                            final isSelected = tempSelectedYear == year;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  tempSelectedYear = year;
                                });
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                margin: EdgeInsets.only(bottom: 12.h),
                                padding: EdgeInsets.symmetric(
                                  vertical: 18.h,
                                  horizontal: 20.w,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            ColorPainter.primaryColor
                                                .withOpacity(0.1),
                                            ColorPainter.secondaryColor
                                                .withOpacity(0.1),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? ColorPainter.secondaryColor
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2.5 : 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: ColorPainter.secondaryColor
                                                .withOpacity(0.2),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: Duration(milliseconds: 200),
                                      width: 24.w,
                                      height: 24.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? ColorPainter.secondaryColor
                                              : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        gradient: isSelected
                                            ? LinearGradient(
                                                colors: [
                                                  ColorPainter.primaryColor,
                                                  ColorPainter.secondaryColor,
                                                ],
                                              )
                                            : null,
                                      ),
                                      child: isSelected
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16.sp,
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: 15.w),
                                    Text(
                                      'Academic Year $year',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? ColorPainter.primaryColor
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          SizedBox(height: 20.h),
                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey[700],
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        ColorPainter.primaryColor,
                                        ColorPainter.secondaryColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ColorPainter.secondaryColor
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      onYearSelected(tempSelectedYear);
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Confirm',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ColorPainter {
  static const Color primaryColor = Color(0xFF9B1313);
  static const Color secondaryColor = Color(0xFFD69B08);
  static const Color accentColor = Color(0xFF4CA1AF);

  static LinearGradient get gradientBackground => LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get buttonGradient => LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration get boxDecoration => BoxDecoration(
    gradient: gradientBackground,
    borderRadius: BorderRadius.circular(25),
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        offset: Offset(0, 6),
        blurRadius: 12,
        color: Colors.black.withOpacity(0.15),
      ),
    ],
    borderRadius: BorderRadius.circular(20),
  );

  static BoxDecoration get buttonBoxDecoration => BoxDecoration(
    gradient: buttonGradient,
    borderRadius: BorderRadius.circular(30),
  );
}
