// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preview_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreviewModel _$UserPreviewModelFromJson(Map<String, dynamic> json) =>
    UserPreviewModel(
      userId: json['_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      profilePhoto: json['profilePhoto'] as String? ?? '',
    );

Map<String, dynamic> _$UserPreviewModelToJson(UserPreviewModel instance) =>
    <String, dynamic>{
      '_id': instance.userId,
      'username': instance.username,
      'profilePhoto': instance.profilePhoto,
    };
