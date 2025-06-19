import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/core/utils/mysnackbar.dart';
import 'package:softconnect/features/auth/domain/use_case/user_login_usecase.dart';
import 'package:softconnect/features/auth/presentation/view/View/signup.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_viewmodel.dart';
// import 'package:softconnect/features/auth/presentation/view/signup_screen.dart'; // Add this import
import 'login_event.dart';
import 'login_state.dart';

class LoginViewModel extends Bloc<LoginEvent, LoginState> {
  final UserLoginUsecase _userLoginUsecase;

  LoginViewModel({
    required UserLoginUsecase userLoginUsecase,
  })  : _userLoginUsecase = userLoginUsecase,
        super(LoginState.initial()) {
    on<LoginUserEvent>(_onLoginUser);
    on<NavigateToSignUpEvent>(_onNavigateToSignUp); // 👈 Register the event
  }

  Future<void> _onLoginUser(
    LoginUserEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, errorMessage: null));

    final result = await _userLoginUsecase.call(
      UserLoginParams(username: event.username, password: event.password),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, isSuccess: false, errorMessage: failure.message));
        showMySnackBar(
          context: event.context,
          message: failure.message,
          color: Colors.red,
        );
      },
      (user) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
        showMySnackBar(
          context: event.context,
          message: 'Login Successful!',
          color: Colors.green,
        );
        // Navigate to home or dashboard if needed
      },
    );
  }

  void _onNavigateToSignUp(
  NavigateToSignUpEvent event,
  Emitter<LoginState> emit,
) {
  Navigator.of(event.context).push(
    MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (_) => serviceLocator<SignupViewModel>(),
        child: SignupScreen(),
      ),
    ),
  );
  }
}
