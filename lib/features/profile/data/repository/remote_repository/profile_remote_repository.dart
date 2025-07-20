import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';
import 'package:softconnect/features/profile/data/data_source/profile_page_datasource.dart';
import 'package:softconnect/features/profile/domain/repository/profile_repository.dart';

class ProfileRemoteRepository implements IProfileRepository {
  final IProfilePageDataSource _dataSource;

  ProfileRemoteRepository({required IProfilePageDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile({
    required String userId,
    required String username,
    required String email,
    String? bio,
    String? profilePhoto, // ✅ Added this
  }) async {
    try {
      final user = await _dataSource.updateUserProfile(
        userId: userId,
        username: username,
        email: email,
        bio: bio,
        profilePhoto: profilePhoto, // ✅ Pass it to the data source
      );
      return Right(user);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }
}
