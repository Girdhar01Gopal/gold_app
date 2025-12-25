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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(180.h),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1), // Assignment primary color
                  Color(0xFF4CA1AF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(top: 50.h, left: 20.w, right: 20.w, bottom: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              controller.studentname.value.replaceAll('"', '').trim(),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Obx(
                            () => Text(
                              '${controller.className.value.replaceAll('"', '').trim()} • ${controller.session.value.replaceAll('"', '').replaceAll('-', '-').trim()}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  'Select Your Subject',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Obx(
          () => controller.subjects.isEmpty
              ? Center(
                  child: CircularProgressIndicator(
                    color: ColorPainter.primaryColor,
                  ),
                )
              : ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: controller.subjects.length,
                  itemBuilder: (context, index) {
                    final subject = controller.subjects[index];
                    return _buildSubjectCard(
                      subject.subjectName ?? 'No Name',
                      () {
                        Get.offAllNamed(
                          AdminRoutes.CONTINUE_SCREEN,
                          arguments: {
                            'subjectId': subject.subjectId.toString(),
                          },
                        );
                      },
                      context,
                      index,
                      isDarkMode, // Pass dark mode info
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
    String subject,
    VoidCallback onPressed,
    BuildContext context,
    int index,
    bool isDarkMode, // Get the dark mode status
  ) {
    // Icon selection based on subject
    IconData getSubjectIcon(String subjectName) {
      final name = subjectName.toLowerCase();
      if (name.contains('math')) return Icons.calculate;
      if (name.contains('physics')) return Icons.science;
      if (name.contains('chemistry')) return Icons.biotech;
      if (name.contains('biology')) return Icons.local_florist;
      if (name.contains('english')) return Icons.menu_book;
      return Icons.school;
    }

    // Color selection based on index
    List<Color> getGradientColors(int idx) {
      final colorSets = [
        [Color(0xFF0D47A1), Color(0xFF1976D2)],
        [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
        [Color(0xFFD84315), Color(0xFFFF6F00)],
        [Color(0xFF2E7D32), Color(0xFF43A047)],
        [Color(0xFFC62828), Color(0xFFE53935)],
      ];
      return colorSets[idx % colorSets.length];
    }

    final gradientColors = getGradientColors(index);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showLoadingDialog(context);
            Future.delayed(Duration(seconds: 2), () {
              Navigator.of(context).pop();
              onPressed();
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Gradient Icon Container
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    getSubjectIcon(subject),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                SizedBox(width: 16.w),
                // Subject Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'View Assignments',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow Icon
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: gradientColors[0].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: gradientColors[0],
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
