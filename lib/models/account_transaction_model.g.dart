// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountTransactionModelAdapter
    extends TypeAdapter<AccountTransactionModel> {
  @override
  final int typeId = 1;

  @override
  AccountTransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AccountTransactionModel(
      date: fields[0] as String,
      type: fields[1] as String,
      amount: fields[2] as double,
      note: fields[3] as String?,
      remoteId: fields[4] as String?,
      updatedAt: fields[5] as DateTime?,
      deletedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AccountTransactionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.remoteId)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountTransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
