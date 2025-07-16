import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/features/home/data/data_source/comment_datasource.dart';
// import 'package:softconnect/features/home/data/model/comment_model.dart';
import 'package:softconnect/features/home/domain/entity/comment_entity.dart';
import 'package:softconnect/features/home/domain/repository/comment_repository.dart';

class CommentRemoteRepository implements ICommentRepository {
  final ICommentDataSource _commentDataSource;

  CommentRemoteRepository({required ICommentDataSource commentDataSource})
      : _commentDataSource = commentDataSource;

  @override
  Future<Either<Failure, CommentEntity>> createComment({
    required String userId,
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final model = await _commentDataSource.createComment(
        userId: userId,
        postId: postId,
        content: content,
        parentCommentId: parentCommentId,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await _commentDataSource.deleteComment(commentId);
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getCommentsByPostId(String postId) async {
    try {
      final models = await _commentDataSource.getCommentsByPostId(postId);
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }
}
