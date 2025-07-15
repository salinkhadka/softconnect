// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FolloweeDto _$FolloweeDtoFromJson(Map<String, dynamic> json) => FolloweeDto(
      id: json['_id'] as String,
      username: json['username'] as String,
      profilePhoto: json['profilePhoto'] as String?,
    );

Map<String, dynamic> _$FolloweeDtoToJson(FolloweeDto instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'profilePhoto': instance.profilePhoto,
    };

FollowDto _$FollowDtoFromJson(Map<String, dynamic> json) => FollowDto(
      id: json['_id'] as String?,
      follower: json['follower'] as String,
      followee: FolloweeDto.fromJson(json['followee'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FollowDtoToJson(FollowDto instance) => <String, dynamic>{
      '_id': instance.id,
      'follower': instance.follower,
      'followee': instance.followee,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
