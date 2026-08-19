// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TradeModelAdapter extends TypeAdapter<TradeModel> {
  @override
  final int typeId = 0;

  @override
  TradeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TradeModel(
      ticket: fields[0] as String,
      pair: fields[1] as String,
      type: fields[2] as String,
      lot: fields[3] as String,
      profit: fields[4] as String,
      openTime: fields[5] as String,
      closeTime: fields[6] as String,
      sl: fields[7] as String,
      tp: fields[8] as String,
      openPrice: fields[9] as String,
      closePrice: fields[10] as String,
      emotion: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TradeModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.ticket)
      ..writeByte(1)
      ..write(obj.pair)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.lot)
      ..writeByte(4)
      ..write(obj.profit)
      ..writeByte(5)
      ..write(obj.openTime)
      ..writeByte(6)
      ..write(obj.closeTime)
      ..writeByte(7)
      ..write(obj.sl)
      ..writeByte(8)
      ..write(obj.tp)
      ..writeByte(9)
      ..write(obj.openPrice)
      ..writeByte(10)
      ..write(obj.closePrice)
      ..writeByte(11)
      ..write(obj.emotion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
