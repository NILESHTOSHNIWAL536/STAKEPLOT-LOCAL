// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_insights_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardInsightsModelAdapter extends TypeAdapter<CardInsightsModel> {
  @override
  final int typeId = 17;

  @override
  CardInsightsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardInsightsModel(
      categoriesList: (fields[6] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, CardInsightsModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(6)
      ..write(obj.categoriesList);
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
