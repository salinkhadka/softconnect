import 'package:softconnect/features/home/data/model/comment_model.dart';

abstract class ICommentDataSource {
  /// Create a new comment on a post (POST /comment/createComment)
  Future<CommentModel> createComment({
    required String userId,
    required String postId,
    required String content,
    String? parentCommentId, // optional for nested replies
  });

  /// Get all comments for a specific post (GET /comment/comments/:postId)
  Future<List<CommentModel>> getCommentsByPostId(String postId);

  /// Delete a specific comment (DELETE /comment/delete/:commentId)
  Future<void> deleteComment(String commentId);
}
