import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/home/domain/entity/like_entity.dart';

abstract interface class ILikeRepository {
  Future<Either<Failure, LikeEntity>> likePost({
    required String userId,
    required String postId,
  });

  Future<Either<Failure, void>> unlikePost({
    required String userId,
    required String postId,
  });

  Future<Either<Failure, List<LikeEntity>>> getLikesByPostId(String postId);
}
