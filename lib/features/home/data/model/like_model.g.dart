// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LikeModel _$LikeModelFromJson(Map<String, dynamic> json) => LikeModel(
      id: json['_id'] as String,
      postId: json['postId'] as String,
      user: UserPreviewModel.fromJson(json['userId'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LikeModelToJson(LikeModel instance) => <String, dynamic>{
      '_id': instance.id,
      'postId': instance.postId,
      'userId': instance.user,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
