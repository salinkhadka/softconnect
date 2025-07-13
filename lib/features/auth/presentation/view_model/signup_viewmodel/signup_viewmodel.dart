import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/features/auth/domain/use_case/user_register_usecase.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupViewModel extends Bloc<SignupEvent, SignupState> {
  final UserRegisterUsecase _userRegisterUsecase;

  SignupViewModel({required UserRegisterUsecase userRegisterUsecase})
      : _userRegisterUsecase = userRegisterUsecase,
        super(SignupState.initial()) {
    on<SignupButtonPressed>(_onSignupButtonPressed);
    on<ProfilePhotoChanged>(_onProfilePhotoChanged);
    on<AgreedToTermsToggled>(_onAgreedToTermsToggled);
  }

  void _onProfilePhotoChanged(ProfilePhotoChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(profilePhotoPath: event.filePath));
  }

  void _onAgreedToTermsToggled(AgreedToTermsToggled event, Emitter<SignupState> emit) {
    emit(state.copyWith(agreedToTerms: event.value));
  }

  Future<void> _onSignupButtonPressed(SignupButtonPressed event, Emitter<SignupState> emit) async {
    emit(state.copyWith(isLoading: true, message: null));

    final result = await _userRegisterUsecase.call(RegisterUserParams(
      email: event.email,
      username: event.username,
      studentId: event.studentId,
      password: event.password,
      profilePhoto: state.profilePhotoPath,
      bio: null,
      role: event.role,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
          message: failure.message, // Pass message to state
        ));
      },
      (_) {
        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
          message: "Signup successful!",
        ));
      },
    );
  }
}
