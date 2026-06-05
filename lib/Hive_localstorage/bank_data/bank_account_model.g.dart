// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_account_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BankAccountModelAdapter extends TypeAdapter<BankAccountModel> {
  @override
  final int typeId = 1;

  @override
  BankAccountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BankAccountModel(
      bankId: fields[0] as String,
      bankName: fields[1] as String,
      bankLogo: fields[2] as String,
      fipId: fields[3] as String,
      accountId: fields[4] as String,
      maskedAccNumber: fields[5] as String,
      type: fields[6] as String,
      currentBalance: fields[7] as String,
      lastFetch: fields[8] as String,
      nextFetch: fields[9] as String,
      fetchCount: fields[10] as String,
      consentId: fields[11] as String,
      consendHandleId: fields[12] as String,
      sessionId: fields[13] as String,
      custId: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BankAccountModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.bankId)
      ..writeByte(1)
      ..write(obj.bankName)
      ..writeByte(2)
      ..write(obj.bankLogo)
      ..writeByte(3)
      ..write(obj.fipId)
      ..writeByte(4)
      ..write(obj.accountId)
      ..writeByte(5)
      ..write(obj.maskedAccNumber)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.currentBalance)
      ..writeByte(8)
      ..write(obj.lastFetch)
      ..writeByte(9)
      ..write(obj.nextFetch)
      ..writeByte(10)
      ..write(obj.fetchCount)
      ..writeByte(11)
      ..write(obj.consentId)
      ..writeByte(12)
      ..write(obj.consendHandleId)
      ..writeByte(13)
      ..write(obj.sessionId)
      ..writeByte(14)
      ..write(obj.custId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankAccountModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
