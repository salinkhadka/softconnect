import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/core/utils/mysnackbar.dart';
// import 'package:softconnect/features/auth/domain/entity/user_entity.dart';
import 'package:softconnect/features/auth/domain/use_case/user_login_usecase.dart';
import 'package:softconnect/features/auth/presentation/view/View/signup.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view/HomePage.dart';
import 'package:softconnect/features/home/presentation/view_model/homepage_viewmodel.dart';
import 'login_event.dart';
import 'login_state.dart';

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

    if (emit.isDone) return;

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => null);
      if (failure != null && !emit.isDone) {
        emit(state.copyWith(
            isLoading: false, isSuccess: false, errorMessage: failure.message));
        showMySnackBar(
          context: event.context,
          message: failure.message,
          color: Colors.red,
        );
      }
    } else {
      final map = result.getOrElse(() => {});
      final token = map['token'] as String;
      final user = map['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userId', user.userId ?? '');
      await prefs.setString('role', user.role);
      await prefs.setString('username', user.username ?? '');

      if (!emit.isDone) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
      }

      showMySnackBar(
        context: event.context,
        message: 'Login Successful!',
        color: Colors.green,
      );

      Navigator.of(event.context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => serviceLocator<HomeViewModel>(),
            child: const HomePage(),
          ),
        ),
      );
    }
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
