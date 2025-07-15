// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowModel _$FollowModelFromJson(Map<String, dynamic> json) => FollowModel(
      id: json['_id'] as String?,
      follower: json['follower'] as String,
      followee: json['followee'] as String,
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
