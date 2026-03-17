// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionhivemodel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class hivequestionAdapter extends TypeAdapter<hivequestion> {
  @override
  final int typeId = 1;

  @override
  hivequestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return hivequestion()
      ..questionId = fields[1] as int?
      ..subjectName = fields[2] as String?
      ..testId = fields[3] as String?
      ..questions = fields[4] as String?
      ..optionA = fields[5] as String?
      ..ansOptionA = fields[6] as String?
      ..optionB = fields[7] as String?
      ..ansOptionB = fields[8] as String?
      ..optionC = fields[9] as String?
      ..ansOptionC = fields[10] as String?
      ..optionD = fields[11] as String?
      ..ansOptionD = fields[12] as String?
      ..optionCorrect = fields[13] as String?
      ..correctOptionText = fields[14] as String?
      ..questionRating = fields[15] as String?
      ..questionMarks = fields[16] as int?
      ..totalMinutes = fields[17] as int?
      ..batchId = fields[18] as int?
      ..examTestId = fields[19] as int?
      ..questionsimg = fields[20] as String?
      ..ansOptionAimg = fields[21] as String?
      ..ansOptionBimg = fields[22] as String?
      ..ansOptionCimg = fields[23] as String?
      ..ansOptionDimg = fields[24] as String?
      ..negativeMarking = fields[25] as String?
      ..questionType = fields[26] as String?
      ..integerTypeCorrecrt = fields[27] as String?
      ..numericRangeCorrectAns = fields[28] as String?
      ..optionCorrectA = fields[29] as String?
      ..optionCorrectB = fields[30] as String?
      ..optionCorrectC = fields[31] as String?
      ..optionCorrectD = fields[32] as String?
      ..correctOptionTextA = fields[33] as String?
      ..correctOptionTextB = fields[34] as String?
      ..correctOptionTextC = fields[35] as String?
      ..correctOptionTextD = fields[36] as String?
      ..quesNegativeMarking = fields[37] as String?
      ..quesNegativeMarkingMarks = fields[38] as int?;
      
      
  }

  @override
  void write(BinaryWriter writer, hivequestion obj) {
    writer
      ..writeByte(24)
      ..writeByte(1)
      ..write(obj.questionId)
      ..writeByte(2)
      ..write(obj.subjectName)
      ..writeByte(3)
      ..write(obj.testId)
      ..writeByte(4)
      ..write(obj.questions)
      ..writeByte(5)
      ..write(obj.optionA)
      ..writeByte(6)
      ..write(obj.ansOptionA)
      ..writeByte(7)
      ..write(obj.optionB)
      ..writeByte(8)
      ..write(obj.ansOptionB)
      ..writeByte(9)
      ..write(obj.optionC)
      ..writeByte(10)
      ..write(obj.ansOptionC)
      ..writeByte(11)
      ..write(obj.optionD)
      ..writeByte(12)
      ..write(obj.ansOptionD)
      ..writeByte(13)
      ..write(obj.optionCorrect)
      ..writeByte(14)
      ..write(obj.correctOptionText)
      ..writeByte(15)
      ..write(obj.questionRating)
      ..writeByte(16)
      ..write(obj.questionMarks)
      ..writeByte(17)
      ..write(obj.totalMinutes)
      ..writeByte(18)
      ..write(obj.batchId)
      ..writeByte(19)
      ..write(obj.examTestId)
      ..writeByte(20)
      ..write(obj.questionsimg)
      ..writeByte(21)
      ..write(obj.ansOptionAimg)
      ..writeByte(22)
      ..write(obj.ansOptionBimg)
      ..writeByte(23)
      ..write(obj.ansOptionCimg)
      ..writeByte(24)
      ..write(obj.ansOptionDimg)
      ..writeByte(25)
      ..write(obj.negativeMarking)
      ..writeByte(26)
      ..write(obj.questionType)
      ..writeByte(27)
      ..write(obj.integerTypeCorrecrt)
      ..writeByte(28)
      ..write(obj.numericRangeCorrectAns)
      ..writeByte(29)
      ..write(obj.optionCorrectA)
      ..writeByte(30)
      ..write(obj.optionCorrectB)
      ..writeByte(31)
      ..write(obj.optionCorrectC)
      ..writeByte(32)
      ..write(obj.optionCorrectD)
      ..writeByte(33)
      ..write(obj.correctOptionTextA)
      ..writeByte(34)
      ..write(obj.correctOptionTextB)
      ..writeByte(35)
      ..write(obj.correctOptionTextC)
      ..writeByte(36)
      ..write(obj.correctOptionTextD)
      ..writeByte(37)
      ..write(obj.quesNegativeMarking)
        ..writeByte(38)
          ..write(obj.quesNegativeMarkingMarks);    
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is hivequestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
