import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/home/domain/use_case/getLikesUseCase.dart';
import 'package:softconnect/features/home/domain/use_case/getCommentsUseCase.dart';
import 'package:softconnect/features/home/domain/use_case/getPostsUseCase.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_event.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_state.dart';

class FeedViewModel extends Bloc<FeedEvent, FeedState> {
  final GetAllPostsUsecase getAllPostsUseCase;
  final GetLikesByPostIdUsecase getLikesByPostIdUsecase;
  final GetCommentsByPostIdUsecase getCommentsByPostIdUsecase;
  final LikePostUsecase likePostUseCase;
  final UnlikePostUsecase unlikePostUseCase;

  FeedViewModel({
    required this.getAllPostsUseCase,
    required this.getLikesByPostIdUsecase,
    required this.getCommentsByPostIdUsecase,
    required this.likePostUseCase,
    required this.unlikePostUseCase,
  }) : super(FeedState.initial()) {
    on<LoadPostsEvent>(_onLoadPosts);
    on<LikePostEvent>(_onLikePost);
    on<UnlikePostEvent>(_onUnlikePost);
  }

  Future<void> _onLoadPosts(LoadPostsEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await getAllPostsUseCase();

    if (result.isLeft()) {
      final failure = result.swap().getOrElse(() => RemoteDatabaseFailure(message: "Unknown error"));
      emit(state.copyWith(isLoading: false, error: failure.message));
      return;
    }

    final posts = result.getOrElse(() => []);

    final likedMap = <String, bool>{};
    final likeCountMap = <String, int>{};
    final commentCountMap = <String, int>{};

    for (var post in posts) {
      final likesResult = await getLikesByPostIdUsecase(GetLikesByPostIdParams(post.id));
      likesResult.fold(
        (_) {
          likeCountMap[post.id] = 0;
          likedMap[post.id] = false;
          print('Post ${post.id} → Likes: ${likeCountMap[post.id]}, LikedByUser: ${likedMap[post.id]}');

        },
        (likes) {
          likeCountMap[post.id] = likes.length;
          // Check if current user liked this post
          likedMap[post.id] = likes.any((like) => like.userId == event.currentUserId);
        },
      );

      final commentsResult = await getCommentsByPostIdUsecase(GetCommentsByPostIdParams(post.id));
      commentsResult.fold(
        (_) => commentCountMap[post.id] = 0,
        (comments) => commentCountMap[post.id] = comments.length,
      );
    }

    emit(state.copyWith(
      isLoading: false,
      posts: posts,
      isLikedMap: likedMap,
      likeCounts: likeCountMap,
      commentCounts: commentCountMap,
      error: null,
    ));
  }

  Future<void> _onLikePost(LikePostEvent event, Emitter<FeedState> emit) async {
    final newIsLikedMap = Map<String, bool>.from(state.isLikedMap);
    final newLikeCounts = Map<String, int>.from(state.likeCounts);

    if (newIsLikedMap[event.postId] == true) return;

    newIsLikedMap[event.postId] = true;
    newLikeCounts[event.postId] = (newLikeCounts[event.postId] ?? 0) + 1;

    emit(state.copyWith(isLikedMap: newIsLikedMap, likeCounts: newLikeCounts));

    final result = await likePostUseCase(
      LikePostParams(userId: event.userId, postId: event.postId),
    );

    result.fold(
      (failure) {
        newIsLikedMap[event.postId] = false;
        newLikeCounts[event.postId] = (newLikeCounts[event.postId] ?? 1) - 1;
        emit(state.copyWith(isLikedMap: newIsLikedMap, likeCounts: newLikeCounts));
      },
      (_) {},
    );
  }

  Future<void> _onUnlikePost(UnlikePostEvent event, Emitter<FeedState> emit) async {
    final newIsLikedMap = Map<String, bool>.from(state.isLikedMap);
    final newLikeCounts = Map<String, int>.from(state.likeCounts);

    if (newIsLikedMap[event.postId] == false) return;

    newIsLikedMap[event.postId] = false;
    newLikeCounts[event.postId] = (newLikeCounts[event.postId] ?? 1) - 1;

    emit(state.copyWith(isLikedMap: newIsLikedMap, likeCounts: newLikeCounts));

    final result = await unlikePostUseCase(
      UnlikePostParams(userId: event.userId, postId: event.postId),
    );

    result.fold(
      (failure) {
        newIsLikedMap[event.postId] = true;
        newLikeCounts[event.postId] = (newLikeCounts[event.postId] ?? 0) + 1;
        emit(state.copyWith(isLikedMap: newIsLikedMap, likeCounts: newLikeCounts));
      },
      (_) {},
    );
  }
}
