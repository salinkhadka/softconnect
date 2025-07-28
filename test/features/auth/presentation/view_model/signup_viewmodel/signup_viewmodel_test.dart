import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/auth/domain/use_case/user_register_usecase.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_event.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_state.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_viewmodel.dart';

// -----------------------------
// Fakes and Mocks
// -----------------------------
class FakeFile extends Fake implements File {}

class FakeRegisterUserParams extends Fake implements RegisterUserParams {}

class MockUserRegisterUsecase extends Mock implements UserRegisterUsecase {}

void main() {
  late MockUserRegisterUsecase mockUserRegisterUsecase;
  late SignupViewModel signupViewModel;

  const testEmail = 'test@example.com';
  const testUsername = 'testuser';
  const testStudentId = 1234;
  const testPassword = 'password123';
  const testRole = 'Student';
  const testProfilePhotoPath = 'some_path.jpg';
  const uploadedFileName = 'mocked_image.jpg';

  setUpAll(() {
    registerFallbackValue(FakeFile());
    registerFallbackValue(FakeRegisterUserParams());
  });

  setUp(() {
    mockUserRegisterUsecase = MockUserRegisterUsecase();
    signupViewModel = SignupViewModel(userRegisterUsecase: mockUserRegisterUsecase);
  });

  tearDown(() {
    signupViewModel.close();
  });

  group('SignupViewModel tests', () {
    blocTest<SignupViewModel, SignupState>(
      'emits loading then success when register succeeds',
      build: () {
        when(() => mockUserRegisterUsecase.uploadProfilePicture(any()))
            .thenAnswer((_) async => uploadedFileName);

        when(() => mockUserRegisterUsecase.call(any()))
            .thenAnswer((_) async => const Right(null));

        return signupViewModel;
      },
      act: (bloc) {
        bloc.add(const ProfilePhotoChanged(testProfilePhotoPath));
        bloc.add(const SignupButtonPressed(
          email: testEmail,
          username: testUsername,
          studentId: testStudentId,
          password: testPassword,
          role: testRole,
        ));
      },
      expect: () => [
        SignupState.initial().copyWith(profilePhotoPath: testProfilePhotoPath),
        SignupState.initial().copyWith(
          profilePhotoPath: testProfilePhotoPath,
          isLoading: true,
          message: null,
        ),
        SignupState.initial().copyWith(
          profilePhotoPath: testProfilePhotoPath,
          isLoading: false,
          isSuccess: true,
          message: "Signup successful!",
        ),
      ],
      verify: (_) {
        verify(() => mockUserRegisterUsecase.uploadProfilePicture(any())).called(1);
        verify(() => mockUserRegisterUsecase.call(any())).called(1);
      },
    );

    blocTest<SignupViewModel, SignupState>(
      'emits loading then failure when register fails',
      build: () {
        when(() => mockUserRegisterUsecase.uploadProfilePicture(any()))
            .thenAnswer((_) async => uploadedFileName);

        when(() => mockUserRegisterUsecase.call(any()))
            .thenAnswer((_) async =>
                Left(RemoteDatabaseFailure(message: 'Signup failed: email exists')));

        return signupViewModel;
      },
      act: (bloc) {
        bloc.add(const ProfilePhotoChanged(testProfilePhotoPath));
        bloc.add(const SignupButtonPressed(
          email: testEmail,
          username: testUsername,
          studentId: testStudentId,
          password: testPassword,
          role: testRole,
        ));
      },
      expect: () => [
        SignupState.initial().copyWith(profilePhotoPath: testProfilePhotoPath),
        SignupState.initial().copyWith(
          profilePhotoPath: testProfilePhotoPath,
          isLoading: true,
          message: null,
        ),
        SignupState.initial().copyWith(
          profilePhotoPath: testProfilePhotoPath,
          isLoading: false,
          isSuccess: false,
          message: 'Signup failed: email exists',
        ),
      ],
      verify: (_) {
        verify(() => mockUserRegisterUsecase.uploadProfilePicture(any())).called(1);
        verify(() => mockUserRegisterUsecase.call(any())).called(1);
      },
    );

    // New test 1: Password visibility toggle
    blocTest<SignupViewModel, SignupState>(
      'toggles password visibility',
      build: () => signupViewModel,
      act: (bloc) => bloc.add(PasswordVisibilityToggled()),
      expect: () => [
        SignupState.initial().copyWith(obscurePassword: false),
      ],
    );

    // New test 2: Toggle agreedToTerms flag
    blocTest<SignupViewModel, SignupState>(
      'toggles agreedToTerms',
      build: () => signupViewModel,
      act: (bloc) => bloc.add(const AgreedToTermsToggled(true)),
      expect: () => [
        SignupState.initial().copyWith(agreedToTerms: true),
      ],
    );
  });
}
