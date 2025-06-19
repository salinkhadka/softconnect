import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/core/utils/mysnackbar.dart';
// import 'package:softconnect/core/common/snackbar/my_snackbar.dart'; // your snackbar util
import 'package:softconnect/features/auth/domain/use_case/user_register_usecase.dart';
// import 'package:softconnect/features/auth/domain/usecase/user_register_usecase.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupViewModel extends Bloc<SignupEvent, SignupState> {
  final UserRegisterUsecase _userRegisterUsecase;

   SignupViewModel({required UserRegisterUsecase userRegisterUsecase})
      : _userRegisterUsecase = userRegisterUsecase,
        super(SignupState.initial()) {
    on<SignupButtonPressed>(_onSignupButtonPressed);
  }

  Future<void> _onSignupButtonPressed(
      SignupButtonPressed event, Emitter<SignupState> emit) async {
    emit(state.copyWith(isLoading: true));

    final result = await _userRegisterUsecase.call(RegisterUserParams(
      email: event.email,
      username: event.username,
      studentId: event.studentId,
      password: event.password,
      profilePhoto: null,
      bio: null,
      role: event.role,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, isSuccess: false));
        showMySnackBar(
          context: event.context,
          message: failure.message,
          color: Colors.red,
        );
      },
      (_) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
        showMySnackBar(
          context: event.context,
          message: "Signup successful!",
          color: Colors.green,
        );
      },
    );
  }
}

