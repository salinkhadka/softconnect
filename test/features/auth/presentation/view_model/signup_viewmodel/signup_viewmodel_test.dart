import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:softconnect/features/auth/domain/use_case/user_register_usecase.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_event.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_state.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_viewmodel.dart';

class MockUserRegisterUsecase extends Mock implements UserRegisterUsecase {}

class FakeRegisterUserParams extends Fake implements RegisterUserParams {}

void main() {
  late MockUserRegisterUsecase mockUserRegisterUsecase;
  late SignupViewModel signupViewModel;

  const testEmail = 'test@example.com';
  const testUsername = 'testuser';
  const testStudentId = 1234;
  const testPassword = 'password123';
  const testRole = 'Student';

  setUpAll(() {
    registerFallbackValue(FakeRegisterUserParams());
  });

  setUp(() {
    mockUserRegisterUsecase = MockUserRegisterUsecase();
    signupViewModel = SignupViewModel(userRegisterUsecase: mockUserRegisterUsecase);
  });

  tearDown(() {
    signupViewModel.close();
  });

  blocTest<SignupViewModel, SignupState>(
  'emits loading then success when register succeeds',
  build: () {
    when(() => mockUserRegisterUsecase.call(any()))
        .thenAnswer((_) async => const Right(null));
    return signupViewModel;
  },
  act: (bloc) => bloc.add(SignupButtonPressed(
    email: testEmail,
    username: testUsername,
    studentId: testStudentId,
    password: testPassword,
    role: testRole,
  )),
  expect: () => [
    SignupState.initial().copyWith(isLoading: true, message: null),
    SignupState.initial().copyWith(
      isLoading: false,
      isSuccess: true,
      message: "Signup successful!",
    ),
  ],
  verify: (_) {
    verify(() => mockUserRegisterUsecase.call(any())).called(1);
  },
);

}
