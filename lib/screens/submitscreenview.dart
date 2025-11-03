// screens/submitscreenview.dart
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gold_app/infrastructure/routes/admin_routes.dart';

class ResultScreen extends StatelessWidget {
  final int total;
  final int attempted;
  final int reviewed;
  final int notAttempted;

  const ResultScreen({
    super.key,
    required this.total,
    required this.attempted,
    required this.reviewed,
    required this.notAttempted,
  });

  @override
  Widget build(BuildContext context) {
    // ScreenUtil.init(context,
    //     designSize: const Size(375, 812), minTextAdapt: true);

    final double attemptedPercent = (attempted / total) * 100;
    final double reviewedPercent = (reviewed / total) * 100;
    final double notAttemptedPercent = (notAttempted / total) * 100;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B1313),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Test Summary",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            //  SizedBox(height: 10.h),
             Align(
  alignment: Alignment.centerRight,
  child: ElevatedButton.icon(
    onPressed: () {
      // Show circular progress indicator
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dialog from being dismissed
        builder: (_) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(color: Colors.white),
                // SizedBox(height: 20),
                // Text(
                //   "Refreshing...",
                //   style: TextStyle(color: Colors.white, fontSize: 16),
                // ),
              ],
            ),
          ),
        ),
      );

      // Wait for 3 to 5 seconds (simulate refresh process)
      Future.delayed(const Duration(seconds: 4), () {
        // Close the dialog after the delay
        Navigator.pop(context);

        // Perform any action you want after refresh (e.g., update screen data)
        // Example: You could call a function to refresh the data here.
        // refreshData();

        // Optionally, show a snackbar or update UI after the refresh
        Get.snackbar(
          "Refresh Complete",
          "Your data has been refreshed.",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.black,
        );
      });
    },
    icon: const Icon(Icons.refresh, color: Colors.white),
    label: const Text(
      "Refresh",
      style: TextStyle(color: Colors.white),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF8B2D28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
),

                  
              /// ✅ Header Card with Key Stats
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _infoItem("Total Questions", "$total",
                              Colors.black87),
                          _infoItem(
                              "Attempted", "$attempted", Colors.green),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _infoItem(
                              "Marked", "$reviewed", Colors.purple),
                          _infoItem("Unattempted", "$notAttempted",
                              Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25.h),

              /// 🎯 Performance Pie Chart
              Text(
                "Overall Performance",
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              SizedBox(height: 130.h),

              SizedBox(
                height: 230.h,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    sections: [
                      _chartSection(
                          Colors.green, attemptedPercent, "Attempted"),
                      _chartSection(
                          Color(0xFF4a4a4a), reviewedPercent, "Marked"),
                      _chartSection(
                          Colors.grey, notAttemptedPercent, "Unattempted"),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 130.h),

              /// 🧩 Chart Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _legendItem("Attempted", Colors.green),
                  _legendItem("Marked", Colors.purple),
                  _legendItem("Unattempted", Colors.grey),
                ],
              ),

              SizedBox(height: 30.h),

              /// 📊 Subject-wise Performance
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Subject-Wise Analysis",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15.h),
                     // For Physics
_subjectRow("Physics", 75, Icons.science),

// For Chemistry
_subjectRow("Chemistry", 60, Icons.local_drink),

// For Mathematics
_subjectRow("Mathematics", 85, Icons.calculate),

                    ],
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              /// ✅ Back Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed:(){
                      Get.offAllNamed(AdminRoutes.LOADING_SCREEN);
                    },
                      icon:
                        const Icon(Icons.home_outlined, color: Colors.white),
                    label: const Text("Back To Login",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B2D28),
                      padding: EdgeInsets.symmetric(
                          horizontal: 40.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                   ElevatedButton.icon(
                    onPressed:(){
                      exit(0);},
                      icon:
                        const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Exit",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B2D28),
                      padding: EdgeInsets.symmetric(
                          horizontal: 40.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Pie Chart Section
  PieChartSectionData _chartSection(Color color, double value, String title) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: "${value.toStringAsFixed(1)}%",
      radius: 70,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// 🔹 Info Card Item
  Widget _infoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black54)),
        SizedBox(height: 5.h),
        Text(value,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }

  /// 🔹 Result Row (General Stats)
  Widget _resultRow(String label, int value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Legend Item
  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        SizedBox(width: 6.w),
        Text(label, style: TextStyle(fontSize: 12.sp)),
      ],
    );
  }
/// 🔹 Subject Row with Circular Progress Indicator
Widget _subjectRow(String subject, int percent, IconData icon) {
  return Padding(
    padding: EdgeInsets.only(bottom: 20.h),
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            // Icon for Subject
            Icon(
              icon,
              size: 30.sp,
              color: Colors.blue.shade700,
            ),
            SizedBox(width: 16.w),

            // Subject Name and Progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "$percent%",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: percent >= 60 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            // Circular Progress Indicator
            SizedBox(
              height: 40.w,
              width: 40.w,
              child: CircularProgressIndicator(
                value: percent / 100,
                strokeWidth: 4,
                color: percent >= 60 ? Colors.green : Colors.red,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}