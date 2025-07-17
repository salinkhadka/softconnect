import 'package:softconnect/features/home/domain/entity/comment_entity.dart';

class CommentState {
  final List<CommentEntity> comments;
  final bool isLoading;
  final String? error;

  CommentState({
    required this.comments,
    required this.isLoading,
    this.error,
  });

  factory CommentState.initial() {
    return CommentState(comments: [], isLoading: false);
  }

  CommentState copyWith({
    List<CommentEntity>? comments,
    bool? isLoading,
    String? error,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
