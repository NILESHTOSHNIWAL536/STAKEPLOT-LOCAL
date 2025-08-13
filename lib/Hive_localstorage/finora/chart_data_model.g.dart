// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChartDataModelAdapter extends TypeAdapter<ChartDataModel> {
  @override
  final int typeId = 10;

  @override
  ChartDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChartDataModel(
      category: fields[0] as String,
      percentage: fields[1] as String,
      value: fields[2] as double,
      color: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChartDataModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.percentage)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
