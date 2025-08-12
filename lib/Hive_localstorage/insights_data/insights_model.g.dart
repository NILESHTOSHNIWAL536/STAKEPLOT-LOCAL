// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InsightsModelAdapter extends TypeAdapter<InsightsModel> {
  @override
  final int typeId = 9;

  @override
  InsightsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InsightsModel(
      totalInSights: (fields[0] as List)
          .map((dynamic e) => (e as Map).map((dynamic k, dynamic v) =>
              MapEntry(k as String, (v as List).cast<String>())))
          .toList(),
      totalInSightsMoneyMap: (fields[1] as List)
          .map((dynamic e) => (e as Map).map((dynamic k, dynamic v) =>
              MapEntry(k as String, (v as List).cast<String>())))
          .toList(),
      lastUpdated: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, InsightsModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.totalInSights)
      ..writeByte(1)
      ..write(obj.totalInSightsMoneyMap)
      ..writeByte(2)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
