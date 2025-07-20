import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';
import 'package:softconnect/features/auth/domain/use_case/user_get_current_user_usecase.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';
import 'package:softconnect/features/home/domain/use_case/getPostsUseCase.dart';
import 'package:softconnect/features/profile/domain/use_case/updateProfileUsecase.dart';

// State class
class UserProfileState extends Equatable {
  final UserEntity? user;
  final List<PostEntity> posts;
  final bool isFollowing;
  final bool isLoading;

  const UserProfileState({
    this.user,
    this.posts = const [],
    this.isFollowing = false,
    this.isLoading = false,
  });

  UserProfileState copyWith({
    UserEntity? user,
    List<PostEntity>? posts,
    bool? isFollowing,
    bool? isLoading,
  }) {
    return UserProfileState(
      user: user ?? this.user,
      posts: posts ?? this.posts,
      isFollowing: isFollowing ?? this.isFollowing,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [user, posts, isFollowing, isLoading];
}

// Cubit class
class UserProfileViewModel extends Cubit<UserProfileState> {
  final GetUserByIdUsecase getUserById;
  final GetPostsByUserIdUsecase getPostsByUserId;
  final UpdateUserProfileUsecase updateUserProfileUsecase;
  final UploadImageUsecase uploadImageUsecase;

  UserProfileViewModel({
    required this.getUserById,
    required this.getPostsByUserId,
    required this.updateUserProfileUsecase,
    required this.uploadImageUsecase
  }) : super(const UserProfileState());

  Future<void> loadUserProfile(String userId) async {
    emit(state.copyWith(isLoading: true));

    final userResult = await getUserById(GetUserByIdParams(userId: userId));
    final postsResult = await getPostsByUserId(GetPostsByUserIdParams(userId));

    UserEntity? user;
    List<PostEntity> posts = [];

    userResult.fold(
      (failure) => debugPrint('User error: $failure'),
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
    ));
  }


  
Future<void> updateUserProfile({
  required String userId,
  required String username,
  required String email,
  String? bio,
  String? profilePhotoPath,
}) async {
  emit(state.copyWith(isLoading: true));

  String? imageUrl;

  if (profilePhotoPath != null && profilePhotoPath.isNotEmpty) {
    final uploadResult = await uploadImageUsecase(
      UploadImageParams(File(profilePhotoPath)), // ✅ Wrap in UploadImageParams
    );

    uploadResult.fold(
      (failure) => debugPrint('Image upload failed: $failure'),
      (path) => imageUrl = path,
    );
  }

  final result = await updateUserProfileUsecase(
    UpdateUserProfileParams(
      userId: userId,
      username: username,
      email: email,
      bio: bio,
      profilePhoto: imageUrl, // ✅ Correct field
    ),
  );

  result.fold(
    (failure) {
      debugPrint('Update failed: $failure');
      emit(state.copyWith(isLoading: false));
    },
    (updatedUser) {
      emit(state.copyWith(user: updatedUser, isLoading: false));
    },
  );
}





  void toggleFollow(String userId) {
    emit(state.copyWith(isFollowing: !state.isFollowing));
    // Call your follow/unfollow usecase if needed here.
  }

  // Getters for backward compatibility
  UserEntity? get user => state.user;
  List<PostEntity> get posts => state.posts;
  bool get isFollowing => state.isFollowing;
}