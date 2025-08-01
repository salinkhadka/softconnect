import 'package:equatable/equatable.dart';
import 'package:softconnect/features/friends/domain/entity/follow_entity.dart';

class FollowState extends Equatable {
  final bool isLoading;
  final List<FollowEntity> followers;
  final List<FollowEntity> following;
  final bool showFollowers;  // <--- new flag
  final String? errorMessage;

  const FollowState({
    required this.isLoading,
    required this.followers,
    required this.following,
    this.showFollowers = true, // default to showing followers
    this.errorMessage,
  });

  factory FollowState.initial() => FollowState(
        isLoading: false,
        followers: [],
        following: [],
        showFollowers: true,
        errorMessage: null,
      );

  FollowState copyWith({
    bool? isLoading,
    List<FollowEntity>? followers,
    List<FollowEntity>? following,
    bool? showFollowers,
    String? errorMessage,
  }) {
    return FollowState(
      isLoading: isLoading ?? this.isLoading,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      showFollowers: showFollowers ?? this.showFollowers,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, followers, following, showFollowers, errorMessage];
}
