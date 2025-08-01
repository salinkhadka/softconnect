import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/core/utils/mysnackbar.dart';
import 'package:softconnect/features/friends/domain/use_case/follow_user_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/get_followers_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/get_following_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/unfollow_user_usecase.dart';
import 'follow_event.dart';
import 'follow_state.dart';

class FollowViewModel extends Bloc<FollowEvent, FollowState> {
  final FollowUserUseCase _followUserUseCase;
  final UnfollowUserUseCase _unfollowUserUseCase;
  final GetFollowersUseCase _getFollowersUseCase;
  final GetFollowingUseCase _getFollowingUseCase;

  FollowViewModel({
    required FollowUserUseCase followUserUseCase,
    required UnfollowUserUseCase unfollowUserUseCase,
    required GetFollowersUseCase getFollowersUseCase,
    required GetFollowingUseCase getFollowingUseCase,
  })  : _followUserUseCase = followUserUseCase,
        _unfollowUserUseCase = unfollowUserUseCase,
        _getFollowersUseCase = getFollowersUseCase,
        _getFollowingUseCase = getFollowingUseCase,
        super(FollowState.initial()) {
    on<FollowUserEvent>(_onFollowUser);
    on<UnfollowUserEvent>(_onUnfollowUser);
    on<LoadFollowersEvent>(_onLoadFollowers);
    on<LoadFollowingEvent>(_onLoadFollowing);
    on<ShowFollowersViewEvent>(_onShowFollowersView);
    on<ShowFollowingViewEvent>(_onShowFollowingView);
  }

  // Helper to get userId from SharedPreferences
  Future<String?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> _onFollowUser(
    FollowUserEvent event,
    Emitter<FollowState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _followUserUseCase(FollowUserParams(event.followeeId));

    if (emit.isDone) return;

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        showMySnackBar(
          context: event.context,
          message: failure.message,
          color: Colors.red,
        );
      },
      (follow) {
        emit(state.copyWith(isLoading: false));
        showMySnackBar(
          context: event.context,
          message: "Followed successfully!",
          color: Color(0xFF37225C),
        );
      },
    );
  }

  Future<void> _onUnfollowUser(
    UnfollowUserEvent event,
    Emitter<FollowState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _unfollowUserUseCase(UnfollowUserParams(event.followeeId));

    if (emit.isDone) return;

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        showMySnackBar(
          context: event.context,
          message: failure.message,
          color: Colors.red,
        );
      },
      (_) {
        final updatedFollowing = List.of(state.following)
          ..removeWhere((f) => f.followeeId == event.followeeId);

        emit(state.copyWith(isLoading: false, following: updatedFollowing));

        showMySnackBar(
          context: event.context,
          message: "Unfollowed successfully!",
          color:Color(0xFF37225C),
        );
      },
    );
  }

  Future<void> _onLoadFollowers(
    LoadFollowersEvent event,
    Emitter<FollowState> emit,
  ) async {
    final userId = await _getUserIdFromPrefs();

    if (userId == null) {
      emit(state.copyWith(isLoading: false, errorMessage: "User ID not found. Please login."));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _getFollowersUseCase(GetFollowersParams(userId));

    if (emit.isDone) return;

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (followers) => emit(state.copyWith(isLoading: false, followers: followers, errorMessage: null)),
    );
  }

  Future<void> _onLoadFollowing(
    LoadFollowingEvent event,
    Emitter<FollowState> emit,
  ) async {
    final userId = await _getUserIdFromPrefs();

    if (userId == null) {
      emit(state.copyWith(isLoading: false, errorMessage: "User ID not found. Please login."));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _getFollowingUseCase(GetFollowingParams(userId));

    if (emit.isDone) return;

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (following) => emit(state.copyWith(isLoading: false, following: following, errorMessage: null)),
    );
  }

  // New handler for ShowFollowersViewEvent
  Future<void> _onShowFollowersView(
    ShowFollowersViewEvent event,
    Emitter<FollowState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, showFollowers: true, errorMessage: null));

    final userId = await _getUserIdFromPrefs();

    if (userId == null) {
      emit(state.copyWith(isLoading: false, errorMessage: "User ID not found. Please login.", showFollowers: true));
      return;
    }

    final result = await _getFollowersUseCase(GetFollowersParams(userId));

    if (emit.isDone) return;

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message, showFollowers: true)),
      (followers) => emit(state.copyWith(isLoading: false, followers: followers, errorMessage: null, showFollowers: true)),
    );
  }

  // New handler for ShowFollowingViewEvent
  Future<void> _onShowFollowingView(
    ShowFollowingViewEvent event,
    Emitter<FollowState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, showFollowers: false, errorMessage: null));

    final userId = await _getUserIdFromPrefs();

    if (userId == null) {
      emit(state.copyWith(isLoading: false, errorMessage: "User ID not found. Please login.", showFollowers: false));
      return;
    }

    final result = await _getFollowingUseCase(GetFollowingParams(userId));

    if (emit.isDone) return;

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message, showFollowers: false)),
      (following) => emit(state.copyWith(isLoading: false, following: following, errorMessage: null, showFollowers: false)),
    );
  }
}
