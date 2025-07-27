// login_state.dart
import 'package:flutter/material.dart';

class LoginState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final bool obscurePassword;
  final bool isBiometricAvailable;
  final bool hasStoredCredentials;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginState({
    required this.isLoading,
    required this.isSuccess,
    this.errorMessage,
    required this.obscurePassword,
    required this.isBiometricAvailable,
    required this.hasStoredCredentials,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });

  factory LoginState.initial() {
    return LoginState(
      isLoading: false,
      isSuccess: false,
      errorMessage: null,
      obscurePassword: true,
      isBiometricAvailable: false,
      hasStoredCredentials: false,
      formKey: GlobalKey<FormState>(),
      emailController: TextEditingController(),
      passwordController: TextEditingController(),
    );
  }

  LoginState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool? obscurePassword,
    bool? isBiometricAvailable,
    bool? hasStoredCredentials,
    GlobalKey<FormState>? formKey,
    TextEditingController? emailController,
    TextEditingController? passwordController,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      hasStoredCredentials: hasStoredCredentials ?? this.hasStoredCredentials,
      formKey: formKey ?? this.formKey,
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
    );
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}