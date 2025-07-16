import 'package:json_annotation/json_annotation.dart';
import 'package:softconnect/features/home/domain/entity/comment_entity.dart';
import 'package:softconnect/features/home/data/model/user_preview_model.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  @JsonKey(name: '_id')
  final String id;

  @JsonKey(name: 'postId')
  final String postId;

  @JsonKey(name: 'userId')
  final UserPreviewModel user; // Updated from String to nested UserPreviewModel

  final String content;
  final String? parentCommentId;

  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.user,
    required this.content,
    this.parentCommentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      postId: postId,
      userId: user.userId, // Extract userId from nested object
      content: content,
      parentCommentId: parentCommentId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
