class loginmodel {
  String? message;
  Data? data;
  int? statuscode;
  int? totalCount;

  loginmodel({this.message, this.data, this.statuscode, this.totalCount});

  loginmodel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    statuscode = json['statuscode'];
    totalCount = json['totalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['statuscode'] = this.statuscode;
    data['totalCount'] = this.totalCount;
    return data;
  }
}

class Data {
  int? studentId;
  String? admissionNo;
  String? studentName;
  String? session;
  int? courseId;
  String? courseName;
  int? schoolId;
  bool? isActive;
  String? createdDate;
  String? date;
  String? modifiedDate;
  int? createdby;
  int? updatedby;

  Data(
      {this.studentId,
      this.admissionNo,
      this.studentName,
      this.session,
      this.courseId,
      this.courseName,
      this.schoolId,
      this.isActive,
      this.createdDate,
      this.date,
      this.modifiedDate,
      this.createdby,
      this.updatedby});

  Data.fromJson(Map<String, dynamic> json) {
    studentId = json['StudentId'];
    admissionNo = json['AdmissionNo'];
    studentName = json['StudentName'];
    session = json['Session'];
    courseId = json['CourseId'];
    courseName = json['CourseName'];
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
    data['StudentId'] = this.studentId;
    data['AdmissionNo'] = this.admissionNo;
    data['StudentName'] = this.studentName;
    data['Session'] = this.session;
    data['CourseId'] = this.courseId;
    data['CourseName'] = this.courseName;
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