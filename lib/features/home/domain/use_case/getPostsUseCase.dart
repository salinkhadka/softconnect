import 'package:dartz/dartz.dart';
// import 'package:equatable/equatable.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';
import 'package:softconnect/features/home/domain/repository/post_repository.dart';

// For fetching all posts (no params)
class GetAllPostsUsecase implements UsecaseWithoutParams<List<PostEntity>> {
  final IPostRepository _postRepository;

  GetAllPostsUsecase({required IPostRepository postRepository})
      : _postRepository = postRepository;

  @override
  Future<Either<Failure, List<PostEntity>>> call() async {
    return await _postRepository.getAllPosts();
  }
}

// For fetching posts by user ID (with params)
class GetPostsByUserIdParams {
  final String userId;
  GetPostsByUserIdParams(this.userId);
}

class GetPostsByUserIdUsecase implements UsecaseWithParams<List<PostEntity>, GetPostsByUserIdParams> {
  final IPostRepository _postRepository;

  GetPostsByUserIdUsecase({required IPostRepository postRepository})
      : _postRepository = postRepository;

  @override
  Future<Either<Failure, List<PostEntity>>> call(GetPostsByUserIdParams params) async {
    return await _postRepository.getPostsByUserId(params.userId);
  }
}

