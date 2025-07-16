// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
      id: json['_id'] as String,
      user: UserPreviewModel.fromJson(json['user'] as Map<String, dynamic>),
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      privacy: json['privacy'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      '_id': instance.id,
      'user': instance.user,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'privacy': instance.privacy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
