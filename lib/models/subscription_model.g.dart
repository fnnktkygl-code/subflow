// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionAdapter extends TypeAdapter<Subscription> {
  @override
  final int typeId = 1;

  @override
  Subscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subscription(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as double,
      startDate: fields[3] as DateTime,
      cycle: fields[4] as String,
      logoUrl: fields[5] as String,
      endDate: fields[6] as DateTime?,
      category: fields[7] as String,
      areNotificationsEnabled: fields[8] as bool,
      reminderDays: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Subscription obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.cycle)
      ..writeByte(5)
      ..write(obj.logoUrl)
      ..writeByte(6)
      ..write(obj.endDate)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.areNotificationsEnabled)
      ..writeByte(9)
      ..write(obj.reminderDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
