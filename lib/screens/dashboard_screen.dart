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
                Text(
                  'Class 11 (AY 2025)',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
                padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 25.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton('Reset', Icons.refresh, () => _showResetDialog(context)),
                    _buildActionButton('Change Year', Icons.calendar_today, () {
                      showYearDropdownDialog(
                        context: context,
                        selectedYear: selectedYear ?? '2025',
                        onYearSelected: (String year) {
                          Get.snackbar('Academic Year Changed', 'Selected $year', snackPosition: SnackPosition.BOTTOM);
                        },
                      );
                    }),
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
                      },context),
                      SizedBox(height: 20.h),
                      _buildSubjectCard('Maths', () {
                        Get.offAllNamed(AdminRoutes.mathscreen);
                      },context),
                      SizedBox(height: 20.h),
                      _buildSubjectCard('Physics', () {
                        Get.offAllNamed(AdminRoutes.physics);
                      },context),
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
  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
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
Widget _buildSubjectCard(String subject, VoidCallback onPressed,BuildContext context) {
  return Card(
    elevation: 6.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
    clipBehavior: Clip.antiAlias,
    shadowColor: Colors.black26,
    child: InkWell(
      onTap: () {
        _showLoadingDialog(context);
        // Simulate a delay (5 seconds) before navigating
        Future.delayed(Duration(seconds: 5), () {
          Navigator.of(context).pop(); // Close the loading dialog
          onPressed(); // Navigate to the next screen
        });
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 213, 103, 103), ColorPainter.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(25.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              color: Colors.white,
              size: 60.sp,
            ),
            SizedBox(height: 15.h),
            Text(
              subject,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
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
    barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r), // Rounded corners for the dialog
        ),
        contentPadding: EdgeInsets.all(25.w), // Add padding inside the dialog
        backgroundColor: Colors.black.withOpacity(0.7), // Set a darker background for the dialog
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading animation (using InkDrop animation)
            LoadingAnimationWidget.inkDrop(
              color: Colors.white, // White color for the animation
              size: 50.w, // Adjust size based on screen size
            ),
            SizedBox(height: 20.h), // Space between the animation and the text
            // Message text
            Text(
              'Please wait...',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white, // Text color
              ),
              textAlign: TextAlign.center, // Center-align the text
            ),
          ],
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
            style: TextStyle(fontSize: 14.sp, color: Colors.black54, height: 1.4),
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
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(25.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Academic Year',
                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.grey.shade100,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: tempSelectedYear,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down_rounded),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          tempSelectedYear = newValue;
                        }
                      },
                      items: ['2025', '2026']
                          .map((year) => DropdownMenuItem<String>(
                                value: year,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  child: Text(year, style: TextStyle(fontSize: 18.sp)),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                SizedBox(height: 25.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(fontSize: 16.sp)),
                    ),
                    SizedBox(width: 12.w),
                    ElevatedButton(
                      onPressed: () {
                        onYearSelected(tempSelectedYear);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1F2A3D),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('Confirm', style: TextStyle(fontSize: 16.sp)),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
