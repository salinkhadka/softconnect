import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';

abstract interface class IPostRepository {
  Future<Either<Failure, List<PostEntity>>> getAllPosts();

  Future<Either<Failure, List<PostEntity>>> getPostsByUserId(String userId);

  Future<Either<Failure, PostEntity>> getPostById(String postId);

  Future<Either<Failure, PostEntity>> createPost({
    required String userId,
    required String content,
    required String privacy,
    String? imageUrl,  // <-- change here
  });

  Future<Either<Failure, PostEntity>> updatePost({
    required String postId,
    String? content,
    String? privacy,
    String? imageUrl,  // <-- change here
  });

  Future<Either<Failure, void>> deletePost(String postId);

  Future<Either<Failure, String>> uploadImage(File postImg);
}
