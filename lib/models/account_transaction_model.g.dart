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
    );
  }

  @override
  void write(BinaryWriter writer, AccountTransactionModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.amount);
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
