// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowUserModel _$FollowUserModelFromJson(Map<String, dynamic> json) =>
    FollowUserModel(
      id: json['_id'] as String,
      username: json['username'] as String,
      profilePhoto: json['profilePhoto'] as String?,
    );

Map<String, dynamic> _$FollowUserModelToJson(FollowUserModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'profilePhoto': instance.profilePhoto,
    };

FollowModel _$FollowModelFromJson(Map<String, dynamic> json) => FollowModel(
      id: json['_id'] as String?,
      follower: json['follower'],
      followee: json['followee'],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FollowModelToJson(FollowModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'follower': instance.follower,
      'followee': instance.followee,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
