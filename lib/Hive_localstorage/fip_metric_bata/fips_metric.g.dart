// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fips_metric.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FipsMetricsAdapter extends TypeAdapter<FipsMetrics> {
  @override
  final int typeId = 4;

  @override
  FipsMetrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FipsMetrics(
      timestamp: fields[0] as DateTime,
      fipId: fields[1] as String,
      eventName: fields[3] as String,
      bankName: fields[2] as String,
      latencyAvgMs: fields[4] as num,
      successPercent: fields[5] as num,
      timeoutPercent: fields[6] as num,
      accNotFoundPercent: fields[7] as num,
      serverErrorPercent: fields[8] as num,
      clientErrorPercent: fields[9] as num,
      latencyP99Ms: fields[10] as num,
      latencyP95Ms: fields[11] as num,
      latencyP50Ms: fields[12] as num,
    );
  }

  @override
  void write(BinaryWriter writer, FipsMetrics obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.fipId)
      ..writeByte(2)
      ..write(obj.bankName)
      ..writeByte(3)
      ..write(obj.eventName)
      ..writeByte(4)
      ..write(obj.latencyAvgMs)
      ..writeByte(5)
      ..write(obj.successPercent)
      ..writeByte(6)
      ..write(obj.timeoutPercent)
      ..writeByte(7)
      ..write(obj.accNotFoundPercent)
      ..writeByte(8)
      ..write(obj.serverErrorPercent)
      ..writeByte(9)
      ..write(obj.clientErrorPercent)
      ..writeByte(10)
      ..write(obj.latencyP99Ms)
      ..writeByte(11)
      ..write(obj.latencyP95Ms)
      ..writeByte(12)
      ..write(obj.latencyP50Ms);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FipsMetricsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
