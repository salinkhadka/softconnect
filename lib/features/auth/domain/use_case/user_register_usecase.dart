import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
// import 'package:softconnect/core/usecase/usecase.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';
import 'package:softconnect/features/auth/domain/repository/user_repository.dart';

/// ------------------- PARAMS -------------------

class RegisterUserParams extends Equatable {
  final String email;
  final String username;
  final int studentId;
  final String password;
  final String? profilePhoto;
  final String? bio;
  final String role;

  const RegisterUserParams({
    required this.email,
    required this.username,
    required this.studentId,
    required this.password,
    this.profilePhoto,
    this.bio,
    this.role = 'normal',
  });

  @override
  List<Object?> get props => [
        email,
        username,
        studentId,
        password,
        profilePhoto,
        bio,
        role,
      ];
}

/// ------------------- USE CASE -------------------

class UserRegisterUsecase
    implements UsecaseWithParams<void, RegisterUserParams> {
  final IUserRepository _userRepository;

  UserRegisterUsecase({required IUserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Either<Failure, void>> call(RegisterUserParams params) {
    final user = UserEntity(
      email: params.email,
      username: params.username,
      studentId: params.studentId,
      password: params.password,
      profilePhoto: params.profilePhoto,
      bio: params.bio,
      role: params.role,
    );
    return _userRepository.registerUser(user);
  }
   Future<String> uploadProfilePicture(File file) async {
    final result = await _userRepository.uploadProfilePicture(file);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (filename) => filename,
    );
  }
}
