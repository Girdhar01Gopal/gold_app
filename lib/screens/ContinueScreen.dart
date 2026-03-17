import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gold_app/Model/assignmentmodel.dart';
import 'package:gold_app/appurl/adminurl.dart';
import 'package:gold_app/localstorage.dart';
import 'package:gold_app/prefconst.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../infrastructure/app_drawer/admin_drawer2.dart';
import '../infrastructure/routes/admin_routes.dart';

class ContinueScreen extends StatefulWidget {
  const ContinueScreen({super.key});

  @override
  State<ContinueScreen> createState() => _ContinueScreenState();
}

class _ContinueScreenState extends State<ContinueScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const List<String> _examOrder = ['Board', 'JEE Main', 'JEE Advanced'];

  /// examType -> chapterName -> AssignmentChapters
  final Map<String, Map<String, AssignmentChapters>> allAssignments = {};

  final RxString schoolid = ''.obs;
  final RxString studentid = ''.obs;
  final RxString subjectId = ''.obs;
  final RxString subjectname = ''.obs;
  final RxString classs = ''.obs;

  bool isLoading = true;

  final Color primary = ColorPainter.primaryColor;
  final Color accent = ColorPainter.accentColor;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    subjectId.value = Get.arguments?['subjectId'] ?? '';
    subjectname.value = Get.arguments?['subjectName'] ?? '';
    schoolid.value = await PrefManager().readValue(key: PrefConst.SchoolId);
    studentid.value = await PrefManager().readValue(key: PrefConst.StudentId);
    classs.value = await PrefManager().readValue(key: PrefConst.className);
    await assignment();
  }

  Future<void> assignment() async {
    try {
      setState(() => isLoading = true);

      final url =
          "${Adminurl.assignment}/${schoolid.value}/${studentid.value}/${subjectId.value}";
      final response = await http.get(Uri.parse(url));

      debugPrint("Request URL: $url");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint("API Response: $jsonResponse");

        if (jsonResponse['data'] != null &&
            jsonResponse['data']['AssignmentExam'] != null) {
          final assignmentExam =
              jsonResponse['data']['AssignmentExam'] as Map<String, dynamic>;

          allAssignments.clear();

          assignmentExam.forEach((examType, examData) {
            if (examData is Map<String, dynamic> &&
                examData['AssignmentChapters'] != null) {
              final chapters =
                  examData['AssignmentChapters'] as Map<String, dynamic>;

              final Map<String, AssignmentChapters> examChapters = {};

              chapters.forEach((chapterName, chapterData) {
                if (chapterData is List) {
                  examChapters[chapterName] = AssignmentChapters(
                    assignments: chapterData
                        .map(
                          (item) =>
                              Assignment.fromJson(item as Map<String, dynamic>),
                        )
                        .toList(),
                  );
                }
              });

              allAssignments[examType] = examChapters;
            }
          });
        }
      } else {
        throw Exception('Failed to load assignments: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error in fetching assignments: $e");
      Get.snackbar(
        "Error",
        "Assignments load nahi hue",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<String> _getAllChapters() {
    final Set<String> chapters = {};
    for (final examMap in allAssignments.values) {
      chapters.addAll(examMap.keys);
    }
    return chapters.toList();
  }

  String _normalizeTopic(String? topic) {
    final value = (topic ?? '').trim();
    return value.isEmpty ? 'General Topic' : value;
  }

  List<String> _getTopicsForChapter(String chapterName) {
    final Set<String> topics = {};

    for (final examMap in allAssignments.values) {
      final items = examMap[chapterName]?.assignments ?? <Assignment>[];
      for (final item in items) {
        topics.add(_normalizeTopic(item.assignmentTopic));
      }
    }

    return topics.toList();
  }

  String? _findExamKey(String target) {
    for (final key in allAssignments.keys) {
      final k = key.toLowerCase().replaceAll(' ', '');
      final t = target.toLowerCase().replaceAll(' ', '');

      if (k == t ||
          k.contains(t) ||
          t.contains(k) ||
          (target == 'Board' && k.contains('board')) ||
          (target == 'JEE Main' &&
              (k.contains('jeemain') ||
                  k.contains('jee(m)') ||
                  k.contains('jeem') ||
                  k.contains('main'))) ||
          (target == 'JEE Advanced' &&
              (k.contains('jeeadvanced') ||
                  k.contains('jee(a)') ||
                  k.contains('jeea') ||
                  k.contains('advanced')))) {
        return key;
      }
    }
    return null;
  }

  List<Assignment> _getAssignmentsFor(
    String examLabel,
    String chapterName,
    String topicName,
  ) {
    final examKey = _findExamKey(examLabel);
    if (examKey == null) return [];
    final items = allAssignments[examKey]?[chapterName]?.assignments ?? [];
    return items
        .where((item) => _normalizeTopic(item.assignmentTopic) == topicName)
        .toList();
  }

  List<List<Assignment>> _splitAssignmentsIntoRounds(List<Assignment> items) {
    if (items.isEmpty) return [[], [], []];

    final List<Assignment> round1 = [];
    final List<Assignment> round2 = [];
    final List<Assignment> round3 = [];

    for (int i = 0; i < items.length; i++) {
      if (i % 3 == 0) {
        round1.add(items[i]);
      } else if (i % 3 == 1) {
        round2.add(items[i]);
      } else {
        round3.add(items[i]);
      }
    }

    return [round1, round2, round3];
  }

  void _openAssignment(Assignment assignment, int index) {
    

    Get.offAllNamed(
      AdminRoutes.testscreen,
      arguments: {'testId': "85228368", 'passcode': "8689512515"},
    );
  }

  Color _examTone(String examLabel) {
    switch (examLabel) {
      case 'Board':
        return primary;
      case 'JEE Main':
        return const Color(0xFF1565C0);
      case 'JEE Advanced':
        return accent;
      default:
        return primary;
    }
  }

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
    bool isDarkMode,
  ) {
    if (assignments.isEmpty) {
      return Center(
        child: Container(
          width: 22.w,
          height: 1.5,
          color: isDarkMode ? Colors.white38 : tone.withOpacity(0.35),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.w,
      runSpacing: 8.h,
      children: List.generate(assignments.length, (index) {
        final bubbleFill = tone.withOpacity(isDarkMode ? 0.18 : 0.12);
        return _buildRoundBubble(
          text: "${index + 1}",
          onTap: () => _openAssignment(assignments[index], index),
          fillColor: bubbleFill,
          borderColor: tone,
          textColor: isDarkMode ? Colors.white : tone,
        );
      }),
    );
  }

  Widget _buildExamRow({
    required String examLabel,
    required String chapterName,
    required String topicName,
    required bool isDarkMode,
    bool showTopBorder = false,
  }) {
    final assignments = _getAssignmentsFor(examLabel, chapterName, topicName);
    final rounds = _splitAssignmentsIntoRounds(assignments);
    final tone = _examTone(examLabel);
    final dividerColor = isDarkMode
        ? Colors.white.withOpacity(0.14)
        : tone.withOpacity(0.16);

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
              width: 80.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: tone.withOpacity(isDarkMode ? 0.2 : 0.12),
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
              width: 80.w,
              child: _buildRoundCell(rounds[0], tone, isDarkMode),
            ),
            _divider(dividerColor),
            _cell(
              width: 80.w,
              child: _buildRoundCell(rounds[1], tone, isDarkMode),
            ),
            _divider(dividerColor),
            _cell(
              width: 80.w,
              child: _buildRoundCell(rounds[2], tone, isDarkMode),
            ),
          ],
        ),
      ),
    );
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

  Widget _divider(Color color) {
    return Container(width: 1, color: color);
  }

  Widget _buildTopicSection({
    required String chapterName,
    required String topicName,
    required bool isDarkMode,
    required bool showTopBorder,
  }) {
    final dividerColor = isDarkMode
        ? Colors.white.withOpacity(0.12)
        : primary.withOpacity(0.14);

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
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.04)
                  : primary.withOpacity(0.05),
            ),
            child: Text(
              topicName,
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF13305C),
                fontSize: 7.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                _cell(
                  width: 80.w,
                  child: Text(
                    'Exam',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _divider(dividerColor),
                _cell(
                  width: 80.w,
                  child: Text(
                    'Round 1',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _divider(dividerColor),
                _cell(
                  width: 80.w,
                  child: Text(
                    'Round 2',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _divider(dividerColor),
                _cell(
                  width: 80.w,
                  child: Text(
                    'Round 3',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: dividerColor),
          Column(
            children: List.generate(_examOrder.length, (index) {
              return _buildExamRow(
                examLabel: _examOrder[index],
                chapterName: chapterName,
                topicName: topicName,
                isDarkMode: isDarkMode,
                showTopBorder: index != 0,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterBlock(String chapterName, bool isDarkMode) {
    final topics = _getTopicsForChapter(chapterName);
    final dividerColor = isDarkMode
        ? Colors.white.withOpacity(0.12)
        : primary.withOpacity(0.14);

    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF141A24) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.24 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
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
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Chapter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 6.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    chapterName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${topics.length} Topic${topics.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: List.generate(topics.length, (index) {
              return _buildTopicSection(
                chapterName: chapterName,
                topicName: topics[index],
                isDarkMode: isDarkMode,
                showTopBorder: index != 0,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: primary,
          size: 42,
        ),
      );
    }

    final chapters = _getAllChapters();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (chapters.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Text(
            "No assignments available",
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
                width: 50.w + 90.w + 90.w + 90.w + 8.w,
                child: Column(
                  children: List.generate(chapters.length, (index) {
                    return _buildChapterBlock(chapters[index], isDarkMode);
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
              bottomLeft: Radius.circular(22.r),
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
                fontSize: 8.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Obx(
              () => Text(
                subjectname.value.isNotEmpty
                    ? "${subjectname.value} • ${classs.value.replaceAll('"', '').trim()}"
                    : "Continue your tests",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }
}

class ColorPainter {
  static const Color primaryColor = Color(0xFF0D47A1);
  static const Color secondaryColor = Color(0xFFFFA000);
  static const Color accentColor = Color(0xFF4CA1AF);

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
    boxShadow: [
      BoxShadow(
        offset: const Offset(0, 6),
        blurRadius: 12,
        color: Colors.black26,
      ),
    ],
    borderRadius: BorderRadius.circular(20),
  );

  static BoxDecoration get buttonBoxDecoration => BoxDecoration(
    gradient: buttonGradient,
    borderRadius: BorderRadius.circular(30),
  );
}
