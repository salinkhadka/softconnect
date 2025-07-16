// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
      id: json['_id'] as String,
      userId: UserApiModel.fromJson(json['userId'] as Map<String, dynamic>),
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      privacy: json['privacy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'privacy': instance.privacy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
