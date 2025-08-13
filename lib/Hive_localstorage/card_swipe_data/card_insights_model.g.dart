// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_insights_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardInsightsModelAdapter extends TypeAdapter<CardInsightsModel> {
  @override
  final int typeId = 11;

  @override
  CardInsightsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardInsightsModel(
      totalDebitThisMonth: fields[0] as double,
      totalDebitThisWeek: fields[1] as double,
      moreDrasticChange: (fields[2] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      moreDrasticChangeWeek: (fields[3] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      frequentPayments: (fields[4] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      frequentPaymentsWeek: (fields[5] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, CardInsightsModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.totalDebitThisMonth)
      ..writeByte(1)
      ..write(obj.totalDebitThisWeek)
      ..writeByte(2)
      ..write(obj.moreDrasticChange)
      ..writeByte(3)
      ..write(obj.moreDrasticChangeWeek)
      ..writeByte(4)
      ..write(obj.frequentPayments)
      ..writeByte(5)
      ..write(obj.frequentPaymentsWeek);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardInsightsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
