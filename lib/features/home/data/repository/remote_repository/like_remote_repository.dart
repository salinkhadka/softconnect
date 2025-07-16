import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/features/home/data/data_source/like_datasource.dart';
import 'package:softconnect/features/home/data/model/like_model.dart';
import 'package:softconnect/features/home/domain/entity/like_entity.dart';
import 'package:softconnect/features/home/domain/repository/like_repository.dart';

class LikeRemoteRepository implements ILikeRepository {
  final ILikeDataSource _likeDataSource;

  LikeRemoteRepository({required ILikeDataSource likeDataSource})
      : _likeDataSource = likeDataSource;

  @override
  Future<Either<Failure, LikeEntity>> likePost({
    required String userId,
    required String postId,
  }) async {
    try {
      final model = await _likeDataSource.likePost(userId: userId, postId: postId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unlikePost({
    required String userId,
    required String postId,
  }) async {
    try {
      await _likeDataSource.unlikePost(userId: userId, postId: postId);
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LikeEntity>>> getLikesByPostId(String postId) async {
    try {
      final models = await _likeDataSource.getLikesByPostId(postId);
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }
}
