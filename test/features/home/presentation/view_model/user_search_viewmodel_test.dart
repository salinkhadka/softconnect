import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';
import 'package:softconnect/features/auth/domain/use_case/getall_users_usecase.dart';

import 'package:softconnect/features/home/presentation/view_model/user_search_state.dart';
import 'package:softconnect/features/home/presentation/view_model/user_search_viewmodel.dart';

// Mock classes
class MockSearchUsersUsecase extends Mock implements SearchUsersUsecase {}

// Fake classes for mocktail
class FakeSearchUsersParams extends Fake implements SearchUsersParams {}

void main() {
  late MockSearchUsersUsecase mockSearchUsersUsecase;
  late UserSearchViewModel userSearchViewModel;

  setUpAll(() {
    registerFallbackValue(FakeSearchUsersParams());
  });

  setUp(() {
    mockSearchUsersUsecase = MockSearchUsersUsecase();
    userSearchViewModel = UserSearchViewModel(
      searchUsersUsecase: mockSearchUsersUsecase,
    );
  });

  tearDown(() {
    userSearchViewModel.close();
  });

  // Sample test data
  final sampleUsers = [
    UserEntity(
      userId: '1',
      username: 'john_doe',
      email: 'john@example.com',
      profilePhoto: 'http://example.com/photo1.jpg',
      
    ),
    UserEntity(
      userId: '2',
      username: 'jane_smith',
      email: 'jane@example.com',
      profilePhoto: 'http://example.com/photo2.jpg',
      
    ),
  ];

  final expectedResults = [
    const UserSearchResult(
      id: '1',
      username: 'john_doe',
      email: 'john@example.com',
      profilePhoto: 'http://example.com/photo1.jpg',
    ),
    const UserSearchResult(
      id: '2',
      username: 'jane_smith',
      email: 'jane@example.com',
      profilePhoto: 'http://example.com/photo2.jpg',
    ),
  ];

  group('UserSearchViewModel Tests', () {
    test('initial state should be correct', () {
      expect(userSearchViewModel.state, equals(const UserSearchState()));
    });

    blocTest<UserSearchViewModel, UserSearchState>(
      'emits empty results when query is empty',
      build: () => userSearchViewModel,
      act: (cubit) => cubit.searchUsers(''),
      wait: const Duration(milliseconds: 350), // Wait for debounce
      expect: () => [
        const UserSearchState(results: [], error: null, isLoading: false),
      ],
      verify: (_) {
        // Should not call the use case for empty query
        verifyNever(() => mockSearchUsersUsecase(any()));
      },
    );

    blocTest<UserSearchViewModel, UserSearchState>(
      'emits [loading, success] when search is successful',
      build: () {
        when(() => mockSearchUsersUsecase(any()))
            .thenAnswer((_) async => Right(sampleUsers));
        return userSearchViewModel;
      },
      act: (cubit) => cubit.searchUsers('john'),
      wait: const Duration(milliseconds: 350), // Wait for debounce
      expect: () => [
        const UserSearchState(isLoading: true, error: null),
        UserSearchState(results: expectedResults, isLoading: false),
      ],
      verify: (_) {
        verify(() => mockSearchUsersUsecase(
          const SearchUsersParams(query: 'john'),
        )).called(1);
      },
    );

    

    blocTest<UserSearchViewModel, UserSearchState>(
      'debounces multiple rapid searches and only executes the last one',
      build: () {
        when(() => mockSearchUsersUsecase(any()))
            .thenAnswer((_) async => Right(sampleUsers));
        return userSearchViewModel;
      },
      act: (cubit) async {
        cubit.searchUsers('j');
        cubit.searchUsers('jo');
        cubit.searchUsers('joh');
        cubit.searchUsers('john'); // Only this should execute
      },
      wait: const Duration(milliseconds: 350), // Wait for debounce
      expect: () => [
        const UserSearchState(isLoading: true, error: null),
        UserSearchState(results: expectedResults, isLoading: false),
      ],
      verify: (_) {
        // Should only be called once with the final query
        verify(() => mockSearchUsersUsecase(
          const SearchUsersParams(query: 'john'),
        )).called(1);
      },
    );

    blocTest<UserSearchViewModel, UserSearchState>(
      'handles users with null profilePhoto correctly',
      build: () {
        final usersWithNullPhoto = [
          UserEntity(
            userId: '3',
            username: 'no_photo_user',
            email: 'nophoto@example.com',
            profilePhoto: null, // null photo
            
          ),
        ];
        
        when(() => mockSearchUsersUsecase(any()))
            .thenAnswer((_) async => Right(usersWithNullPhoto));
        return userSearchViewModel;
      },
      act: (cubit) => cubit.searchUsers('nophoto'),
      wait: const Duration(milliseconds: 350),
      expect: () => [
        const UserSearchState(isLoading: true, error: null),
        const UserSearchState(
          results: [
            UserSearchResult(
              id: '3',
              username: 'no_photo_user',
              email: 'nophoto@example.com',
              profilePhoto: null,
            ),
          ],
          isLoading: false,
        ),
      ],
    );

    

    test('cancels timer when cubit is closed', () async {
      // Start a search to create a timer
      userSearchViewModel.searchUsers('test');
      
      // Close the cubit immediately
      await userSearchViewModel.close();
      
      // Wait for the debounce period
      await Future.delayed(const Duration(milliseconds: 350));
      
      // Verify the use case was never called because timer was cancelled
      verifyNever(() => mockSearchUsersUsecase(any()));
    });

    blocTest<UserSearchViewModel, UserSearchState>(
      'handles empty search results correctly',
      build: () {
        when(() => mockSearchUsersUsecase(any()))
            .thenAnswer((_) async => const Right([])); // Empty list
        return userSearchViewModel;
      },
      act: (cubit) => cubit.searchUsers('nonexistent'),
      wait: const Duration(milliseconds: 350),
      expect: () => [
        const UserSearchState(isLoading: true, error: null),
        const UserSearchState(results: [], isLoading: false),
      ],
      verify: (_) {
        verify(() => mockSearchUsersUsecase(
          const SearchUsersParams(query: 'nonexistent'),
        )).called(1);
      },
    );
  });
}