// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
      id: json['_id'] as String,
      postId: json['postId'] as String,
      user: UserPreviewModel.fromJson(json['userId'] as Map<String, dynamic>),
      content: json['content'] as String,
      parentCommentId: json['parentCommentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'postId': instance.postId,
      'userId': instance.user,
      'content': instance.content,
      'parentCommentId': instance.parentCommentId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
