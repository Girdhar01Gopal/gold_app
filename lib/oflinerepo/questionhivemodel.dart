import 'package:hive/hive.dart';

part 'questionhivemodel.g.dart';

@HiveType(typeId : 1)
class hivequestion{

    @HiveField(1)
    int? questionId;

    @HiveField(2)
    String? subjectName;

    @HiveField(3)
    String? testId;

    @HiveField(4)
    String? questions;

    @HiveField(5)
    String? optionA;

    @HiveField(6)
    String? ansOptionA;

    @HiveField(7)
    String? optionB;  

    @HiveField(8)
    String? ansOptionB;

    @HiveField(9)
    String? optionC;    

    @HiveField(10)
    String? ansOptionC;

    @HiveField(11)
    String? optionD;  

    @HiveField(12)
    String? ansOptionD;

    @HiveField(13)
    String? optionCorrect;

    @HiveField(14)
    String? correctOptionText;

    @HiveField(15)
    String? questionRating;

    @HiveField(16)
    int? questionMarks;

    @HiveField(17)
    int? totalMinutes;

    @HiveField(18)
    int? batchId;

    @HiveField(19)
    int? examTestId;



    @HiveField(20)
String? questionsimg;

@HiveField(21)
String? ansOptionAimg;

@HiveField(22)
String? ansOptionBimg;

@HiveField(23)
String? ansOptionCimg;

@HiveField(24)
String? ansOptionDimg;

@HiveField(25)
String? negativeMarking;

@HiveField(26)
String? questionType;

@HiveField(27)
String? integerTypeCorrecrt;

@HiveField(28)
String? numericRangeCorrectAns;

@HiveField(29)
String? optionCorrectA;

@HiveField(30)
String? optionCorrectB;

@HiveField(31)
String? optionCorrectC;

@HiveField(32)
String? optionCorrectD;

@HiveField(33)
String? correctOptionTextA;

@HiveField(34)
String? correctOptionTextB;

@HiveField(35)
String? correctOptionTextC;

@HiveField(36)
String? correctOptionTextD;

@HiveField(37)
String? quesNegativeMarking;
@HiveField(38)
int? quesNegativeMarkingMarks;
 // you already have this but keep consistent

    // Getter for compatibility: returns questionsimg as questionImg
    String? get questionImg => questionsimg;
}