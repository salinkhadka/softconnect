import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/features/message/data/data_source/message_datsource.dart';
import 'package:softconnect/features/message/data/model/message_inbox_model.dart';
import 'package:softconnect/features/message/data/model/message_model.dart';
import 'package:softconnect/features/message/domain/entity/message_entity.dart';
import 'package:softconnect/features/message/domain/entity/message_inbox_entity.dart';
import 'package:softconnect/features/message/domain/repository/message_repository.dart';

class MessageRemoteRepository implements IMessageRepository {
  final IMessageDataSource _dataSource;

  MessageRemoteRepository({
    required IMessageDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Either<Failure, List<MessageInboxEntity>>> getInbox(
      String userId) async {
    try {
      final List<MessageInboxModel> models =
          await _dataSource.getInboxConversations(userId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessagesBetweenUsers(
      String senderId, String receiverId) async {
    try {
      final List<MessageModel> messageModels =
          await _dataSource.getMessagesBetweenUsers(senderId, receiverId);
      final entities = messageModels.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(
      String senderId, String recipientId, String content) async {
    try {
      final messageModel =
          await _dataSource.sendMessage(senderId, recipientId, content);
      return Right(messageModel.toEntity());
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    try {
      await _dataSource.deleteMessage(messageId);
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }
}
