import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String? username;
  final String? profilePhoto;
  final String content;
  final String? parentCommentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    this.username,
    this.profilePhoto,
    required this.content,
    this.parentCommentId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        postId,
        userId,
        username,
        profilePhoto,
        content,
        parentCommentId,
        createdAt,
        updatedAt,
      ];
}
