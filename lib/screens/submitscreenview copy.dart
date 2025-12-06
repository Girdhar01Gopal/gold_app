import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gold_app/infrastructure/routes/admin_routes.dart';
import 'package:gold_app/utils/constants/color_constants.dart';

// removed duplicate/unused imports
import 'package:flutter/services.dart';

class ResultScreen extends StatelessWidget {
  final int total;
  final int attempted;
  final int reviewed;
  final int notAttempted;
  final List<Map<String, dynamic>>? questionReviewData;

  ResultScreen({
    super.key,
    required this.total,
    required this.attempted,
    required this.reviewed,
    required this.notAttempted,
    this.questionReviewData,
  });

  final GlobalKey _repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double attemptedPercent = (attempted / total) * 100;
    final double reviewedPercent = (reviewed / total) * 100;
    final double notAttemptedPercent = (notAttempted / total) * 100;

    final grouped = _groupedQuestions();
    final subjectStats = _calculateSubjectStats();

    final correct = questionReviewData
            ?.where((q) => q['isCorrect'] == true)
            .length ??
        0;
    final skipped = questionReviewData
            ?.where((q) => q['studentAnswer'] == '—')
            .length ??
        0;
    final wrong = total - correct - skipped;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.MAHARISHI_GOLD, AppColor.MAHARISHI_AMBER, AppColor.MAHARISHI_BRONZE],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Test Summary",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: RepaintBoundary(
        key: _repaintKey,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ---------- Header
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [AppColor.MAHARISHI_GOLD, AppColor.MAHARISHI_AMBER, AppColor.MAHARISHI_BRONZE],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _headerItem("Total", total.toString(), Colors.white),
                      _headerItem(
                          "Attempted", attempted.toString(), Colors.greenAccent),
                      _headerItem("Marked", reviewed.toString(), Colors.white),
                      _headerItem("Unanswered", notAttempted.toString(),
                          Colors.yellowAccent),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // ---------- Quick Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _summaryBox("✅ Correct", correct, Colors.green),
                    _summaryBox("❌ Wrong", wrong, Colors.red),
                    _summaryBox("➖ Skipped", skipped, Colors.grey),
                  ],
                ),
                SizedBox(height: 30.h),

                // ---------- Pie Chart
                Text(
                  "Overall Performance",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  height: 250.h,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 40,
                      sectionsSpace: 4,
                      sections: [
                        _chartSection(
                            Colors.green, attemptedPercent, "Attempted"),
                        _chartSection(
                            Colors.purple, reviewedPercent, "Marked"),
                        _chartSection(Colors.grey, notAttemptedPercent,
                            "Unattempted"),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30.h),

                // ---------- Subject Stats
                if (subjectStats.isNotEmpty) ...[
                  Text(
                    "Subject-wise Analysis",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.MAHARISHI_BRONZE,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...subjectStats.entries.map((e) {
                    final subject = e.key;
                    final stats = e.value;
                    return _subjectStatCard(subject, stats);
                  }),
                ],
                SizedBox(height: 25.h),

                // ---------- Question Review
                if (grouped.isNotEmpty) ...[
                  Text(
                    "Detailed Review",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.MAHARISHI_BRONZE,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...grouped.entries.map((entry) {
                    final subject = entry.key;
                    final questions = entry.value;
                    return ExpansionTile(
                      collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.black12)),
                      title: Text(
                        subject,
                        style: TextStyle(
                            color: AppColor.MAHARISHI_BRONZE,
                            fontWeight: FontWeight.bold),
                      ),
                      children: questions.map((q) => _questionCard(q)).toList(),
                    );
                  }),
                ],

                SizedBox(height: 40.h),

                // ---------- Navigation Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _bottomButton(
                      label: "Dashboard",
                      icon: Icons.home_outlined,
                      color: AppColor.MAHARISHI_BRONZE,
                      onTap: () => Get.offAllNamed(AdminRoutes.LOADING_SCREEN),
                    ),
                    _bottomButton(
                      label: "Exit",
                      icon: Icons.logout,
                      color: Colors.red.shade700,
                      onTap: () => exit(0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Capture and share the screen


  // ---------- Group by subject
  Map<String, List<Map<String, dynamic>>> _groupedQuestions() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var q in questionReviewData ?? []) {
      final subj = q['subject'] ?? 'General';
      grouped.putIfAbsent(subj, () => []);
      grouped[subj]!.add(q);
    }
    return grouped;
  }

  // ---------- Calculate subject stats
  Map<String, Map<String, int>> _calculateSubjectStats() {
    final result = <String, Map<String, int>>{};
    final grouped = _groupedQuestions();
    grouped.forEach((subject, questions) {
      final correct = questions.where((q) => q['isCorrect']).length;
      final wrong = questions
          .where((q) => q['isCorrect'] == false && q['studentAnswer'] != '—')
          .length;
      final skipped = questions.where((q) => q['studentAnswer'] == '—').length;
      result[subject] = {
        'correct': correct,
        'wrong': wrong,
        'skipped': skipped,
      };
    });
    return result;
  }

// ---------- Subject stat card (Gradient Style)
Widget _subjectStatCard(String subject, Map<String, int> stats) {
  final total = stats['correct']! + stats['wrong']! + stats['skipped']!;
  final String accuracy =
      total == 0 ? '0' : (stats['correct']! / total * 100).toStringAsFixed(1);

  // Choose gradient color based on performance
  final double accuracyValue = double.tryParse(accuracy) ?? 0;
  final List<Color> gradientColors = accuracyValue >= 70
      ? [const Color(0xFF4CAF50), const Color(0xFF81C784)] // Green tone
      : accuracyValue >= 40
          ? [const Color(0xFFFFA726), const Color(0xFFFFCC80)] // Orange tone
          : [const Color(0xFFE53935), const Color(0xFFFF8A80)]; // Red tone

  return Card(
    margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject Title
          Text(
            subject,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8.h),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem("✅", "Correct", stats['correct']!, Colors.white),
              _statItem("❌", "Wrong", stats['wrong']!, Colors.white),
              _statItem("➖", "Skipped", stats['skipped']!, Colors.white70),
              _statItem("🎯", "Accuracy", double.parse(accuracy), Colors.white,
                  suffix: "%"),
            ],
          ),
        ],
      ),
    ),
  );
}

// ---------- Helper for stat item
Widget _statItem(String emoji, String label, dynamic value, Color color,
    {String suffix = ""}) {
  return Column(
    children: [
      Text(
        emoji,
        style: TextStyle(fontSize: 18.sp, color: color),
      ),
      Text(
        "$value$suffix",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
          color: color,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          color: color.withOpacity(0.9),
        ),
      ),
    ],
  );
}

  // ---------- Question card
  Widget _questionCard(Map<String, dynamic> q) {
    final isCorrect = q['isCorrect'] ?? false;
    final studentAnswer = q['studentAnswer'] ?? '—';
    final correctAnswer = q['correctAnswer'] ?? '—';

    Color borderColor;
    if (studentAnswer == '—') {
      borderColor = Colors.grey;
    } else {
      borderColor = isCorrect ? Colors.green : Colors.red;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: borderColor, width: 1.2),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q['question'] ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 6.h),
            Text.rich(
              TextSpan(
                text: "Your Answer: ",
                style: const TextStyle(fontWeight: FontWeight.w500),
                children: [
                  TextSpan(
                    text: studentAnswer,
                    style: TextStyle(
                      color: isCorrect
                          ? Colors.green
                          : (studentAnswer == '—'
                              ? Colors.grey
                              : Colors.red),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: "Correct Answer: ",
                style: const TextStyle(fontWeight: FontWeight.w500),
                children: [
                  TextSpan(
                    text: correctAnswer,
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Pie Chart Section
  PieChartSectionData _chartSection(Color color, double value, String title) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: "${value.toStringAsFixed(1)}%",
      radius: 70,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ---------- Header Item
  Widget _headerItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            )),
        SizedBox(height: 4.h),
        Text(value,
            style: TextStyle(
              color: color,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

  // ---------- Summary Box
  Widget _summaryBox(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(count.toString(),
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 18.sp)),
          Text(label,
              style: TextStyle(
                  color: color.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp)),
        ],
      ),
    );
  }

  // ---------- Button
  Widget _bottomButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    );
  }
}
