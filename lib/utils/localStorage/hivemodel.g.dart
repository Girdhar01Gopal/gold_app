// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hivemodel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HivemodelAdapter extends TypeAdapter<Hivemodel> {
  @override
  final int typeId = 0;

  @override
  Hivemodel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Hivemodel()
      ..questionId = fields[0] as int?
      ..subjectName = fields[1] as String?
      ..questions = fields[2] as String?
      ..optionA = fields[3] as String?
      ..ansOptionA = fields[4] as String?
      ..optionB = fields[5] as String?
      ..ansOptionB = fields[6] as String?
      ..optionC = fields[7] as String?
      ..ansOptionC = fields[8] as String?
      ..optionD = fields[9] as String?
      ..ansOptionD = fields[10] as String?
      ..optionCorrect = fields[11] as String?
      ..correctOptionText = fields[12] as String?
      ..questionRating = fields[13] as String?
      ..questionMarks = fields[14] as int?
      ..totalMinutes = fields[15] as int?
      ..schoolId = fields[16] as String?
      ..batchId = fields[17] as int?
      ..examTestId = fields[18] as int?;
  }

  @override
  void write(BinaryWriter writer, Hivemodel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.questionId)
      ..writeByte(1)
      ..write(obj.subjectName)
      ..writeByte(2)
      ..write(obj.questions)
      ..writeByte(3)
      ..write(obj.optionA)
      ..writeByte(4)
      ..write(obj.ansOptionA)
      ..writeByte(5)
      ..write(obj.optionB)
      ..writeByte(6)
      ..write(obj.ansOptionB)
      ..writeByte(7)
      ..write(obj.optionC)
      ..writeByte(8)
      ..write(obj.ansOptionC)
      ..writeByte(9)
      ..write(obj.optionD)
      ..writeByte(10)
      ..write(obj.ansOptionD)
      ..writeByte(11)
      ..write(obj.optionCorrect)
      ..writeByte(12)
      ..write(obj.correctOptionText)
      ..writeByte(13)
      ..write(obj.questionRating)
      ..writeByte(14)
      ..write(obj.questionMarks)
      ..writeByte(15)
      ..write(obj.totalMinutes)
      ..writeByte(16)
      ..write(obj.schoolId)
      ..writeByte(17)
      ..write(obj.batchId)
      ..writeByte(18)
      ..write(obj.examTestId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HivemodelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
