abstract class CommentEvent {}

class LoadComments extends CommentEvent {
  final String postId;
  LoadComments(this.postId);
}

class AddComment extends CommentEvent {
  final String userId;
  final String postId;
  final String content;
  final String? parentCommentId;

  AddComment({
    required this.userId,
    required this.postId,
    required this.content,
    this.parentCommentId,
  });


}
class DeleteComment extends CommentEvent {
  final String commentId;
  final String postId; // Needed to reload comments after deletion

  DeleteComment({required this.commentId, required this.postId});
}

