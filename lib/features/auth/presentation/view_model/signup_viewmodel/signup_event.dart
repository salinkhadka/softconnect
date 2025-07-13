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
  // final BuildContext context;

  const SignupButtonPressed({
    required this.email,
    required this.username,
    required this.studentId,
    required this.password,
    required this.role,
    // required this.context,
  });

  @override
  List<Object?> get props => [email, username, studentId, password, role];
}

class ProfilePhotoChanged extends SignupEvent {
  final String filePath;

  const ProfilePhotoChanged(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class AgreedToTermsToggled extends SignupEvent {
  final bool value;

  const AgreedToTermsToggled(this.value);

  @override
  List<Object?> get props => [value];
}
