import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/home/domain/entity/comment_entity.dart';

abstract interface class ICommentRepository {
  Future<Either<Failure, CommentEntity>> createComment({
    required String userId,
    required String postId,
    required String content,
    String? parentCommentId,
  });

  Future<Either<Failure, void>> deleteComment(String commentId);

  Future<Either<Failure, List<CommentEntity>>> getCommentsByPostId(String postId);
}
