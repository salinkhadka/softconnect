import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/home/domain/entity/comment_entity.dart';
// import 'package:softconnect/features/home/domain/use_case/create_comment_usecase.dart';
import 'package:softconnect/features/home/domain/use_case/getCommentsUseCase.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_event.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_state.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_view_model.dart';
// import 'package:softconnect/features/home/domain/use_case/delete_comment_usecase.dart';

// import 'package:softconnect/features/home/presentation/viewmodel/comment_viewmodel.dart';
// import 'package:softconnect/features/home/presentation/viewmodel/comment_event.dart';
// import 'package:softconnect/features/home/presentation/viewmodel/comment_state.dart';

// Mock classes
class MockCreateCommentUsecase extends Mock implements CreateCommentUsecase {}
class MockGetCommentsByPostIdUsecase extends Mock implements GetCommentsByPostIdUsecase {}
class MockDeleteCommentUsecase extends Mock implements DeleteCommentUsecase {}

// Fake classes for mocktail
class FakeCreateCommentParams extends Fake implements CreateCommentParams {}
class FakeGetCommentsByPostIdParams extends Fake implements GetCommentsByPostIdParams {}
class FakeDeleteCommentParams extends Fake implements DeleteCommentParams {}

void main() {
  late MockCreateCommentUsecase mockCreateCommentUsecase;
  late MockGetCommentsByPostIdUsecase mockGetCommentsByPostIdUsecase;
  late MockDeleteCommentUsecase mockDeleteCommentUsecase;
  late CommentViewModel commentViewModel;

  setUpAll(() {
    registerFallbackValue(FakeCreateCommentParams());
    registerFallbackValue(FakeGetCommentsByPostIdParams());
    registerFallbackValue(FakeDeleteCommentParams());
  });

  setUp(() {
    mockCreateCommentUsecase = MockCreateCommentUsecase();
    mockGetCommentsByPostIdUsecase = MockGetCommentsByPostIdUsecase();
    mockDeleteCommentUsecase = MockDeleteCommentUsecase();
    
    commentViewModel = CommentViewModel(
      createCommentUsecase: mockCreateCommentUsecase,
      getCommentsUsecase: mockGetCommentsByPostIdUsecase,
      deleteCommentUsecase: mockDeleteCommentUsecase,
    );
  });

  tearDown(() {
    commentViewModel.close();
  });

  // Sample test data
  final sampleComments = [
    CommentEntity(
      id: '1',
      postId: 'post1',
      userId: 'user1',
      username: 'testuser1',
      profilePhoto: 'https://example.com/avatar1.jpg',
      content: 'Test comment 1',
      parentCommentId: null,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    CommentEntity(
      id: '2',
      postId: 'post1',
      userId: 'user2',
      username: 'testuser2',
      profilePhoto: 'https://example.com/avatar2.jpg',
      content: 'Test comment 2',
      parentCommentId: null,
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
    ),
  ];

  final newComment = CommentEntity(
    id: '3',
    postId: 'post1',
    userId: 'user3',
    username: 'testuser3',
    profilePhoto: 'https://example.com/avatar3.jpg',
    content: 'New test comment',
    parentCommentId: null,
    createdAt: DateTime(2024, 1, 3),
    updatedAt: DateTime(2024, 1, 3),
  );

  const testPostId = 'post1';
  const testUserId = 'user3';
  const testContent = 'New test comment';
  const testCommentId = '1';

  group('CommentViewModel Tests', () {
    

    group('State Management', () {
    

      test('copyWith can clear error by setting to null', () {
        final stateWithError = CommentState.initial().copyWith(
          error: 'Previous error',
        );

        final clearedState = stateWithError.copyWith(error: null);

        expect(clearedState.error, isNull);
      });

      test('initial state has correct default values', () {
        final initialState = CommentState.initial();
        
        expect(initialState.comments, isEmpty);
        expect(initialState.isLoading, isFalse);
        expect(initialState.error, isNull);
      });
    });

    
  });
}