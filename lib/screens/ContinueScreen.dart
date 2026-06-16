import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gold_app/Model/assignmentmodel.dart';
import 'package:gold_app/controllers/ContinueScreenController.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../infrastructure/app_drawer/admin_drawer2.dart';
import '../infrastructure/routes/admin_routes.dart';

class ContinueScreen extends StatelessWidget {
  ContinueScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ContinueScreenController controller =
      Get.put(ContinueScreenController());

  // ── Colors ──────────────────────────────────────────────────
  Color get primary => ColorPainter.primaryColor;
  Color get accent  => ColorPainter.accentColor;

  // // ── Open assignment dialog ───────────────────────────────────
  // Future<void> _openAssignment(Assignment assignment) async {
  //   final selectedMode = await Get.dialog<String>(
  //     AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: const Text('Set time limit to solve assignment'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: ContinueScreenController.questionModeOptions
  //             .map(
  //               (option) => Padding(
  //                 padding: const EdgeInsets.only(bottom: 5),
  //                 child: SizedBox(
  //                   width: double.infinity,
  //                   child: ElevatedButton(
  //                     onPressed: () => Get.back(result: option.value),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: option.color ?? primary,
  //                       foregroundColor: Colors.white,
  //                       padding: const EdgeInsets.symmetric(vertical: 12),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                     ),
  //                     child: Text(option.label,
  //                         style: const TextStyle(fontSize: 14)),
  //                   ),
  //                 ),
  //               ),
  //             )
  //             .toList(),
  //       ),
  //       actions: [
  //         TextButton(
  //             onPressed: () => Get.back(), child: const Text('Cancel')),
  //       ],
  //     ),
  //     barrierDismissible: false,
  //   );

  //   if (selectedMode == null) return;

  //     Get.offAllNamed(AdminRoutes.examinstruction,
  //     arguments: {
  //       'testId':       assignment.testId ?? '',
  //     });
  //   // Get.offAllNamed(
  //   //   AdminRoutes.testscreen,
  //   //   arguments: {
  //   //     'testId':       assignment.testId ?? '',
  //   //     'passcode':     assignment.testId ?? '',
  //   //     'questionMode': selectedMode,
  //   //   },
  //   // );
  // }

  // ── Helpers ──────────────────────────────────────────────────
  Color _examTone(String examLabel) {
    switch (examLabel) {
      case 'CBSE':
      case 'Board':
        return primary;
      case 'JEE M':
        return const Color(0xFF1565C0);
      case 'JEE A':
        return accent;
      default:
        return primary;
    }
  }

  /// Returns filled% based purely on actual data (max 2 bubbles per round × 3 rounds).
  double _rowAveragePercent(List<List<Assignment>> rounds) {
    const int maxPerRound = 2;
    final int total  = rounds.length * maxPerRound;
    final int filled = rounds.fold<int>(0, (s, r) => s + r.length.clamp(0, maxPerRound));
    if (total == 0) return 0;
    return (filled * 100) / total;
  }

  /// Convert a percentage (0-100) to a GPA on a 4.0 scale.
  /// Defaults to a linear mapping where 100% -> 4.0.
  double _percentToGpa(double percent, {double maxGpa = 4.0}) {
    final p = percent.clamp(0, 100);
    return (p / 100.0) * maxGpa;
  }

  // ── Widgets ──────────────────────────────────────────────────
  Widget _buildRoundBubble({
    required String text,
    required VoidCallback onTap,
    required Color fillColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 15.w,
        height: 15.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fillColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 5.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildRoundCell(
    List<Assignment> assignments,
    Color tone,
    bool isDarkMode, {
    required int uiCount,
  }) {
    if (uiCount <= 0) return const SizedBox.shrink();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6.w,
      runSpacing: 6.h,
      children: List.generate(uiCount, (index) {
        final hasAssignment = index < assignments.length;
        final bubbleFill = tone.withValues(alpha: isDarkMode ? 0.18 : 0.12);
        return _buildRoundBubble(
          text: '${index + 1}',
          onTap: (){
            if (!hasAssignment) return;
            final assignment = assignments[index];
            Get.offAllNamed(AdminRoutes.examinstruction,
              arguments: {
                'testId':          assignment.testId ?? '',
                'passcode':        assignment.testId ?? '',
                'AssigtTopicId':   assignment.assigtTopicId?.toString() ?? '',
                'AssigtChapterId': assignment.assigtChapterId?.toString() ?? '',
                'SubjectId':       assignment.subjectId?.toString() ?? '',
                'AssExamRound':    assignment.assExamRound ?? '',
              });
              print("Tapped on assignment bubble with args: testId=${assignment.testId}, AssigtTopicId=${assignment.assigtTopicId}, AssigtChapterId=${assignment.assigtChapterId}, SubjectId=${assignment.subjectId}, AssExamRound=${assignment.assExamRound}");
          },
          fillColor: hasAssignment
              ? bubbleFill
              : tone.withValues(alpha: isDarkMode ? 0.08 : 0.06),
          borderColor: hasAssignment ? tone : tone.withValues(alpha: 0.6),
          textColor: isDarkMode ? Colors.white : tone,
        );
      }),
    );
  }

  /// Shows bubbles when the round has data, emoji when it has none.
  Widget _buildRoundCellWithUiRules({
    required List<Assignment> assignments,
    required Color tone,
    required bool isDarkMode,
  }) {
    if (assignments.isEmpty) {
      return Icon(Icons.emoji_emotions, color: Colors.redAccent.withValues(alpha: 0.8), size: 16.sp);
    }
    return _buildRoundCell(assignments, tone, isDarkMode, uiCount: assignments.length);
  }

  Widget _cell({required double width, required Widget child, double? height}) {
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        child: Center(child: child),
      ),
    );
  }

  Widget _divider(Color color) => Container(width: 1, color: color);

  Widget _buildExamRow({
    required String examLabel,
    required String chapterName,
    required String topicName,
    required bool isDarkMode,
    bool showTopBorder = false,
  }) {
    final assignments =
        controller.getAssignmentsFor(examLabel, chapterName, topicName);
    final rounds       = controller.splitAssignmentsIntoRounds(assignments);
    final tone         = _examTone(examLabel);
    final averagePercent = _rowAveragePercent(rounds);
    final dividerColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.14)
        : tone.withValues(alpha: 0.16);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: showTopBorder
              ? BorderSide(color: dividerColor, width: 1)
              : BorderSide.none,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _cell(
              width: 54.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: isDarkMode ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  examLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : tone,
                    fontSize: 4.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            _divider(dividerColor),
            _cell(
              width: 54.w,
              child: _buildRoundCellWithUiRules(
                  assignments: rounds[0], tone: tone, isDarkMode: isDarkMode),
            ),
            _divider(dividerColor),
            _cell(
              width: 54.w,
              child: _buildRoundCellWithUiRules(
                  assignments: rounds[1], tone: tone, isDarkMode: isDarkMode),
            ),
            _divider(dividerColor),
            _cell(
              width: 54.w,
              child: _buildRoundCellWithUiRules(
                  assignments: rounds[2], tone: tone, isDarkMode: isDarkMode),
            ),
            _divider(dividerColor),
            _cell(
              width: 54.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: isDarkMode ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: tone.withValues(alpha: 0.35), width: 1),
                ),
                child: Text(
                  '${_percentToGpa(averagePercent).toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : tone,
                    fontSize: 4.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicSection({
    required String chapterName,
    required String topicName,
    required bool isDarkMode,
    required bool showTopBorder,
  }) {
    final dividerColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.12)
        : primary.withValues(alpha: 0.14);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: showTopBorder
              ? BorderSide(color: dividerColor, width: 1)
              : BorderSide.none,
        ),
      ),
      child: Column(
        children: [
          // ── Sub-header row ──
          IntrinsicHeight(
            child: Row(children: [
              _cell(width: 54.w,
                  child: Text('Topic', style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 8.sp, fontWeight: FontWeight.w600))),
              _divider(dividerColor),
              _cell(width: 54.w,
                  child: Text('Target Exam', style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 8.sp, fontWeight: FontWeight.w600))),
              _divider(dividerColor),
              _cell(width: 54.w,
                  child: Text('Scholar', style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 6.sp, fontWeight: FontWeight.w600))),
              _divider(dividerColor),
              _cell(width: 54.w,
                  child: Text('Expert', style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 6.sp, fontWeight: FontWeight.w600))),
              _divider(dividerColor),
              _cell(width: 54.w,
                  child: Text('Champion', style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 6.sp, fontWeight: FontWeight.w600))),
              _divider(dividerColor),
              _cell(width: 54.w,
                  child: Text('GPA', style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 6.sp, fontWeight: FontWeight.w600))),
            ]),
          ),
          Container(height: 1, color: dividerColor),
          // ── Data row ──
          IntrinsicHeight(
            child: Row(children: [
              _cell(
                width: 54.w,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.04)
                        : primary.withValues(alpha: 0.05),
                  ),
                  child: Text(topicName,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : const Color(0xFF13305C),
                        fontSize: 3.5.sp, fontWeight: FontWeight.w700,
                      )),
                ),
              ),
              _divider(dividerColor),
              Column(
                children: List.generate(
                  ContinueScreenController.examOrder.length,
                  (index) => _buildExamRow(
                    examLabel:    ContinueScreenController.examOrder[index],
                    chapterName:  chapterName,
                    topicName:    topicName,
                    isDarkMode:   isDarkMode,
                    showTopBorder: index != 0,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterBlock(String chapterName, bool isDarkMode) {
    final topics = controller.getTopicsForChapter(chapterName);
    final dividerColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.12)
        : primary.withValues(alpha: 0.14);

    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF141A24) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.24 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: [
        // Chapter header
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft:  Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
          ),
          child: Row(children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text('Chapter',
                  style: TextStyle(
                    color: Colors.white, fontSize: 6.sp, fontWeight: FontWeight.w600,
                  )),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(chapterName,
                  style: TextStyle(
                    color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.w700,
                  )),
            ),
            Text(
              '${topics.length} Topic${topics.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11.sp, fontWeight: FontWeight.w500,
              ),
            ),
          ]),
        ),
        // Topic sections
        Column(
          children: List.generate(topics.length, (index) => _buildTopicSection(
            chapterName:    chapterName,
            topicName:      topics[index],
            isDarkMode:     isDarkMode,
            showTopBorder:  index != 0,
          )),
        ),
      ]),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: primary,
            size: 42,
          ),
        );
      }

      final chapters = controller.getAllChapters();

      if (chapters.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Text(
              'No assignments available',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 50.w * 6.4 + 8.w,
                  child: Column(
                    children: List.generate(chapters.length,
                        (i) => _buildChapterBlock(chapters[i], isDarkMode)),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: AdminDrawer2(),
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF4F6FA),
      appBar: AppBar(
        toolbarHeight: 120.h,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft:  Radius.circular(22.r),
              bottomRight: Radius.circular(22.r),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Assignments',
              style: TextStyle(
                fontSize: 8.sp, fontWeight: FontWeight.w700, color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Obx(() => Text(
              controller.subjectname.value.isNotEmpty
                  ? '${controller.subjectname.value} • ${controller.classs.value.replaceAll('"', '').trim()}'
                  : 'Continue your tests',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.sp, color: Colors.white70, fontWeight: FontWeight.w400,
              ),
            )),
          ],
        ),
        centerTitle: true,
      ),
      body: _buildBody(isDarkMode),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  COLOR PAINTER
// ─────────────────────────────────────────────────────────────
class ColorPainter {
  static const Color primaryColor   = Color(0xFFA10D52);
  static const Color secondaryColor = Color(0xFFFFA000);
  static const Color accentColor    = Color(0xFF4CA1AF);

  static LinearGradient get gradientBackground => const LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get buttonGradient => const LinearGradient(
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
    boxShadow: const [
      BoxShadow(offset: Offset(0, 6), blurRadius: 12, color: Colors.black26),
    ],
    borderRadius: BorderRadius.circular(20),
  );

  static BoxDecoration get buttonBoxDecoration => BoxDecoration(
    gradient: buttonGradient,
    borderRadius: BorderRadius.circular(30),
  );
}
