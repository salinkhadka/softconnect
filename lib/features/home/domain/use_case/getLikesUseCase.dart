import 'package:dartz/dartz.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/home/domain/entity/like_entity.dart';
import 'package:softconnect/features/home/domain/repository/like_repository.dart';

// Params class for postId
class GetLikesByPostIdParams {
  final String postId;
  GetLikesByPostIdParams(this.postId);
}

// Get all likes for a post (with params)
class GetLikesByPostIdUsecase implements UsecaseWithParams<List<LikeEntity>, GetLikesByPostIdParams> {
  final ILikeRepository _likeRepository;

  GetLikesByPostIdUsecase({required ILikeRepository likeRepository}) : _likeRepository = likeRepository;

  @override
  Future<Either<Failure, List<LikeEntity>>> call(GetLikesByPostIdParams params) async {
    return await _likeRepository.getLikesByPostId(params.postId);
  }
}

// Params class for likePost
class LikePostParams {
  final String userId;
  final String postId;

  LikePostParams({required this.userId, required this.postId});
}

// Like a post (with params)
class LikePostUsecase implements UsecaseWithParams<LikeEntity, LikePostParams> {
  final ILikeRepository _likeRepository;

  LikePostUsecase({required ILikeRepository likeRepository}) : _likeRepository = likeRepository;

  @override
  Future<Either<Failure, LikeEntity>> call(LikePostParams params) async {
    return await _likeRepository.likePost(userId: params.userId, postId: params.postId);
  }
}

// Params class for unlikePost
class UnlikePostParams {
  final String userId;
  final String postId;

  UnlikePostParams({required this.userId, required this.postId});
}

// Unlike a post (with params)
class UnlikePostUsecase implements UsecaseWithParams<void, UnlikePostParams> {
  final ILikeRepository _likeRepository;

  UnlikePostUsecase({required ILikeRepository likeRepository}) : _likeRepository = likeRepository;

  @override
  Future<Either<Failure, void>> call(UnlikePostParams params) async {
    return await _likeRepository.unlikePost(userId: params.userId, postId: params.postId);
  }
}
