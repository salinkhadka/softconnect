// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preview_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreviewHiveModelAdapter extends TypeAdapter<UserPreviewHiveModel> {
  @override
  final int typeId = 2;

  @override
  UserPreviewHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreviewHiveModel(
      userId: fields[0] as String,
      username: fields[1] as String,
      profilePhoto: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreviewHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.profilePhoto);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreviewHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
