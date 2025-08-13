// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finora_last_two_months_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinoraLastTwoMonthsModelAdapter
    extends TypeAdapter<FinoraLastTwoMonthsModel> {
  @override
  final int typeId = 19;

  @override
  FinoraLastTwoMonthsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinoraLastTwoMonthsModel(
      month1Name: fields[0] as String?,
      month2Name: fields[1] as String?,
      month1Avg: fields[2] as double?,
      month2Avg: fields[3] as double?,
      month1DailySums: (fields[4] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      month2DailySums: (fields[5] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, FinoraLastTwoMonthsModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.month1Name)
      ..writeByte(1)
      ..write(obj.month2Name)
      ..writeByte(2)
      ..write(obj.month1Avg)
      ..writeByte(3)
      ..write(obj.month2Avg)
      ..writeByte(4)
      ..write(obj.month1DailySums)
      ..writeByte(5)
      ..write(obj.month2DailySums);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinoraLastTwoMonthsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
