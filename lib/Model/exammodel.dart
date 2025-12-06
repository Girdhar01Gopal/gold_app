class exammodel {
  String? message;
  List<Data>? data;
  int? statuscode;
  int? totalCount;

  exammodel({this.message, this.data, this.statuscode, this.totalCount});

  exammodel.fromJson(Map<String, dynamic> json) {
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
  int? schoolId;
  bool? isActive;
  String? createdDate;
  String? date;
  String? modifiedDate;
  int? createdby;
  int? updatedby;

  Data(
      {this.questionId,
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
      this.schoolId,
      this.isActive,
      this.createdDate,
      this.date,
      this.modifiedDate,
      this.createdby,
      this.updatedby});

  Data.fromJson(Map<String, dynamic> json) {
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
    schoolId = json['SchoolId'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    date = json['Date'];
    modifiedDate = json['ModifiedDate'];
    createdby = json['Createdby'];
    updatedby = json['Updatedby'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    data['SchoolId'] = this.schoolId;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['Date'] = this.date;
    data['ModifiedDate'] = this.modifiedDate;
    data['Createdby'] = this.createdby;
    data['Updatedby'] = this.updatedby;
    return data;
  }
}