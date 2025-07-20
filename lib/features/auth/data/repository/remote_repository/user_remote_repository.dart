import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/auth/data/data_source/remote_dataSource/user_remote_data_source.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';
import 'package:softconnect/features/auth/domain/repository/user_repository.dart';

class UserRemoteRepository implements IUserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRemoteRepository({required UserRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser(String id) async {
    try {
      final user = await _remoteDataSource.getCurrentUser(id);
      return Right(user);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> loginUser(
      String username, String password) async {
    try {
      final Map<String, dynamic> result =
          await _remoteDataSource.loginUser(username, password);
      return Right(result);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerUser(UserEntity user) async {
    try {
      await _remoteDataSource.registerUser(user);
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(File file) async {
    try {
      final filePath = await _remoteDataSource.uploadProfilePicture(file.path);
      return Right(filePath);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> searchUsers(String query) async {
    try {
      final users = await _remoteDataSource.searchUsers(query);
      return Right(users);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset(String email) async {
    try {
      await _remoteDataSource.requestPasswordReset(email);
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String token, String newPassword) async {
    try {
      await _remoteDataSource.resetPassword(token, newPassword);
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyPassword(String userId, String currentPassword) async {
    try {
      final token = await _remoteDataSource.verifyPassword(userId, currentPassword);
      return Right(token);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }
}
