import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';
import 'package:softconnect/features/home/domain/repository/post_repository.dart';

// ───────────────────────────── Get All Posts ─────────────────────────────
class GetAllPostsUsecase implements UsecaseWithoutParams<List<PostEntity>> {
  final IPostRepository _postRepository;

  GetAllPostsUsecase(this._postRepository);

  @override
  Future<Either<Failure, List<PostEntity>>> call() async {
    return await _postRepository.getAllPosts();
  }
}

// ──────────────────────── Get Posts by User ID ──────────────────────────
class GetPostsByUserIdParams {
  final String userId;
  GetPostsByUserIdParams(this.userId);
}

class GetPostsByUserIdUsecase
    implements UsecaseWithParams<List<PostEntity>, GetPostsByUserIdParams> {
  final IPostRepository _postRepository;

  GetPostsByUserIdUsecase(this._postRepository);

  @override
  Future<Either<Failure, List<PostEntity>>> call(GetPostsByUserIdParams params) {
    return _postRepository.getPostsByUserId(params.userId);
  }
}

// ───────────────────────────── Get Post by ID ───────────────────────────
class GetPostByIdParams {
  final String postId;
  GetPostByIdParams(this.postId);
}

class GetPostByIdUsecase
    implements UsecaseWithParams<PostEntity, GetPostByIdParams> {
  final IPostRepository _postRepository;

  GetPostByIdUsecase(this._postRepository);

  @override
  Future<Either<Failure, PostEntity>> call(GetPostByIdParams params) {
    return _postRepository.getPostById(params.postId);
  }
}

// ───────────────────────────── Create Post ──────────────────────────────
class CreatePostParams {
  final String userId;
  final String content;
  final String privacy;
  final String? imageUrl;  // updated here

  CreatePostParams({
    required this.userId,
    required this.content,
    required this.privacy,
    this.imageUrl,
  });
}

class CreatePostUsecase
    implements UsecaseWithParams<PostEntity, CreatePostParams> {
  final IPostRepository _postRepository;

  CreatePostUsecase(this._postRepository);

  @override
  Future<Either<Failure, PostEntity>> call(CreatePostParams params) {
    return _postRepository.createPost(
      userId: params.userId,
      content: params.content,
      privacy: params.privacy,
      imageUrl: params.imageUrl,  // updated here
    );
  }
}

// ───────────────────────────── Update Post ──────────────────────────────
class UpdatePostParams {
  final String postId;
  final String? content;
  final String? privacy;
  final String? imageUrl;  // updated here

  UpdatePostParams({
    required this.postId,
    this.content,
    this.privacy,
    this.imageUrl,
  });
}

class UpdatePostUsecase
    implements UsecaseWithParams<PostEntity, UpdatePostParams> {
  final IPostRepository _postRepository;

  UpdatePostUsecase(this._postRepository);

  @override
  Future<Either<Failure, PostEntity>> call(UpdatePostParams params) {
    return _postRepository.updatePost(
      postId: params.postId,
      content: params.content,
      privacy: params.privacy,
      imageUrl: params.imageUrl,  // updated here
    );
  }
}

// ───────────────────────────── Delete Post ──────────────────────────────
class DeletePostParams {
  final String postId;
  DeletePostParams(this.postId);
}

class DeletePostUsecase
    implements UsecaseWithParams<void, DeletePostParams> {
  final IPostRepository _postRepository;

  DeletePostUsecase(this._postRepository);

  @override
  Future<Either<Failure, void>> call(DeletePostParams params) {
    return _postRepository.deletePost(params.postId);
  }
}

class UploadImageParams {
  final File postImage;
  UploadImageParams(this.postImage);
}

class UploadImageUsecase
    implements UsecaseWithParams<String, UploadImageParams> {
  final IPostRepository _postRepository;

  UploadImageUsecase(this._postRepository);

  @override
  Future<Either<Failure, String>> call(UploadImageParams params) {
    return _postRepository.uploadImage(params.postImage);
  }
}
