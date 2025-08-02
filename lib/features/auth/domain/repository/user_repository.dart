import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';

abstract interface class IUserRepository {
  Future<Either<Failure, void>> registerUser(UserEntity user);

  Future<Either<Failure, Map<String, dynamic>>> loginUser(
    String username,
    String password,
  );

  Future<Either<Failure, String>> uploadProfilePicture(File file);

  Future<Either<Failure, UserEntity>> getCurrentUser(String id);

  // New method for searching users by query string
  Future<Either<Failure, List<UserEntity>>> searchUsers(String query);
  Future<Either<Failure, void>> requestPasswordReset(String email);

  Future<Either<Failure, void>> resetPassword(String token, String newPassword);

  Future<Either<Failure, String>> verifyPassword(
      String userId, String currentPassword);
      Future<Either<Failure, Map<String, dynamic>>> googleLogin(String idToken);
}
