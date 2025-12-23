import 'package:hive/hive.dart';

part 'hivemodel.g.dart';

@HiveType(typeId: 0)
class Hivemodel extends HiveObject {
  @HiveField(0)
  int? questionId;  // Add this field

  @HiveField(1)
  String? subjectName;

  @HiveField(2)
  String? questions;

  @HiveField(3)
  String? optionA;

  @HiveField(4)
  String? ansOptionA;

  @HiveField(5)
  String? optionB;

  @HiveField(6)
  String? ansOptionB;

  @HiveField(7)
  String? optionC;

  @HiveField(8)
  String? ansOptionC;

  @HiveField(9)
  String? optionD;

  @HiveField(10)
  String? ansOptionD;

  @HiveField(11)
  String? optionCorrect;

  @HiveField(12)
  String? correctOptionText;

  @HiveField(13)
  String? questionRating;

  @HiveField(14)
  int? questionMarks;

  @HiveField(15)
  int? totalMinutes;

  @HiveField(16)
  String? schoolId;

  @HiveField(17)
  int? batchId;

  @HiveField(18)
  int? examTestId;
}