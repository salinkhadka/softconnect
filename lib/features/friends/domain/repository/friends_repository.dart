import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/friends/domain/entity/follow_entity.dart';

abstract interface class IFriendsRepository {
  Future<Either<Failure, FollowEntity>> followUser(String followeeId);

  Future<Either<Failure, void>> unfollowUser(String followeeId);

  Future<Either<Failure, List<FollowEntity>>> getFollowers(String userId);

  Future<Either<Failure, List<FollowEntity>>> getFollowing(String userId);
}
