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
  final int totalMarks;
  final int obtainedMarks;
  final List<Map<String, dynamic>>? questionReviewData;

  const ResultScreen({
    super.key,
    required this.total,
    required this.attempted,
    required this.reviewed,
    required this.notAttempted,
    required this.totalMarks,
    required this.obtainedMarks,
    this.questionReviewData,
  });

  static const Color _primary = Color(0xFFA10D52);
  static const Color _accent  = Color(0xFF4CA1AF);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final double attemptedPercent = total > 0 ? (attempted / total) * 100 : 0;
    final double reviewedPercent  = total > 0 ? (reviewed  / total) * 100 : 0;
    final double notAttemptedPercent = total > 0 ? (notAttempted / total) * 100 : 0;

    final grouped      = _groupedQuestions();
    final subjectStats = _calculateSubjectStats();

    final correct = questionReviewData?.where((q) => q['isCorrect'] == true).length ?? 0;
    final skipped = questionReviewData?.where((q) => q['studentAnswer'] == '—').length ?? 0;
    final wrong   = total - correct - skipped;

    final double pct = totalMarks > 0 ? (obtainedMarks / totalMarks) * 100 : 0;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? null
                : const LinearGradient(
                    colors: [_primary, _accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isDarkMode ? const Color(0xFF1A1F2E) : null,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(22),
            ),
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Assignment Summary',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Text(
              'Your performance overview',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 10),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero result card ──────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1A1F2E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Gradient header strip
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primary, _accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.emoji_events, color: Colors.white, size: 28),
                          ),
                          SizedBox(width: 14.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Assignment Completed!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Your Performance Summary',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Score row
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                      child: Row(
                        children: [
                          _scoreTile('Obtained', obtainedMarks.toString(), _primary, isDarkMode),
                          _scoreDivider(isDarkMode),
                          _scoreTile('Total', totalMarks.toString(), _accent, isDarkMode),
                          _scoreDivider(isDarkMode),
                          _scoreTile('Score', '${pct.toStringAsFixed(1)}%',
                              pct >= 60 ? Colors.green.shade600 : Colors.orange.shade700, isDarkMode),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    // Correct / Wrong / Skipped chips
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _chip(Icons.check_circle_outline, '$correct Correct', Colors.green.shade600),
                          _chip(Icons.cancel_outlined,      '$wrong Wrong',     Colors.red.shade600),
                          _chip(Icons.remove_circle_outline,'$skipped Skipped', Colors.grey.shade600),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    // Mini stats strip
                    Container(
                      margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 16.h),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFF8F0F4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _miniStat('Total',    total.toString(),       _primary,              isDarkMode),
                          _vDivider(isDarkMode),
                          _miniStat('Attempted', attempted.toString(),  Colors.green.shade600,  isDarkMode),
                          _vDivider(isDarkMode),
                          _miniStat('Marked',   reviewed.toString(),    Colors.purple.shade600, isDarkMode),
                          _vDivider(isDarkMode),
                          _miniStat('Skipped',  notAttempted.toString(),Colors.orange.shade600, isDarkMode),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // ── Pie chart ─────────────────────────────────────────────
              _sectionHeader('Overall Performance', isDarkMode),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1A1F2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 220.h,
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 38,
                          sectionsSpace: 3,
                          sections: [
                            _chartSection(_primary,              attemptedPercent,    'Attempted'),
                            _chartSection(Colors.purple.shade400,reviewedPercent,     'Marked'),
                            _chartSection(Colors.grey.shade400,  notAttemptedPercent, 'Skipped'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legendDot(_primary,               'Attempted'),
                        SizedBox(width: 16.w),
                        _legendDot(Colors.purple.shade400, 'Marked'),
                        SizedBox(width: 16.w),
                        _legendDot(Colors.grey.shade400,   'Skipped'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // ── Subject stats ─────────────────────────────────────────
              if (subjectStats.isNotEmpty) ...[
                _sectionHeader('Subject-wise Analysis', isDarkMode),
                SizedBox(height: 12.h),
                ...subjectStats.entries.map((e) => _subjectStatCard(e.key, e.value, isDarkMode)),
                SizedBox(height: 8.h),
              ],

              // ── Detailed review ───────────────────────────────────────
              if (grouped.isNotEmpty) ...[
                _sectionHeader('Detailed Review', isDarkMode),
                SizedBox(height: 12.h),
                ...grouped.entries.map((entry) {
                  final questions = entry.value;
                  final c = questions.where((q) => q['isCorrect'] == true).length;
                  return Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1A1F2E) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.08)
                            : _primary.withValues(alpha: 0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      shape: const Border(),
                      collapsedShape: const Border(),
                      tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                      title: Text(
                        entry.key,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : _primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_primary, _accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$c/${questions.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      children: questions.map((q) => _questionCard(q, isDarkMode)).toList(),
                    ),
                  );
                }),
                SizedBox(height: 8.h),
              ],

              // ── Bottom buttons ────────────────────────────────────────
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.offAllNamed(AdminRoutes.LOADING_SCREEN),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_primary, _accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _primary.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home_outlined, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Dashboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => exit(0),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Exit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, bool isDarkMode) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primary, _accent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : _primary,
          ),
        ),
      ],
    );
  }

  Widget _scoreTile(String label, String value, Color color, bool isDarkMode) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: color),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreDivider(bool isDarkMode) => Container(
    width: 1,
    height: 36.h,
    color: isDarkMode ? Colors.white12 : Colors.grey.shade200,
  );

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          SizedBox(width: 5.w),
          Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color, bool isDarkMode) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: color)),
        SizedBox(height: 2.h),
        Text(label, style: TextStyle(fontSize: 9.sp, color: isDarkMode ? Colors.white54 : Colors.grey.shade600)),
      ],
    );
  }

  Widget _vDivider(bool isDarkMode) => Container(
    width: 1,
    height: 28.h,
    color: isDarkMode ? Colors.white12 : Colors.grey.shade300,
  );

  Widget _subjectStatCard(String subject, Map<String, int> stats, bool isDarkMode) {
    final t = stats['correct']! + stats['wrong']! + stats['skipped']!;
    final acc = t == 0 ? 0.0 : stats['correct']! / t * 100;
    final List<Color> g = acc >= 70
        ? [const Color(0xFF4CAF50), const Color(0xFF81C784)]
        : acc >= 40
            ? [const Color(0xFFFFA726), const Color(0xFFFFCC80)]
            : [const Color(0xFFE53935), const Color(0xFFFF8A80)];

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: g, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: g.last.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subject,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('✅', 'Correct', stats['correct']!),
              _statItem('❌', 'Wrong', stats['wrong']!),
              _statItem('➖', 'Skipped', stats['skipped']!),
              _statItem('🎯', 'Accuracy', acc, suffix: '%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String emoji, String label, dynamic value, {String suffix = ''}) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 16.sp)),
        Text(
          value is double ? '${value.toStringAsFixed(1)}$suffix' : '$value$suffix',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.sp),
        ),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
      ],
    );
  }

  Widget _questionCard(Map<String, dynamic> q, bool isDarkMode) {
    final isCorrect     = q['isCorrect'] ?? false;
    final studentAnswer = q['studentAnswer'] ?? '—';
    final correctAnswer = q['correctAnswer'] ?? '—';
    final skipped       = studentAnswer == '—';

    final Color accent = skipped ? Colors.grey : (isCorrect ? Colors.green.shade600 : Colors.red.shade600);

    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q['question'] ?? '',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text('Your: ', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
              Text(
                studentAnswer,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
              const Spacer(),
              Text('Correct: ', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
              Text(
                correctAnswer,
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: _accent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _chartSection(Color color, double value, String title) {
    return PieChartSectionData(
      color: color,
      value: value <= 0 ? 0.001 : value,
      title: value > 5 ? '${value.toStringAsFixed(0)}%' : '',
      radius: 65,
      titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600)),
      ],
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupedQuestions() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final q in questionReviewData ?? []) {
      final subj = q['subject'] ?? 'General';
      grouped.putIfAbsent(subj, () => []).add(q);
    }
    return grouped;
  }

  Map<String, Map<String, int>> _calculateSubjectStats() {
    final result  = <String, Map<String, int>>{};
    final grouped = _groupedQuestions();
    grouped.forEach((subject, questions) {
      result[subject] = {
        'correct': questions.where((q) => q['isCorrect'] == true).length,
        'wrong':   questions.where((q) => q['isCorrect'] == false && q['studentAnswer'] != '—').length,
        'skipped': questions.where((q) => q['studentAnswer'] == '—').length,
      };
    });
    return result;
  }
}
