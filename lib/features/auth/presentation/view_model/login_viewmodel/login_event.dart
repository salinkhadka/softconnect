import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginUserEvent extends LoginEvent {
  final String username;
  final String password;
  final BuildContext context;

  const LoginUserEvent({
    required this.username,
    required this.password,
    required this.context,
  });

  @override
  List<Object?> get props => [username, password, context];
}
class NavigateToSignUpEvent extends LoginEvent {
  final BuildContext context;
  NavigateToSignUpEvent({required this.context});
}
