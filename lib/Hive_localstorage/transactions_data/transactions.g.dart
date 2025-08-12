// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionsAdapter extends TypeAdapter<Transactions> {
  @override
  final int typeId = 7;

  @override
  Transactions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transactions(
      id: fields[0] as String,
      type: fields[1] as String,
      mode: fields[2] as String,
      amount: fields[3] as double,
      currentBalance: fields[5] as double,
      transactionTimestamp: fields[6] as DateTime,
      txnId: fields[7] as String?,
      narration: fields[8] as String,
      reference: fields[9] as String,
      title: fields[10] as String,
      manualTransaction: fields[11] as bool,
      category: fields[12] as String,
      subcategory: fields[13] as String,
      hidden: fields[14] as bool,
      isBill: fields[15] as bool,
      isDebt: fields[16] as bool,
      isSplit: fields[17] as bool,
      needsReview: fields[19] as bool?,
      isAutoPay: fields[20] as bool?,
      autoPayId: fields[21] as String?,
      merchant: fields[22] as String?,
      expectedFrequency: fields[23] as String?,
      userId: fields[24] as String?,
      accountId: fields[25] as String?,
      bankId: fields[26] as String?,
      bankName: fields[27] as String?,
      bankLogo: fields[28] as String?,
      v: fields[29] as int?,
      isBalanceOut: fields[18] as bool?,
      balanceOut: fields[4] as double?,
      isExcluded: fields[30] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Transactions obj) {
    writer
      ..writeByte(31)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.mode)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.balanceOut)
      ..writeByte(5)
      ..write(obj.currentBalance)
      ..writeByte(6)
      ..write(obj.transactionTimestamp)
      ..writeByte(7)
      ..write(obj.txnId)
      ..writeByte(8)
      ..write(obj.narration)
      ..writeByte(9)
      ..write(obj.reference)
      ..writeByte(10)
      ..write(obj.title)
      ..writeByte(11)
      ..write(obj.manualTransaction)
      ..writeByte(12)
      ..write(obj.category)
      ..writeByte(13)
      ..write(obj.subcategory)
      ..writeByte(14)
      ..write(obj.hidden)
      ..writeByte(15)
      ..write(obj.isBill)
      ..writeByte(16)
      ..write(obj.isDebt)
      ..writeByte(17)
      ..write(obj.isSplit)
      ..writeByte(18)
      ..write(obj.isBalanceOut)
      ..writeByte(19)
      ..write(obj.needsReview)
      ..writeByte(20)
      ..write(obj.isAutoPay)
      ..writeByte(21)
      ..write(obj.autoPayId)
      ..writeByte(22)
      ..write(obj.merchant)
      ..writeByte(23)
      ..write(obj.expectedFrequency)
      ..writeByte(24)
      ..write(obj.userId)
      ..writeByte(25)
      ..write(obj.accountId)
      ..writeByte(26)
      ..write(obj.bankId)
      ..writeByte(27)
      ..write(obj.bankName)
      ..writeByte(28)
      ..write(obj.bankLogo)
      ..writeByte(29)
      ..write(obj.v)
      ..writeByte(30)
      ..write(obj.isExcluded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
