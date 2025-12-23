class SubjectResponse {
  String? message;
  Data? data;
  int? statusCode;
  int? totalCount;

  SubjectResponse({this.message, this.data, this.statusCode, this.totalCount});

  SubjectResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    statusCode = json['statuscode'];
    totalCount = json['totalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['statuscode'] = this.statusCode;
    data['totalCount'] = this.totalCount;
    return data;
  }
}

class Data {
  AssignmentExam? assignmentExam;
  bool? isActive;
  String? createdDate;
  String? date;
  String? modifiedDate;
  int? createdBy;
  int? updatedBy;

  Data({
    this.assignmentExam,
    this.isActive,
    this.createdDate,
    this.date,
    this.modifiedDate,
    this.createdBy,
    this.updatedBy,
  });

  Data.fromJson(Map<String, dynamic> json) {
    assignmentExam = json['AssignmentExam'] != null
        ? AssignmentExam.fromJson(json['AssignmentExam'])
        : null;
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    date = json['Date'];
    modifiedDate = json['ModifiedDate'];
    createdBy = json['Createdby'];
    updatedBy = json['Updatedby'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.assignmentExam != null) {
      data['AssignmentExam'] = this.assignmentExam!.toJson();
    }
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['Date'] = this.date;
    data['ModifiedDate'] = this.modifiedDate;
    data['Createdby'] = this.createdBy;
    data['Updatedby'] = this.updatedBy;
    return data;
  }
}

class AssignmentExam {
  Map<String, AssignmentChapters>? assignmentChapters;

  AssignmentExam({this.assignmentChapters});

  AssignmentExam.fromJson(Map<String, dynamic> json) {
    if (json['JEE Advanced'] != null) {
      assignmentChapters = <String, AssignmentChapters>{};
      json['JEE Advanced']['AssignmentChapters'].forEach((key, value) {
        assignmentChapters![key] = AssignmentChapters.fromJson(value);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.assignmentChapters != null) {
      data['AssignmentChapters'] =
          this.assignmentChapters!.map((key, value) => MapEntry(key, value.toJson()));
    }
    return data;
  }
}

class AssignmentChapters {
  List<Assignment>? assignments;

  AssignmentChapters({this.assignments});

  AssignmentChapters.fromJson(List<dynamic> json) {
    assignments = json.map((v) => Assignment.fromJson(v as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.assignments != null) {
      data['assignments'] = this.assignments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Assignment {
  String? assignmentTopic;
  String? testId;
  String? testName;
  String? status;
  String? aStatus;
  String? testTotalMarks;
  int? totalMinutes;
  int? assigtChapterId;
  int? assigtTopicId;
  int? subjectId;
  String? assignmentChapter;
  String? subjectName;

  Assignment({
    this.assignmentTopic,
    this.testId,
    this.testName,
    this.status,
    this.aStatus,
    this.testTotalMarks,
    this.totalMinutes,
    this.assigtChapterId,
    this.assigtTopicId,
    this.subjectId,
    this.assignmentChapter,
    this.subjectName,
  });

  Assignment.fromJson(Map<String, dynamic> json) {
    assignmentTopic = json['AssignmentTopic'];
    testId = json['TestId'];
    testName = json['TestName'];
    status = json['Status'];
    aStatus = json['AStatus'];
    testTotalMarks = json['TestTotalMarks'];
    totalMinutes = json['TotalMinutes'];
    assigtChapterId = json['AssigtChapterId'];
    assigtTopicId = json['AssigtTopicId'];
    subjectId = json['SubjectId'];
    assignmentChapter = json['AssignmentChapter'];
    subjectName = json['SubjectName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AssignmentTopic'] = this.assignmentTopic;
    data['TestId'] = this.testId;
    data['TestName'] = this.testName;
    data['Status'] = this.status;
    data['AStatus'] = this.aStatus;
    data['TestTotalMarks'] = this.testTotalMarks;
    data['TotalMinutes'] = this.totalMinutes;
    data['AssigtChapterId'] = this.assigtChapterId;
    data['AssigtTopicId'] = this.assigtTopicId;
    data['SubjectId'] = this.subjectId;
    data['AssignmentChapter'] = this.assignmentChapter;
    data['SubjectName'] = this.subjectName;
    return data;
  }
}
