import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/friends/domain/entity/follow_entity.dart';
import 'package:softconnect/features/friends/domain/use_case/follow_user_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/unfollow_user_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/get_followers_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/get_following_usecase.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_viewmodel.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_event.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_state.dart';

// Mock all the use cases
class MockFollowUserUseCase extends Mock implements FollowUserUseCase {}
class MockUnfollowUserUseCase extends Mock implements UnfollowUserUseCase {}
class MockGetFollowersUseCase extends Mock implements GetFollowersUseCase {}
class MockGetFollowingUseCase extends Mock implements GetFollowingUseCase {}

// Fake classes for mocktail
class FakeBuildContext extends Fake implements BuildContext {}
class FakeFollowUserParams extends Fake implements FollowUserParams {}
class FakeUnfollowUserParams extends Fake implements UnfollowUserParams {}
class FakeGetFollowersParams extends Fake implements GetFollowersParams {}
class FakeGetFollowingParams extends Fake implements GetFollowingParams {}

void main() {
  late MockFollowUserUseCase mockFollowUserUseCase;
  late MockUnfollowUserUseCase mockUnfollowUserUseCase;
  late MockGetFollowersUseCase mockGetFollowersUseCase;
  late MockGetFollowingUseCase mockGetFollowingUseCase;
  late FollowViewModel followViewModel;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(FakeFollowUserParams());
    registerFallbackValue(FakeUnfollowUserParams());
    registerFallbackValue(FakeGetFollowersParams());
    registerFallbackValue(FakeGetFollowingParams());
    
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({'userId': 'test_user_id'});
  });

  setUp(() {
    mockFollowUserUseCase = MockFollowUserUseCase();
    mockUnfollowUserUseCase = MockUnfollowUserUseCase();
    mockGetFollowersUseCase = MockGetFollowersUseCase();
    mockGetFollowingUseCase = MockGetFollowingUseCase();

    followViewModel = FollowViewModel(
      followUserUseCase: mockFollowUserUseCase,
      unfollowUserUseCase: mockUnfollowUserUseCase,
      getFollowersUseCase: mockGetFollowersUseCase,
      getFollowingUseCase: mockGetFollowingUseCase,
    );
  });

  tearDown(() {
    followViewModel.close();
  });

  final fakeContext = FakeBuildContext();
  final now = DateTime.now();
  
  final sampleFollowEntity = FollowEntity(
    id: '1',
    followerId: 'follower1',
    followeeId: 'followee1',
    username: 'followerUser',
    profilePhoto: 'http://photo.url',
    createdAt: now,
    updatedAt: now,
  );

  group('FollowViewModel Tests', () {
    

    

    blocTest<FollowViewModel, FollowState>(
      'emits [loading, success] when unfollow user is successful',
      build: () {
        when(() => mockUnfollowUserUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return followViewModel;
      },
      seed: () => FollowState.initial().copyWith(
        following: [sampleFollowEntity],
      ),
      act: (bloc) => bloc.add(
        UnfollowUserEvent(followeeId: 'followee1', context: fakeContext),
      ),
      expect: () => [
        FollowState.initial().copyWith(
          following: [sampleFollowEntity],
          isLoading: true,
        ),
        FollowState.initial().copyWith(
          isLoading: false,
          following: [], // Should remove the unfollowed user
        ),
      ],
      verify: (_) {
        verify(() => mockUnfollowUserUseCase(any())).called(1);
      },
    );

    blocTest<FollowViewModel, FollowState>(
      'emits [loading, error] when unfollow user fails',
      build: () {
        when(() => mockUnfollowUserUseCase(any()))
            .thenAnswer((_) async => Left(RemoteDatabaseFailure(message: 'Failed to unfollow')));
        return followViewModel;
      },
      act: (bloc) => bloc.add(
        UnfollowUserEvent(followeeId: 'followee1', context: fakeContext),
      ),
      expect: () => [
        FollowState.initial().copyWith(isLoading: true),
        FollowState.initial().copyWith(
          isLoading: false,
          errorMessage: 'Failed to unfollow',
        ),
      ],
      verify: (_) {
        verify(() => mockUnfollowUserUseCase(any())).called(1);
      },
    );

    blocTest<FollowViewModel, FollowState>(
      'emits [loading, success] when load followers is successful',
      build: () {
        when(() => mockGetFollowersUseCase(any()))
            .thenAnswer((_) async => Right([sampleFollowEntity]));
        return followViewModel;
      },
      act: (bloc) => bloc.add(const LoadFollowersEvent('test_user_id')),
      expect: () => [
        FollowState.initial().copyWith(isLoading: true, errorMessage: null),
        FollowState.initial().copyWith(
          isLoading: false,
          followers: [sampleFollowEntity],
          errorMessage: null,
        ),
      ],
      verify: (_) {
        verify(() => mockGetFollowersUseCase(any())).called(1);
      },
    );

    blocTest<FollowViewModel, FollowState>(
      'emits [loading, success] when load following is successful',
      build: () {
        when(() => mockGetFollowingUseCase(any()))
            .thenAnswer((_) async => Right([sampleFollowEntity]));
        return followViewModel;
      },
      act: (bloc) => bloc.add(const LoadFollowingEvent('test_user_id')),
      expect: () => [
        FollowState.initial().copyWith(isLoading: true, errorMessage: null),
        FollowState.initial().copyWith(
          isLoading: false,
          following: [sampleFollowEntity],
          errorMessage: null,
        ),
      ],
      verify: (_) {
        verify(() => mockGetFollowingUseCase(any())).called(1);
      },
    );

    blocTest<FollowViewModel, FollowState>(
      'emits [loading, success with showFollowers=true] when ShowFollowersViewEvent is triggered',
      build: () {
        when(() => mockGetFollowersUseCase(any()))
            .thenAnswer((_) async => Right([sampleFollowEntity]));
        return followViewModel;
      },
      act: (bloc) => bloc.add(const ShowFollowersViewEvent()),
      expect: () => [
        FollowState.initial().copyWith(
          isLoading: true,
          showFollowers: true,
          errorMessage: null,
        ),
        FollowState.initial().copyWith(
          isLoading: false,
          followers: [sampleFollowEntity],
          showFollowers: true,
          errorMessage: null,
        ),
      ],
      verify: (_) {
        verify(() => mockGetFollowersUseCase(any())).called(1);
      },
    );

    blocTest<FollowViewModel, FollowState>(
      'emits [loading, success with showFollowers=false] when ShowFollowingViewEvent is triggered',
      build: () {
        when(() => mockGetFollowingUseCase(any()))
            .thenAnswer((_) async => Right([sampleFollowEntity]));
        return followViewModel;
      },
      act: (bloc) => bloc.add(const ShowFollowingViewEvent()),
      expect: () => [
        FollowState.initial().copyWith(
          isLoading: true,
          showFollowers: false,
          errorMessage: null,
        ),
        FollowState.initial().copyWith(
          isLoading: false,
          following: [sampleFollowEntity],
          showFollowers: false,
          errorMessage: null,
        ),
      ],
      verify: (_) {
        verify(() => mockGetFollowingUseCase(any())).called(1);
      },
    );

    test('initial state should be correct', () {
      expect(
        followViewModel.state,
        equals(FollowState.initial()),
      );
    });
  });
}