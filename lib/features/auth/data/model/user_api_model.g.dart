// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserApiModel _$UserApiModelFromJson(Map<String, dynamic> json) => UserApiModel(
      userId: json['_id'] as String?,
      email: json['email'] as String,
      username: json['username'] as String,
      studentId: (json['StudentId'] as num?)?.toInt(),
      password: json['password'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      bio: json['bio'] as String?,
      role: json['role'] as String? ?? 'Student',
      followersCount: (json['followersCount'] as num?)?.toInt(),
      followingCount: (json['followingCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$UserApiModelToJson(UserApiModel instance) =>
    <String, dynamic>{
      '_id': instance.userId,
      'email': instance.email,
      'username': instance.username,
      'StudentId': instance.studentId,
      'password': instance.password,
      'profilePhoto': instance.profilePhoto,
      'bio': instance.bio,
      'role': instance.role,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
