// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_inbox_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageInboxHiveModelAdapter extends TypeAdapter<MessageInboxHiveModel> {
  @override
  final int typeId = 3;

  @override
  MessageInboxHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageInboxHiveModel(
      id: fields[0] as String,
      username: fields[1] as String,
      email: fields[2] as String,
      profilePhoto: fields[3] as String?,
      lastMessage: fields[4] as String,
      lastMessageTime: fields[5] as DateTime,
      lastMessageIsRead: fields[6] as bool,
      lastMessageSenderId: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MessageInboxHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.profilePhoto)
      ..writeByte(4)
      ..write(obj.lastMessage)
      ..writeByte(5)
      ..write(obj.lastMessageTime)
      ..writeByte(6)
      ..write(obj.lastMessageIsRead)
      ..writeByte(7)
      ..write(obj.lastMessageSenderId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageInboxHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
