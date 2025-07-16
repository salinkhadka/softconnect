import 'package:equatable/equatable.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';

class FeedState extends Equatable {
  final bool isLoading;
  final List<PostEntity> posts;
  final Map<String, bool> isLikedMap; // postId -> liked
  final Map<String, int> likeCounts; // postId -> likeCount
  final Map<String, int> commentCounts; // postId -> commentCount
  final String? error;

  const FeedState({
    required this.isLoading,
    required this.posts,
    required this.isLikedMap,
    required this.likeCounts,
    required this.commentCounts,
    this.error,
  });

  factory FeedState.initial() {
    return FeedState(
      isLoading: false,
      posts: [],
      isLikedMap: {},
      likeCounts: {},
      commentCounts: {},
      error: null,
    );
  }

  FeedState copyWith({
    bool? isLoading,
    List<PostEntity>? posts,
    Map<String, bool>? isLikedMap,
    Map<String, int>? likeCounts,
    Map<String, int>? commentCounts,
    String? error,
  }) {
    return FeedState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      isLikedMap: isLikedMap ?? this.isLikedMap,
      likeCounts: likeCounts ?? this.likeCounts,
      commentCounts: commentCounts ?? this.commentCounts,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, posts, isLikedMap, likeCounts, commentCounts, error];
}
