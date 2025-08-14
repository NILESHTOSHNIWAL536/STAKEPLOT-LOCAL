// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardsDataAdapter extends TypeAdapter<CardsData> {
  @override
  final int typeId = 18;

  @override
  CardsData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardsData(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as String,
      date: fields[3] as String,
      occuranceDate: (fields[4] as List).cast<String>(),
      frequency: fields[5] as String,
      narration: fields[6] as String,
      gradientIndex: fields[7] as int,
      nextReminderAt: fields[8] as DateTime?,
      isActive: fields[9] as bool,
      isDaily: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CardsData obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.occuranceDate)
      ..writeByte(5)
      ..write(obj.frequency)
      ..writeByte(6)
      ..write(obj.narration)
      ..writeByte(7)
      ..write(obj.gradientIndex)
      ..writeByte(8)
      ..write(obj.nextReminderAt)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.isDaily);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardsDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
