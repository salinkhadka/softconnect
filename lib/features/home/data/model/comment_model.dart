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

  @JsonKey(name: 'userId', fromJson: _userFromJson)
  final UserPreviewModel user;

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

  // Custom converter to handle both String and Map for userId
  static UserPreviewModel _userFromJson(dynamic json) {
    if (json is String) {
      // When userId is just a string (like in create comment response)
      return UserPreviewModel(
        userId: json,
        username: '', // You might want to handle this differently
        profilePhoto: null,
      );
    } else if (json is Map<String, dynamic>) {
      // When userId is a full user object (like in get comments response)
      return UserPreviewModel.fromJson(json);
    } else {
      throw Exception('Invalid userId format');
    }
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      postId: postId,
      userId: user.userId,
      username: user.username,
      profilePhoto: user.profilePhoto,
      content: content,
      parentCommentId: parentCommentId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
