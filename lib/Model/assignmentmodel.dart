class SubjectResponse {
  String? message;
  Data? data;
  int? statuscode;
  int? totalCount;

  SubjectResponse({this.message, this.data, this.statuscode, this.totalCount});

  SubjectResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    statuscode = json['statuscode'];
    totalCount = json['totalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    if (this.data != null) data['data'] = this.data!.toJson();
    data['statuscode'] = statuscode;
    data['totalCount'] = totalCount;
    return data;
  }
}

// ── Top-level data wrapper ─────────────────────────────────────────────────
class Data {
  AssignmentExam? assignmentExam;

  Data({this.assignmentExam});

  Data.fromJson(Map<String, dynamic> json) {
    assignmentExam = json['AssignmentExam'] != null
        ? AssignmentExam.fromJson(json['AssignmentExam'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (assignmentExam != null) data['AssignmentExam'] = assignmentExam!.toJson();
    return data;
  }
}

// ── Exam map: dynamic keys like "CBSE", "JEE Main", etc. ──────────────────
// Parsed manually in the controller via forEach; stored as
//   examType -> AssignmentChapterMap
class AssignmentExam {
  final Map<String, AssignmentChapterMap> exams;

  AssignmentExam({required this.exams});

  factory AssignmentExam.fromJson(Map<String, dynamic> json) {
    final map = <String, AssignmentChapterMap>{};
    json.forEach((examType, examData) {
      if (examData is Map<String, dynamic>) {
        map[examType] = AssignmentChapterMap.fromJson(examData);
      }
    });
    return AssignmentExam(exams: map);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    exams.forEach((key, val) => data[key] = val.toJson());
    return data;
  }
}

// ── Chapter map: dynamic keys like "Chapter 1", "Chapter 2", etc. ─────────
class AssignmentChapterMap {
  final Map<String, List<Assignment>> chapters;

  AssignmentChapterMap({required this.chapters});

  factory AssignmentChapterMap.fromJson(Map<String, dynamic> json) {
    final map = <String, List<Assignment>>{};
    final raw = json['AssignmentChapters'];
    if (raw is Map<String, dynamic>) {
      raw.forEach((chapterName, chapterData) {
        if (chapterData is List) {
          map[chapterName] = chapterData
              .whereType<Map<String, dynamic>>()
              .map((item) => Assignment.fromJson(item))
              .toList();
        }
      });
    }
    return AssignmentChapterMap(chapters: map);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    chapters.forEach((key, val) => data[key] = val.map((a) => a.toJson()).toList());
    return {'AssignmentChapters': data};
  }
}

// ── Unified assignment leaf node (same fields for CBSE, JEE Main, etc.) ───
class Assignment {
  String? assignmentTopic;
  String? assignmentExam;
  String? testId;
  String? testName;
  String? assExamRound;
  String? status;
  String? aStatus;
  String? testTotalMarks;
  int? totalMinutes;
  int? assigtChapterId;
  int? assigtTopicId;
  int? subjectId;
  int? questionTestId;
  String? assignmentChapter;
  String? subjectName;

  Assignment({
    this.assignmentTopic,
    this.assignmentExam,
    this.testId,
    this.testName,
    this.assExamRound,
    this.status,
    this.aStatus,
    this.testTotalMarks,
    this.totalMinutes,
    this.assigtChapterId,
    this.assigtTopicId,
    this.subjectId,
    this.questionTestId,
    this.assignmentChapter,
    this.subjectName,
  });

  Assignment.fromJson(Map<String, dynamic> json) {
    assignmentTopic = json['AssignmentTopic'];
    assignmentExam  = json['AssignmentExam'];
    testId          = json['TestId'];
    testName        = json['TestName'];
    assExamRound    = json['AssExamRound'];
    status          = json['Status'];
    aStatus         = json['AStatus'];
    testTotalMarks  = json['TestTotalMarks'];
    totalMinutes    = json['TotalMinutes'];
    assigtChapterId = json['AssigtChapterId'];
    assigtTopicId   = json['AssigtTopicId'];
    subjectId       = json['SubjectId'];
    questionTestId  = json['QuestionTestId'];
    assignmentChapter = json['AssignmentChapter'];
    subjectName     = json['SubjectName'];
  }

  Map<String, dynamic> toJson() => {
    'AssignmentTopic':  assignmentTopic,
    'AssignmentExam':   assignmentExam,
    'TestId':           testId,
    'TestName':         testName,
    'AssExamRound':     assExamRound,
    'Status':           status,
    'AStatus':          aStatus,
    'TestTotalMarks':   testTotalMarks,
    'TotalMinutes':     totalMinutes,
    'AssigtChapterId':  assigtChapterId,
    'AssigtTopicId':    assigtTopicId,
    'SubjectId':        subjectId,
    'QuestionTestId':   questionTestId,
    'AssignmentChapter': assignmentChapter,
    'SubjectName':      subjectName,
  };
}

// ── Legacy wrapper kept for backward compat with AssignmentChapters refs ───
class AssignmentChapters {
  List<Assignment>? assignments;

  AssignmentChapters({this.assignments});
}
