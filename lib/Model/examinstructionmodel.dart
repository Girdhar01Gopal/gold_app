class instructionexam {
  String? message;
  List<Data>? data;
  int? statuscode;
  int? totalCount;

  instructionexam({this.message, this.data, this.statuscode, this.totalCount});

  instructionexam.fromJson(Map<String, dynamic> json) {
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
  int? testExamInstId;
  int? batchId;
  Null? batchName;
  int? sessionId;
  Null? sessionName;
  int? subjectId;
  String? subjectName;
  int? courseId;
  Null? courseName;
  int? examTestId;
  String? testId;
  Null? testName;
  String? examInstruction;
  Null? action;
  Null? createBy;
  Null? updateBy;
  String? createDate;
  int? schoolId;
  int? assInstId;
  bool? isActive;
  String? createdDate;
  String? date;
  String? modifiedDate;
  int? createdby;
  int? updatedby;

  Data(
      {this.testExamInstId,
      this.batchId,
      this.batchName,
      this.sessionId,
      this.sessionName,
      this.subjectId,
      this.subjectName,
      this.courseId,
      this.courseName,
      this.examTestId,
      this.testId,
      this.testName,
      this.examInstruction,
      this.action,
      this.createBy,
      this.updateBy,
      this.createDate,
      this.schoolId,
      this.assInstId,
      this.isActive,
      this.createdDate,
      this.date,
      this.modifiedDate,
      this.createdby,
      this.updatedby});

  Data.fromJson(Map<String, dynamic> json) {
    testExamInstId = json['TestExamInstId'];
    batchId = json['BatchId'];
    batchName = json['BatchName'];
    sessionId = json['SessionId'];
    sessionName = json['SessionName'];
    subjectId = json['SubjectId'];
    subjectName = json['SubjectName'];
    courseId = json['CourseId'];
    courseName = json['CourseName'];
    examTestId = json['ExamTestId'];
    testId = json['TestId'];
    testName = json['TestName'];
    examInstruction = json['ExamInstruction'];
    action = json['Action'];
    createBy = json['CreateBy'];
    updateBy = json['UpdateBy'];
    createDate = json['CreateDate'];
    schoolId = json['SchoolId'];
    assInstId = json['AssInstId'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    date = json['Date'];
    modifiedDate = json['ModifiedDate'];
    createdby = json['Createdby'];
    updatedby = json['Updatedby'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TestExamInstId'] = this.testExamInstId;
    data['BatchId'] = this.batchId;
    data['BatchName'] = this.batchName;
    data['SessionId'] = this.sessionId;
    data['SessionName'] = this.sessionName;
    data['SubjectId'] = this.subjectId;
    data['SubjectName'] = this.subjectName;
    data['CourseId'] = this.courseId;
    data['CourseName'] = this.courseName;
    data['ExamTestId'] = this.examTestId;
    data['TestId'] = this.testId;
    data['TestName'] = this.testName;
    data['ExamInstruction'] = this.examInstruction;
    data['Action'] = this.action;
    data['CreateBy'] = this.createBy;
    data['UpdateBy'] = this.updateBy;
    data['CreateDate'] = this.createDate;
    data['SchoolId'] = this.schoolId;
    data['AssInstId'] = this.assInstId;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['Date'] = this.date;
    data['ModifiedDate'] = this.modifiedDate;
    data['Createdby'] = this.createdby;
    data['Updatedby'] = this.updatedby;
    return data;
  }
}