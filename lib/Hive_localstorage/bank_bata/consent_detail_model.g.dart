// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_detail_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConsentDetailModelAdapter extends TypeAdapter<ConsentDetailModel> {
  @override
  final int typeId = 2;

  @override
  ConsentDetailModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConsentDetailModel(
      consentId: fields[0] as String,
      consendHandleId: fields[1] as String,
      sessionId: fields[2] as String,
      custId: fields[3] as String,
      lastFetch: fields[4] as String,
      nextFetch: fields[5] as String,
      fetchCount: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ConsentDetailModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.consentId)
      ..writeByte(1)
      ..write(obj.consendHandleId)
      ..writeByte(2)
      ..write(obj.sessionId)
      ..writeByte(3)
      ..write(obj.custId)
      ..writeByte(4)
      ..write(obj.lastFetch)
      ..writeByte(5)
      ..write(obj.nextFetch)
      ..writeByte(6)
      ..write(obj.fetchCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsentDetailModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
