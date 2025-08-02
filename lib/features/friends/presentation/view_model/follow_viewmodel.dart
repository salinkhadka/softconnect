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
        // Only update the list if we currently have following data
        if (state.following != null) {
          final updatedFollowing = List.of(state.following!)
            ..removeWhere((f) => f.followeeId == event.followeeId);

          emit(state.copyWith(isLoading: false, following: updatedFollowing));
        } else {
          emit(state.copyWith(isLoading: false));
        }

        showMySnackBar(
          context: event.context,
          message: "Unfollowed successfully!",
          color: Color(0xFF37225C),
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
      (failure) => emit(state.copyWith(
        isLoading: false, 
        errorMessage: failure.message,
        hasInitiallyLoaded: true,
      )),
      (followers) => emit(state.copyWith(
        isLoading: false, 
        followers: followers, 
        errorMessage: null,
        hasInitiallyLoaded: true,
      )),
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
      (failure) => emit(state.copyWith(
        isLoading: false, 
        errorMessage: failure.message,
        hasInitiallyLoaded: true,
      )),
      (following) => emit(state.copyWith(
        isLoading: false, 
        following: following, 
        errorMessage: null,
        hasInitiallyLoaded: true,
      )),
    );
  }

  Future<void> _onShowFollowersView(
    ShowFollowersViewEvent event,
    Emitter<FollowState> emit,
  ) async {
    // Set showFollowers to true immediately
    emit(state.copyWith(showFollowers: true));

    // Only fetch if we don't have followers data yet
    if (state.followers == null) {
      emit(state.copyWith(isLoading: true, showFollowers: true, errorMessage: null));

      final userId = await _getUserIdFromPrefs();

      if (userId == null) {
        emit(state.copyWith(
          isLoading: false, 
          errorMessage: "User ID not found. Please login.", 
          showFollowers: true,
          hasInitiallyLoaded: true,
        ));
        return;
      }

      final result = await _getFollowersUseCase(GetFollowersParams(userId));

      if (emit.isDone) return;

      result.fold(
        (failure) => emit(state.copyWith(
          isLoading: false, 
          errorMessage: failure.message, 
          showFollowers: true,
          hasInitiallyLoaded: true,
        )),
        (followers) => emit(state.copyWith(
          isLoading: false, 
          followers: followers, 
          errorMessage: null, 
          showFollowers: true,
          hasInitiallyLoaded: true,
        )),
      );
    }
  }

  Future<void> _onShowFollowingView(
    ShowFollowingViewEvent event,
    Emitter<FollowState> emit,
  ) async {
    // Set showFollowers to false immediately
    emit(state.copyWith(showFollowers: false));

    // Only fetch if we don't have following data yet
    if (state.following == null) {
      emit(state.copyWith(isLoading: true, showFollowers: false, errorMessage: null));

      final userId = await _getUserIdFromPrefs();

      if (userId == null) {
        emit(state.copyWith(
          isLoading: false, 
          errorMessage: "User ID not found. Please login.", 
          showFollowers: false,
          hasInitiallyLoaded: true,
        ));
        return;
      }

      final result = await _getFollowingUseCase(GetFollowingParams(userId));

      if (emit.isDone) return;

      result.fold(
        (failure) => emit(state.copyWith(
          isLoading: false, 
          errorMessage: failure.message, 
          showFollowers: false,
          hasInitiallyLoaded: true,
        )),
        (following) => emit(state.copyWith(
          isLoading: false, 
          following: following, 
          errorMessage: null, 
          showFollowers: false,
          hasInitiallyLoaded: true,
        )),
      );
    }
  }
}