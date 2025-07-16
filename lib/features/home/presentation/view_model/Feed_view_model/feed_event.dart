abstract class FeedEvent {}

class LoadPostsEvent extends FeedEvent {
  final String currentUserId; // <-- Add this
  LoadPostsEvent(this.currentUserId);
}

class LikePostEvent extends FeedEvent {
  final String userId;
  final String postId;

  LikePostEvent({required this.userId, required this.postId});
}

class UnlikePostEvent extends FeedEvent {
  final String userId;
  final String postId;

  UnlikePostEvent({required this.userId, required this.postId});
}

class OpenPostEvent extends FeedEvent {
  final String postId;
  OpenPostEvent(this.postId);
}

class CommentOnPostEvent extends FeedEvent {
  final String postId;
  final String commentText;
  CommentOnPostEvent(this.postId, this.commentText);
}
