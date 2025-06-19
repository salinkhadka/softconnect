import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const LoginState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  factory LoginState.initial() => const LoginState();

  LoginState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, errorMessage];
}
