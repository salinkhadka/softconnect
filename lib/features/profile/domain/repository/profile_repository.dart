import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';

abstract interface class IProfileRepository {
  Future<Either<Failure, UserEntity>> updateUserProfile({
    required String userId,
    required String username,
    required String email,
    String? bio,
    String? profilePhoto, // Added
  });
}
