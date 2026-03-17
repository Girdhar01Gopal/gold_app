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
  String? questionsimg;
  String? optionA;
  String? ansOptionA;
  String? ansOptionAimg;
  String? optionB;
  String? ansOptionB;
  String? ansOptionBimg;
  String? optionC;
  String? ansOptionC;
  String? ansOptionCimg;
  String? optionD;
  String? ansOptionD;
  String? ansOptionDimg;
  String? optionCorrect;
  String? correctOptionText;
  String? correctOptionImag;
  String? questionRating;
  int? questionMarks;
  int? totalMinutes;
  int? schoolId;
  int? batchId;
  int? examTestId;
  int? questionTestId;
  int? answerCount;
  String? negativeMarking;
  String? questionType;
  String? integerTypeCorrecrt;
  String? numericRangeCorrectAns;
  String? optionCorrectA;
  String? optionCorrectB;
  String? optionCorrectC;
  String? optionCorrectD;
  String? correctOptionTextA;
  String? correctOptionTextB;
  String? correctOptionTextC;
  String? correctOptionTextD;
  String? quesNegativeMarking;
  int? quesNegativeMarkingMarks;
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
      this.questionsimg,
      this.optionA,
      this.ansOptionA,
      this.ansOptionAimg,
      this.optionB,
      this.ansOptionB,
      this.ansOptionBimg,
      this.optionC,
      this.ansOptionC,
      this.ansOptionCimg,
      this.optionD,
      this.ansOptionD,
      this.ansOptionDimg,
      this.optionCorrect,
      this.correctOptionText,
      this.correctOptionImag,
      this.questionRating,
      this.questionMarks,
      this.totalMinutes,
      this.schoolId,
      this.batchId,
      this.examTestId,
      this.questionTestId,
      this.answerCount,
      this.negativeMarking,
      this.questionType,
      this.integerTypeCorrecrt,
      this.numericRangeCorrectAns,
      this.optionCorrectA,
      this.optionCorrectB,
      this.optionCorrectC,
      this.optionCorrectD,
      this.correctOptionTextA,
      this.correctOptionTextB,
      this.correctOptionTextC,
      this.correctOptionTextD,
      this.quesNegativeMarking,
      this.quesNegativeMarkingMarks,
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
    questionsimg = json['Questionsimg'];
    optionA = json['OptionA'];
    ansOptionA = json['AnsOptionA'];
    ansOptionAimg = json['AnsOptionAimg'];
    optionB = json['OptionB'];
    ansOptionB = json['AnsOptionB'];
    ansOptionBimg = json['AnsOptionBimg'];
    optionC = json['OptionC'];
    ansOptionC = json['AnsOptionC'];
    ansOptionCimg = json['AnsOptionCimg'];
    optionD = json['OptionD'];
    ansOptionD = json['AnsOptionD'];
    ansOptionDimg = json['AnsOptionDimg'];
    optionCorrect = json['OptionCorrect'];
    correctOptionText = json['CorrectOptionText'];
    correctOptionImag = json['CorrectOptionImag'];
    questionRating = json['QuestionRating'];
    questionMarks = json['QuestionMarks'];
    totalMinutes = json['TotalMinutes'];
    schoolId = json['SchoolId'];
    batchId = json['BatchId'];
    examTestId = json['ExamTestId'];
    questionTestId = json['QuestionTestId'];
    answerCount = json['AnswerCount'];
    negativeMarking = json['NegativeMarking'];
    questionType = json['QuestionType'];
    integerTypeCorrecrt = json['IntegerTypeCorrecrt'];
    numericRangeCorrectAns = json['NumericRangeCorrectAns'];
    optionCorrectA = json['OptionCorrectA'];
    optionCorrectB = json['OptionCorrectB'];
    optionCorrectC = json['OptionCorrectC'];
    optionCorrectD = json['OptionCorrectD'];
    correctOptionTextA = json['CorrectOptionTextA'];
    correctOptionTextB = json['CorrectOptionTextB'];
    correctOptionTextC = json['CorrectOptionTextC'];
    correctOptionTextD = json['CorrectOptionTextD'];
    quesNegativeMarking = json['QuesNegativeMarking'];
    quesNegativeMarkingMarks = json['QuesNegativeMarkingMarks'];
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
    data['Questionsimg'] = this.questionsimg;
    data['OptionA'] = this.optionA;
    data['AnsOptionA'] = this.ansOptionA;
    data['AnsOptionAimg'] = this.ansOptionAimg;
    data['OptionB'] = this.optionB;
    data['AnsOptionB'] = this.ansOptionB;
    data['AnsOptionBimg'] = this.ansOptionBimg;
    data['OptionC'] = this.optionC;
    data['AnsOptionC'] = this.ansOptionC;
    data['AnsOptionCimg'] = this.ansOptionCimg;
    data['OptionD'] = this.optionD;
    data['AnsOptionD'] = this.ansOptionD;
    data['AnsOptionDimg'] = this.ansOptionDimg;
    data['OptionCorrect'] = this.optionCorrect;
    data['CorrectOptionText'] = this.correctOptionText;
    data['CorrectOptionImag'] = this.correctOptionImag;
    data['QuestionRating'] = this.questionRating;
    data['QuestionMarks'] = this.questionMarks;
    data['TotalMinutes'] = this.totalMinutes;
    data['SchoolId'] = this.schoolId;
    data['BatchId'] = this.batchId;
    data['ExamTestId'] = this.examTestId;
    data['QuestionTestId'] = this.questionTestId;
    data['AnswerCount'] = this.answerCount;
    data['NegativeMarking'] = this.negativeMarking;
    data['QuestionType'] = this.questionType;
    data['IntegerTypeCorrecrt'] = this.integerTypeCorrecrt;
    data['NumericRangeCorrectAns'] = this.numericRangeCorrectAns;
    data['OptionCorrectA'] = this.optionCorrectA;
    data['OptionCorrectB'] = this.optionCorrectB;
    data['OptionCorrectC'] = this.optionCorrectC;
    data['OptionCorrectD'] = this.optionCorrectD;
    data['CorrectOptionTextA'] = this.correctOptionTextA;
    data['CorrectOptionTextB'] = this.correctOptionTextB;
    data['CorrectOptionTextC'] = this.correctOptionTextC;
    data['CorrectOptionTextD'] = this.correctOptionTextD;
    data['QuesNegativeMarking'] = this.quesNegativeMarking;
    data['QuesNegativeMarkingMarks'] = this.quesNegativeMarkingMarks;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['Date'] = this.date;
    data['ModifiedDate'] = this.modifiedDate;
    data['Createdby'] = this.createdby;
    data['Updatedby'] = this.updatedby;
    return data;
  }
}