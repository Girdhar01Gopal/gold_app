class ResultModel {
  String? message;
  List<Data>? data;
  int? statuscode;
  int? totalCount;

  ResultModel({this.message, this.data, this.statuscode, this.totalCount});

  ResultModel.fromJson(Map<String, dynamic> json) {
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
  int? studentId;
  Null? registrationNo;
  Null? admissionNo;
  Null? studentName;
  Null? fatherName;
  Null? session;
  Null? courseName;
  int? questionId;
  String? subjectName;
  String? testId;
  String? questions;
  String? optionA;
  String? ansOptionA;
  String? optionB;
  String? ansOptionB;
  String? optionC;
  String? ansOptionC;
  String? optionD;
  String? ansOptionD;
  String? optionCorrect;
  String? correctOptionText;
  String? choiceOption;
  String? choiceOptionText;
  String? optionStatus;
  int? questionMarks;
  int? totalMinutes;
  int? totalQueMarks;
  int? totalCorrect;
  int? totalIncorrect;
  int? totalCorrectMarks;
  int? totalIncorrectMarks;
  int? totalNotAtempMarks;
  int? schoolId;
  int? batchId;
  int? examTestId;
  String? examDate;
  int? questionTestId;
  int? againExam;
  int? assigtChapterId;
  int? assigtTopicId;
  Null? assignmentChapter;
  Null? assignmentTopic;
  bool? isActive;
  String? createdDate;
  String? date;
  String? modifiedDate;
  int? createdby;
  int? updatedby;

  Data(
      {this.studentId,
      this.registrationNo,
      this.admissionNo,
      this.studentName,
      this.fatherName,
      this.session,
      this.courseName,
      this.questionId,
      this.subjectName,
      this.testId,
      this.questions,
      this.optionA,
      this.ansOptionA,
      this.optionB,
      this.ansOptionB,
      this.optionC,
      this.ansOptionC,
      this.optionD,
      this.ansOptionD,
      this.optionCorrect,
      this.correctOptionText,
      this.choiceOption,
      this.choiceOptionText,
      this.optionStatus,
      this.questionMarks,
      this.totalMinutes,
      this.totalQueMarks,
      this.totalCorrect,
      this.totalIncorrect,
      this.totalCorrectMarks,
      this.totalIncorrectMarks,
      this.totalNotAtempMarks,
      this.schoolId,
      this.batchId,
      this.examTestId,
      this.examDate,
      this.questionTestId,
      this.againExam,
      this.assigtChapterId,
      this.assigtTopicId,
      this.assignmentChapter,
      this.assignmentTopic,
      this.isActive,
      this.createdDate,
      this.date,
      this.modifiedDate,
      this.createdby,
      this.updatedby});

  Data.fromJson(Map<String, dynamic> json) {
    studentId = json['StudentId'];
    registrationNo = json['RegistrationNo'];
    admissionNo = json['AdmissionNo'];
    studentName = json['StudentName'];
    fatherName = json['FatherName'];
    session = json['Session'];
    courseName = json['CourseName'];
    questionId = json['QuestionId'];
    subjectName = json['SubjectName'];
    testId = json['TestId'];
    questions = json['Questions'];
    optionA = json['OptionA'];
    ansOptionA = json['AnsOptionA'];
    optionB = json['OptionB'];
    ansOptionB = json['AnsOptionB'];
    optionC = json['OptionC'];
    ansOptionC = json['AnsOptionC'];
    optionD = json['OptionD'];
    ansOptionD = json['AnsOptionD'];
    optionCorrect = json['OptionCorrect'];
    correctOptionText = json['CorrectOptionText'];
    choiceOption = json['ChoiceOption'];
    choiceOptionText = json['ChoiceOptionText'];
    optionStatus = json['OptionStatus'];
    questionMarks = json['QuestionMarks'];
    totalMinutes = json['TotalMinutes'];
    totalQueMarks = json['TotalQueMarks'];
    totalCorrect = json['TotalCorrect'];
    totalIncorrect = json['TotalIncorrect'];
    totalCorrectMarks = json['TotalCorrectMarks'];
    totalIncorrectMarks = json['TotalIncorrectMarks'];
    totalNotAtempMarks = json['TotalNotAtempMarks'];
    schoolId = json['SchoolId'];
    batchId = json['BatchId'];
    examTestId = json['ExamTestId'];
    examDate = json['ExamDate'];
    questionTestId = json['QuestionTestId'];
    againExam = json['AgainExam'];
    assigtChapterId = json['AssigtChapterId'];
    assigtTopicId = json['AssigtTopicId'];
    assignmentChapter = json['AssignmentChapter'];
    assignmentTopic = json['AssignmentTopic'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    date = json['Date'];
    modifiedDate = json['ModifiedDate'];
    createdby = json['Createdby'];
    updatedby = json['Updatedby'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['StudentId'] = this.studentId;
    data['RegistrationNo'] = this.registrationNo;
    data['AdmissionNo'] = this.admissionNo;
    data['StudentName'] = this.studentName;
    data['FatherName'] = this.fatherName;
    data['Session'] = this.session;
    data['CourseName'] = this.courseName;
    data['QuestionId'] = this.questionId;
    data['SubjectName'] = this.subjectName;
    data['TestId'] = this.testId;
    data['Questions'] = this.questions;
    data['OptionA'] = this.optionA;
    data['AnsOptionA'] = this.ansOptionA;
    data['OptionB'] = this.optionB;
    data['AnsOptionB'] = this.ansOptionB;
    data['OptionC'] = this.optionC;
    data['AnsOptionC'] = this.ansOptionC;
    data['OptionD'] = this.optionD;
    data['AnsOptionD'] = this.ansOptionD;
    data['OptionCorrect'] = this.optionCorrect;
    data['CorrectOptionText'] = this.correctOptionText;
    data['ChoiceOption'] = this.choiceOption;
    data['ChoiceOptionText'] = this.choiceOptionText;
    data['OptionStatus'] = this.optionStatus;
    data['QuestionMarks'] = this.questionMarks;
    data['TotalMinutes'] = this.totalMinutes;
    data['TotalQueMarks'] = this.totalQueMarks;
    data['TotalCorrect'] = this.totalCorrect;
    data['TotalIncorrect'] = this.totalIncorrect;
    data['TotalCorrectMarks'] = this.totalCorrectMarks;
    data['TotalIncorrectMarks'] = this.totalIncorrectMarks;
    data['TotalNotAtempMarks'] = this.totalNotAtempMarks;
    data['SchoolId'] = this.schoolId;
    data['BatchId'] = this.batchId;
    data['ExamTestId'] = this.examTestId;
    data['ExamDate'] = this.examDate;
    data['QuestionTestId'] = this.questionTestId;
    data['AgainExam'] = this.againExam;
    data['AssigtChapterId'] = this.assigtChapterId;
    data['AssigtTopicId'] = this.assigtTopicId;
    data['AssignmentChapter'] = this.assignmentChapter;
    data['AssignmentTopic'] = this.assignmentTopic;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['Date'] = this.date;
    data['ModifiedDate'] = this.modifiedDate;
    data['Createdby'] = this.createdby;
    data['Updatedby'] = this.updatedby;
    return data;
  }
}