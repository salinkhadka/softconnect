import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/service_locator/service_locator.dart';
import 'package:softconnect/core/utils/mysnackbar.dart';
import 'package:softconnect/features/auth/domain/use_case/user_login_usecase.dart';
import 'package:softconnect/features/auth/domain/use_case/google_login_usecase.dart';
import 'package:softconnect/features/auth/presentation/view/View/signup.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view/HomePage.dart';
import 'package:softconnect/features/home/presentation/view_model/homepage_viewmodel.dart';
import 'package:softconnect/google_auth_service.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginViewModel extends Bloc<LoginEvent, LoginState> {
  final UserLoginUsecase _userLoginUsecase;
  final GoogleLoginUsecase _googleLoginUsecase;
  final GoogleAuthService _googleAuthService;

  LoginViewModel({
    required UserLoginUsecase userLoginUsecase,
    required GoogleLoginUsecase googleLoginUsecase,
    required GoogleAuthService googleAuthService,
  })  : _userLoginUsecase = userLoginUsecase,
        _googleLoginUsecase = googleLoginUsecase,
        _googleAuthService = googleAuthService,
        super(LoginState.initial()) {
    on<LoginUserEvent>(_onLoginUser);
    on<NavigateToSignUpEvent>(_onNavigateToSignUp);
    on<GoogleLoginEvent>(_onGoogleLogin);
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
      await _handleSuccessfulLogin(result.getOrElse(() => {}), event.context, emit);
    }
  }

  Future<void> _onGoogleLogin(
    GoogleLoginEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, errorMessage: null));

    try {
      // Use selectAccountAndSignIn to force account selection
      final String? idToken = await _googleAuthService.selectAccountAndSignIn();
      
      if (idToken == null) {
        // User canceled the sign-in
        emit(state.copyWith(isLoading: false, isSuccess: false));
        showMySnackBar(
          context: event.context,
          message: 'Google Sign-In was cancelled',
          color: Colors.orange,
        );
        return;
      }

      // Call the backend with the ID token
      final result = await _googleLoginUsecase.call(
        GoogleLoginParams(idToken: idToken),
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
        await _handleSuccessfulLogin(result.getOrElse(() => {}), event.context, emit);
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(state.copyWith(
            isLoading: false, isSuccess: false, errorMessage: e.toString()));
        showMySnackBar(
          context: event.context,
          message: 'Google Sign-In failed: $e',
          color: Colors.red,
        );
      }
    }
  }

  Future<void> _handleSuccessfulLogin(
    Map<String, dynamic> loginData,
    BuildContext context,
    Emitter<LoginState> emit,
  ) async {
    final token = loginData['token'] as String;
    final user = loginData['user'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userId', user.userId ?? '');
    await prefs.setString('role', user.role);
    await prefs.setString('username', user.username ?? '');

    if (!emit.isDone) {
      emit(state.copyWith(isLoading: false, isSuccess: true));
    }

    showMySnackBar(
      context: context,
      message: 'Login Successful!',
      color: Colors.green,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => serviceLocator<HomeViewModel>(),
          child: const HomePage(),
        ),
      ),
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