// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinanceModelAdapter extends TypeAdapter<FinanceModel> {
  @override
  final int typeId = 8;

  @override
  FinanceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinanceModel(
      period: fields[0] as String,
      startDate: fields[1] as String,
      endDate: fields[2] as String?,
      labels: (fields[3] as List).cast<String>(),
      debited: (fields[4] as List).cast<double>(),
      credited: (fields[5] as List).cast<double>(),
      totalDebitValue: fields[6] as double,
      totalDebitValuePercent: fields[7] as double,
      maxYValue: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, FinanceModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.period)
      ..writeByte(1)
      ..write(obj.startDate)
      ..writeByte(2)
      ..write(obj.endDate)
      ..writeByte(3)
      ..write(obj.labels)
      ..writeByte(4)
      ..write(obj.debited)
      ..writeByte(5)
      ..write(obj.credited)
      ..writeByte(6)
      ..write(obj.totalDebitValue)
      ..writeByte(7)
      ..write(obj.totalDebitValuePercent)
      ..writeByte(8)
      ..write(obj.maxYValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
