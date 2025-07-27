import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';
import 'package:softconnect/features/auth/domain/use_case/user_get_current_user_usecase.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';
import 'package:softconnect/features/home/domain/use_case/getPostsUseCase.dart';
import 'package:softconnect/features/profile/domain/use_case/updateProfileUsecase.dart';

class UserProfileState extends Equatable {
  final UserEntity? user;
  final List<PostEntity> posts;
  final bool isFollowing;
  final bool isLoading;
  final String? error;

  const UserProfileState({
    this.user,
    this.posts = const [],
    this.isFollowing = false,
    this.isLoading = false,
    this.error,
  });

  UserProfileState copyWith({
    UserEntity? user,
    List<PostEntity>? posts,
    bool? isFollowing,
    bool? isLoading,
    String? error,
  }) {
    return UserProfileState(
      user: user ?? this.user,
      posts: posts ?? this.posts,
      isFollowing: isFollowing ?? this.isFollowing,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [user, posts, isFollowing, isLoading, error];
}

class UserProfileViewModel extends Cubit<UserProfileState> {
  final GetUserByIdUsecase getUserById;
  final GetPostsByUserIdUsecase getPostsByUserId;
  final UpdateUserProfileUsecase updateUserProfileUsecase;
  final UploadImageUsecase uploadImageUsecase;
  final UpdatePostUsecase updatePostUsecase;
  final DeletePostUsecase deletePostUsecase;

  UserProfileViewModel({
    required this.getUserById,
    required this.getPostsByUserId,
    required this.updateUserProfileUsecase,
    required this.uploadImageUsecase,
    required this.updatePostUsecase,
    required this.deletePostUsecase,
  }) : super(const UserProfileState());

  Future<void> loadUserProfile(String userId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final userResult = await getUserById(GetUserByIdParams(userId: userId));
      final postsResult = await getPostsByUserId(GetPostsByUserIdParams(userId));

      UserEntity? user;
      List<PostEntity> posts = [];

      userResult.fold(
        (failure) {
          debugPrint('User error: $failure');
          emit(state.copyWith(
            isLoading: false,
            error: 'Failed to load user profile',
          ));
          return;
        },
        (userData) => user = userData,
      );

      postsResult.fold(
        (failure) => debugPrint('Posts error: $failure'),
        (userPosts) => posts = userPosts,
      );

      emit(state.copyWith(
        user: user,
        posts: posts,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      ));
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required String username,
    required String email,
    String? bio,
    String? profilePhotoPath,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      String? imageUrl;

      if (profilePhotoPath != null && profilePhotoPath.isNotEmpty) {
        final uploadResult = await uploadImageUsecase(
          UploadImageParams(File(profilePhotoPath)),
        );

        uploadResult.fold(
          (failure) {
            debugPrint('Image upload failed: $failure');
            emit(state.copyWith(
              isLoading: false,
              error: 'Failed to upload image',
            ));
            return;
          },
          (path) => imageUrl = path,
        );
      }

      final result = await updateUserProfileUsecase(
        UpdateUserProfileParams(
          userId: userId,
          username: username,
          email: email,
          bio: bio,
          profilePhoto: imageUrl ?? state.user?.profilePhoto,
        ),
      );

      result.fold(
        (failure) {
          debugPrint('Update failed: $failure');
          emit(state.copyWith(
            isLoading: false,
            error: 'Failed to update profile',
          ));
        },
        (updatedUser) {
          emit(state.copyWith(
            user: updatedUser,
            isLoading: false,
            error: null,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      ));
      debugPrint('Error updating profile: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final result = await deletePostUsecase(DeletePostParams(postId));

      result.fold(
        (failure) {
          debugPrint('Delete post failed: $failure');
          emit(state.copyWith(error: 'Failed to delete post'));
        },
        (_) {
          final updatedPosts = state.posts.where((post) => post.id != postId).toList();
          emit(state.copyWith(
            posts: updatedPosts,
            error: null,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(error: 'An unexpected error occurred'));
      debugPrint('Error deleting post: $e');
    }
  }

  Future<void> updatePost(PostEntity updatedPost) async {
    try {
      final result = await updatePostUsecase(
        UpdatePostParams(
          postId: updatedPost.id,
          content: updatedPost.content,
          privacy: updatedPost.privacy,
          imageUrl: updatedPost.imageUrl,
        ),
      );

      result.fold(
        (failure) {
          debugPrint('Update post failed: $failure');
          emit(state.copyWith(error: 'Failed to update post'));
        },
        (newPost) {
          final updatedPosts = state.posts.map((post) {
            return post.id == newPost.id ? newPost : post;
          }).toList();
          emit(state.copyWith(
            posts: updatedPosts,
            error: null,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(error: 'An unexpected error occurred'));
      debugPrint('Error updating post: $e');
    }
  }

  void toggleFollow(String userId) {
    // TODO: Implement actual follow/unfollow API call
    emit(state.copyWith(isFollowing: !state.isFollowing));
  }

  // Getters for easier access
  UserEntity? get user => state.user;
  List<PostEntity> get posts => state.posts;
  bool get isFollowing => state.isFollowing;
  bool get isLoading => state.isLoading;
  String? get error => state.error;
}
