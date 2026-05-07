import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gold_app/Model/assignmentmodel.dart';
import 'package:gold_app/appurl/adminurl.dart';
import 'package:gold_app/localstorage.dart';
import 'package:gold_app/prefconst.dart';
import 'package:http/http.dart' as http;

class _QuestionModeOption {
  const _QuestionModeOption({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;
}

class ContinueScreenController extends GetxController {
  // ── Reactive state ──────────────────────────────────────────
  final RxBool   isLoading   = true.obs;
  final RxString subjectId   = ''.obs;
  final RxString subjectname = ''.obs;
  final RxString classs      = ''.obs;
  final RxString schoolid    = ''.obs;
  final RxString studentid   = ''.obs;

  // ── Static config ───────────────────────────────────────────
  static const List<String> examOrder = ['CBSE', 'JEE M', 'JEE A'];

  static const List<_QuestionModeOption> questionModeOptions = [
    _QuestionModeOption(label: 'Set average time per Question 2 min', value: 'average'),
    _QuestionModeOption(label: 'Set average time per Question 3 min', value: 'medium'),
    _QuestionModeOption(label: 'Set average time per Question 5 min', value: 'hard', color: Color(0xFFFFA000)),
    _QuestionModeOption(label: 'No Time limit', value: 'no_limit'),
  ];

  /// chapterName -> topicName -> examType -> `List<Assignment>`
  ///
  /// JSON path:
  ///   data.AssignmentChapters.{chapter}.AssignmentTopics.{topic}.AssignmentExams.{examType}[...]
  final Map<String, Map<String, Map<String, List<Assignment>>>> allData = {};

  // ── Lifecycle ───────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    subjectId.value   = Get.arguments?['subjectId']?.toString()  ?? '';
    subjectname.value = Get.arguments?['subjectName']?.toString() ?? '';
    schoolid.value    = await PrefManager().readValue(key: PrefConst.SchoolId)  ?? '';
    studentid.value   = await PrefManager().readValue(key: PrefConst.StudentId) ?? '';
    classs.value      = await PrefManager().readValue(key: PrefConst.className) ?? '';
    await fetchAssignments();
  }

  // ── API ─────────────────────────────────────────────────────
  Future<void> fetchAssignments() async {
    try {
      isLoading.value = true;

      final url = '${Adminurl.assignment}/${schoolid.value}/${studentid.value}/${subjectId.value}';
      debugPrint('ContinueScreen URL: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _parseResponse(json);
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching assignments: $e');
      Get.snackbar('Error', 'Failed to load assignments', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Parses the nested JSON:
  ///   data.AssignmentChapters → {chapter} → AssignmentTopics → {topic} → AssignmentExams → {exam} → [...]
  void _parseResponse(Map<String, dynamic> json) {
    allData.clear();

    final chaptersRaw = json['data']?['AssignmentChapters'] as Map<String, dynamic>?;
    if (chaptersRaw == null) return;

    chaptersRaw.forEach((chapterName, chapterVal) {
      if (chapterVal is! Map<String, dynamic>) return;

      final topicsRaw = chapterVal['AssignmentTopics'] as Map<String, dynamic>?;
      if (topicsRaw == null) return;

      final Map<String, Map<String, List<Assignment>>> topicMap = {};

      topicsRaw.forEach((topicName, topicVal) {
        if (topicVal is! Map<String, dynamic>) return;

        final examsRaw = topicVal['AssignmentExams'] as Map<String, dynamic>?;
        if (examsRaw == null) return;

        final Map<String, List<Assignment>> examMap = {};

        examsRaw.forEach((examType, examData) {
          if (examData is List) {
            examMap[examType] = examData
                .whereType<Map<String, dynamic>>()
                .map((item) => Assignment.fromJson(item))
                .toList();
          }
        });

        if (examMap.isNotEmpty) topicMap[topicName] = examMap;
      });

      if (topicMap.isNotEmpty) allData[chapterName] = topicMap;
    });

    debugPrint('Parsed chapters: ${allData.keys.toList()}');
  }

  // ── Data helpers (called by the screen) ─────────────────────
  List<String> getAllChapters() => allData.keys.toList();

  List<String> getTopicsForChapter(String chapterName) =>
      allData[chapterName]?.keys.toList() ?? [];

  List<Assignment> getAssignmentsFor(
      String examLabel, String chapterName, String topicName) {
    final topicData = allData[chapterName]?[topicName];
    if (topicData == null) return [];

    final examKey = _findExamKey(examLabel, topicData.keys.toList());
    if (examKey == null) return [];

    return topicData[examKey] ?? [];
  }

  String? _findExamKey(String target, List<String> keys) {
    for (final key in keys) {
      final k = key.toLowerCase().replaceAll(' ', '');
      final t = target.toLowerCase().replaceAll(' ', '');
      if (k == t ||
          k.contains(t) ||
          t.contains(k) ||
          (target == 'CBSE'  && k.contains('board')) ||
          (target == 'Board' && k.contains('board')) ||
          (target == 'JEE M' && (k.contains('jeemain') || k.contains('jee(m)') || k.contains('jeem') || k.contains('main'))) ||
          (target == 'JEE A' && (k.contains('jeeadvanced') || k.contains('jee(a)') || k.contains('jeea') || k.contains('advanced')))) {
        return key;
      }
    }
    return null;
  }

  /// Splits assignments into [Scholar, Expert, Champion] columns
  /// based on the AssExamRound field (e.g. "Scholar-I", "Expert-II").
  List<List<Assignment>> splitAssignmentsIntoRounds(List<Assignment> items) {
    final List<Assignment> scholar  = [];
    final List<Assignment> expert   = [];
    final List<Assignment> champion = [];

    for (final item in items) {
      final round = (item.assExamRound ?? '').toLowerCase();
      if (round.contains('scholar')) {
        scholar.add(item);
      } else if (round.contains('expert')) {
        expert.add(item);
      } else if (round.contains('champion')) {
        champion.add(item);
      }
    }

    return [scholar, expert, champion];
  }
}
