import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object?> get props => [];
}

class SignupButtonPressed extends SignupEvent {
  final String email;
  final String username;
  final int studentId;
  final String password;
  final String role;
  final BuildContext context; // pass context for snackbar

  const SignupButtonPressed({
    required this.email,
    required this.username,
    required this.studentId,
    required this.password,
    required this.role,
    required this.context,
  });

  @override
  List<Object?> get props => [email, username, studentId, password, role, context];
}
