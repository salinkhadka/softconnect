import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/auth/domain/use_case/user_login_usecase.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_event.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_state.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';

class MockUserLoginUsecase extends Mock implements UserLoginUsecase {}


class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late MockUserLoginUsecase mockUserLoginUsecase;
  late MockBuildContext mockContext;
  late LoginViewModel loginViewModel;

  const String testUsername = 'testuser';
  const String testPassword = 'testpassword';
  const String testToken = 'some_auth_token';

  setUpAll(() {
    registerFallbackValue(UserLoginParams(username: '', password: ''));
  });

  setUp(() {
    mockUserLoginUsecase = MockUserLoginUsecase();
    mockContext = MockBuildContext();
    loginViewModel = LoginViewModel(userLoginUsecase: mockUserLoginUsecase);

    when(() => mockContext.mounted).thenReturn(true);
  });

  tearDown(() {
    loginViewModel.close();
  });

  test('initial state should be LoginState.initial()', () {
    expect(loginViewModel.state, LoginState.initial());
  });

  group('LoginUserEvent', () {
    blocTest<LoginViewModel, LoginState>(
      'emits [isLoading: true, isSuccess: true] when login succeeds',
      build: () {
        when(() => mockUserLoginUsecase.call(
              UserLoginParams(username: testUsername, password: testPassword),
            )).thenAnswer((_) async => const Right(testToken));
        return LoginViewModel(userLoginUsecase: mockUserLoginUsecase);
      },
      act: (bloc) => bloc.add(LoginUserEvent(
        username: testUsername,
        password: testPassword,
        context: mockContext,
      )),
      expect: () => [
        const LoginState(isLoading: true, isSuccess: false),
        const LoginState(isLoading: false, isSuccess: true),
      ],
      verify: (_) {
        verify(() => mockUserLoginUsecase.call(
              UserLoginParams(username: testUsername, password: testPassword),
            )).called(1);
      },
    );

    blocTest<LoginViewModel, LoginState>(
      'emits [isLoading: true, isSuccess: false, errorMessage] when login fails',
      build: () {
        when(() => mockUserLoginUsecase.call(
              UserLoginParams(username: testUsername, password: testPassword),
            )).thenAnswer((_) async =>
            Left(LocalDatabaseFailure(message: 'Login failed')));
        return LoginViewModel(userLoginUsecase: mockUserLoginUsecase);
      },
      act: (bloc) => bloc.add(LoginUserEvent(
        username: testUsername,
        password: testPassword,
        context: mockContext,
      )),
      expect: () => [
        const LoginState(isLoading: true, isSuccess: false),
        const LoginState(isLoading: false, isSuccess: false, errorMessage: 'Login failed'),
      ],
      verify: (_) {
        verify(() => mockUserLoginUsecase.call(
              UserLoginParams(username: testUsername, password: testPassword),
            )).called(1);
      },
    );
  });
}
