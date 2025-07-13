import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/core/utils/mysnackbar.dart';
import 'package:softconnect/features/auth/domain/use_case/user_login_usecase.dart';
import 'package:softconnect/features/auth/presentation/view/View/signup.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view/HomePage.dart';
import 'package:softconnect/features/home/presentation/view_model/homepage_viewmodel.dart';
// import 'package:softconnect/features/auth/presentation/view/signup_screen.dart'; // Add this import
import 'login_event.dart';
import 'login_state.dart';

// login_view_model.dart

class LoginViewModel extends Bloc<LoginEvent, LoginState> {
  final UserLoginUsecase _userLoginUsecase;

  LoginViewModel({
    required UserLoginUsecase userLoginUsecase,
  })  : _userLoginUsecase = userLoginUsecase,
        super(LoginState.initial()) {
    on<LoginUserEvent>(_onLoginUser);
    on<NavigateToSignUpEvent>(_onNavigateToSignUp);
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
        try {
          showMySnackBar(
            context: event.context,
            message: failure.message,
            color: Colors.red,
          );
        } catch (e) {
          debugPrint('showMySnackBar failed: $e');
        }
      },
      (user) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
        try {
          showMySnackBar(
            context: event.context,
            message: 'Login Successful!',
            color: Colors.green,
          );
        } catch (e) {
          debugPrint('showMySnackBar failed: $e');
        }
        try {
          Navigator.of(event.context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (_) => serviceLocator<HomeViewModel>(),
                child: const HomePage(),
              ),
            ),
          );
        } catch (e) {
          debugPrint('Navigation to HomePage failed: $e');
        }
      },
    );
  }

  void _onNavigateToSignUp(
    NavigateToSignUpEvent event,
    Emitter<LoginState> emit,
  ) {
    try {
      Navigator.of(event.context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => serviceLocator<SignupViewModel>(),
            child: SignupScreen(),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Navigation to SignupScreen failed: $e');
    }
  }
}
