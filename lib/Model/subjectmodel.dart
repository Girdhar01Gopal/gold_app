class subjectmodel {
  String? message;
  List<Data>? data;
  int? statuscode;
  int? totalCount;

  subjectmodel({this.message, this.data, this.statuscode, this.totalCount});

  subjectmodel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    statuscode = json['statuscode'];
    totalCount = json['totalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['statuscode'] = this.statuscode;
    data['totalCount'] = this.totalCount;
    return data;
  }
}

class Data {
  Null? assignmentExam;
  Null? assignmentChapter;
  Null? assignmentTopic;
  String? subjectName;
  Null? testId;
  Null? testName;
  Null? status;
  Null? aStatus;
  Null? testTotalMarks;
  int? totalMinutes;
  int? assigtChapterId;
  int? assigtTopicId;
  int? subjectId;
  bool? isActive;
  String? createdDate;
  String? date;
  String? modifiedDate;
  int? createdby;
  int? updatedby;

  Data(
      {this.assignmentExam,
      this.assignmentChapter,
      this.assignmentTopic,
      this.subjectName,
      this.testId,
      this.testName,
      this.status,
      this.aStatus,
      this.testTotalMarks,
      this.totalMinutes,
      this.assigtChapterId,
      this.assigtTopicId,
      this.subjectId,
      this.isActive,
      this.createdDate,
      this.date,
      this.modifiedDate,
      this.createdby,
      this.updatedby});

  Data.fromJson(Map<String, dynamic> json) {
    assignmentExam = json['AssignmentExam'];
    assignmentChapter = json['AssignmentChapter'];
    assignmentTopic = json['AssignmentTopic'];
    subjectName = json['SubjectName'];
    testId = json['TestId'];
    testName = json['TestName'];
    status = json['Status'];
    aStatus = json['AStatus'];
    testTotalMarks = json['TestTotalMarks'];
    totalMinutes = json['TotalMinutes'];
    assigtChapterId = json['AssigtChapterId'];
    assigtTopicId = json['AssigtTopicId'];
    subjectId = json['SubjectId'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    date = json['Date'];
    modifiedDate = json['ModifiedDate'];
    createdby = json['Createdby'];
    updatedby = json['Updatedby'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AssignmentExam'] = this.assignmentExam;
    data['AssignmentChapter'] = this.assignmentChapter;
    data['AssignmentTopic'] = this.assignmentTopic;
    data['SubjectName'] = this.subjectName;
    data['TestId'] = this.testId;
    data['TestName'] = this.testName;
    data['Status'] = this.status;
    data['AStatus'] = this.aStatus;
    data['TestTotalMarks'] = this.testTotalMarks;
    data['TotalMinutes'] = this.totalMinutes;
    data['AssigtChapterId'] = this.assigtChapterId;
    data['AssigtTopicId'] = this.assigtTopicId;
    data['SubjectId'] = this.subjectId;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['Date'] = this.date;
    data['ModifiedDate'] = this.modifiedDate;
    data['Createdby'] = this.createdby;
    data['Updatedby'] = this.updatedby;
    return data;
  }
}