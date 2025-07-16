import 'package:dartz/dartz.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/home/domain/entity/comment_entity.dart';
import 'package:softconnect/features/home/domain/repository/comment_repository.dart';

// Params class for creating a comment
class CreateCommentParams {
  final String userId;
  final String postId;
  final String content;
  final String? parentCommentId;

  CreateCommentParams({
    required this.userId,
    required this.postId,
    required this.content,
    this.parentCommentId,
  });
}

// Create a comment (with params)
class CreateCommentUsecase implements UsecaseWithParams<CommentEntity, CreateCommentParams> {
  final ICommentRepository _commentRepository;

  CreateCommentUsecase({required ICommentRepository commentRepository}) : _commentRepository = commentRepository;

  @override
  Future<Either<Failure, CommentEntity>> call(CreateCommentParams params) async {
    return await _commentRepository.createComment(
      userId: params.userId,
      postId: params.postId,
      content: params.content,
      parentCommentId: params.parentCommentId,
    );
  }
}

// Params class for getting comments by post
class GetCommentsByPostIdParams {
  final String postId;
  GetCommentsByPostIdParams(this.postId);
}

// Get comments for a post (with params)
class GetCommentsByPostIdUsecase implements UsecaseWithParams<List<CommentEntity>, GetCommentsByPostIdParams> {
  final ICommentRepository _commentRepository;

  GetCommentsByPostIdUsecase({required ICommentRepository commentRepository}) : _commentRepository = commentRepository;

  @override
  Future<Either<Failure, List<CommentEntity>>> call(GetCommentsByPostIdParams params) async {
    return await _commentRepository.getCommentsByPostId(params.postId);
  }
}

// Params class for deleting a comment
class DeleteCommentParams {
  final String commentId;
  DeleteCommentParams(this.commentId);
}

// Delete a comment (with params)
class DeleteCommentUsecase implements UsecaseWithParams<void, DeleteCommentParams> {
  final ICommentRepository _commentRepository;

  DeleteCommentUsecase({required ICommentRepository commentRepository}) : _commentRepository = commentRepository;

  @override
  Future<Either<Failure, void>> call(DeleteCommentParams params) async {
    return await _commentRepository.deleteComment(params.commentId);
  }
}
