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

  try {
    String? uploadedImageFilename;

    if (state.profilePhotoPath != null && state.profilePhotoPath!.isNotEmpty) {
      final file = File(state.profilePhotoPath!);

      // Upload image file first and get server filename
      uploadedImageFilename = await _userRegisterUsecase.uploadProfilePicture(file);
    }

    // Register user with uploaded image filename (or null if no photo)
    final result = await _userRegisterUsecase.call(RegisterUserParams(
      email: event.email,
      username: event.username,
      studentId: event.studentId,
      password: event.password,
      profilePhoto: uploadedImageFilename,
      bio: null,
      role: event.role,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
          message: failure.message,
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
  } catch (e) {
    emit(state.copyWith(
      isLoading: false,
      isSuccess: false,
      message: 'Unexpected error: $e',
    ));
  }
}

}
