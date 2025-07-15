import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/friends/data/data_source/friends_data_source.dart';
import 'package:softconnect/features/friends/data/model/follow_model.dart';
import 'package:softconnect/features/friends/domain/entity/follow_entity.dart';
import 'package:softconnect/features/friends/domain/repository/friends_repository.dart';

class FriendsRemoteRepository implements IFriendsRepository {
  final IFriendsDataSource _friendsDataSource;

  FriendsRemoteRepository({required IFriendsDataSource friendsDataSource})
      : _friendsDataSource = friendsDataSource;

  @override
  Future<Either<Failure, FollowEntity>> followUser(String followeeId) async {
    try {
      final FollowModel model = await _friendsDataSource.followUser(followeeId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unfollowUser(String followeeId) async {
    try {
      await _friendsDataSource.unfollowUser(followeeId);
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FollowEntity>>> getFollowers(String userId) async {
    try {
      final List<FollowModel> models = await _friendsDataSource.getFollowers(userId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FollowEntity>>> getFollowing(String userId) async {
    try {
      final List<FollowModel> models = await _friendsDataSource.getFollowing(userId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }
}
