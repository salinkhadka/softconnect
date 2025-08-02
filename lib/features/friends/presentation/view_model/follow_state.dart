// Update your FollowState class like this:

import 'package:softconnect/features/friends/domain/entity/follow_entity.dart';

class FollowState {
  final bool isLoading;
  final List<FollowEntity>? followers; // Make nullable
  final List<FollowEntity>? following; // Make nullable
  final bool showFollowers;
  final String? errorMessage;
  final bool hasInitiallyLoaded; // Add this flag

  const FollowState({
    required this.isLoading,
    this.followers,
    this.following,
    required this.showFollowers,
    this.errorMessage,
    required this.hasInitiallyLoaded,
  });

  factory FollowState.initial() {
    return const FollowState(
      isLoading: false,
      followers: null, // Start with null
      following: null, // Start with null
      showFollowers: true,
      errorMessage: null,
      hasInitiallyLoaded: false,
    );
  }

  FollowState copyWith({
    bool? isLoading,
    List<FollowEntity>? followers,
    List<FollowEntity>? following,
    bool? showFollowers,
    String? errorMessage,
    bool? hasInitiallyLoaded,
  }) {
    return FollowState(
      isLoading: isLoading ?? this.isLoading,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      showFollowers: showFollowers ?? this.showFollowers,
      errorMessage: errorMessage ?? this.errorMessage,
      hasInitiallyLoaded: hasInitiallyLoaded ?? this.hasInitiallyLoaded,
    );
  }
}