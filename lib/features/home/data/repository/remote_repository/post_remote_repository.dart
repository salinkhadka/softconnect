import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/features/home/data/data_source/post_datasource.dart';
import 'package:softconnect/features/home/data/model/post_model.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';
import 'package:softconnect/features/home/domain/repository/post_repository.dart';

class PostRemoteRepository implements IPostRepository {
  final IPostsDataSource _postDataSource;

  PostRemoteRepository({required IPostsDataSource postDataSource, required ApiService apiService})
      : _postDataSource = postDataSource;

  @override
  Future<Either<Failure, List<PostEntity>>> getAllPosts() async {
    try {
      final models = await _postDataSource.getAllPosts();
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getPostsByUserId(String userId) async {
    try {
      final models = await _postDataSource.getPostsByUserId(userId);
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(String postId) async {
    try {
      final model = await _postDataSource.getPostById(postId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> createPost({
    required String userId,
    required String content,
    required String privacy,
    String? imagePath,
  }) async {
    try {
      final model = await _postDataSource.createPost(
        userId: userId,
        content: content,
        privacy: privacy,
        imagePath: imagePath,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> updatePost({
    required String postId,
    String? content,
    String? privacy,
    String? imagePath,
  }) async {
    try {
      final model = await _postDataSource.updatePost(
        postId: postId,
        content: content,
        privacy: privacy,
        imagePath: imagePath,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await _postDataSource.deletePost(postId);
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(File postImg) async {
    try {
      final url = await _postDataSource.uploadImage(postImg);
      return Right(url);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }
}
