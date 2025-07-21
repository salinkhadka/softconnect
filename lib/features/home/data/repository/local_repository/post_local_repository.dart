import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';
import 'package:softconnect/features/home/domain/repository/post_repository.dart';

class PostLocalRepository implements IPostRepository{
  @override
  Future<Either<Failure, PostEntity>> createPost({required String userId, required String content, required String privacy, String? imageUrl}) {
    // TODO: implement createPost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) {
    // TODO: implement deletePost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getAllPosts() {
    // TODO: implement getAllPosts
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(String postId) {
    // TODO: implement getPostById
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getPostsByUserId(String userId) {
    // TODO: implement getPostsByUserId
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, PostEntity>> updatePost({required String postId, String? content, String? privacy, String? imageUrl}) {
    // TODO: implement updatePost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> uploadImage(File postImg) {
    // TODO: implement uploadImage
    throw UnimplementedError();
  }

}