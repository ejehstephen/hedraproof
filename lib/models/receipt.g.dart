// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReceiptAdapter extends TypeAdapter<Receipt> {
  @override
  final int typeId = 0;

  @override
  Receipt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Receipt(
      item: fields[0] as String,
      amount: fields[1] as String,
      tokenId: fields[2] as String,
      serial: fields[3] as int?,
      date: fields[4] as String,
      qrCodeIpfsCid: fields[5] as String?,
      status: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Receipt obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.item)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.tokenId)
      ..writeByte(3)
      ..write(obj.serial)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.qrCodeIpfsCid)
      ..writeByte(6)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
