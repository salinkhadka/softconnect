import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/message/domain/entity/message_entity.dart';
import 'package:softconnect/features/message/domain/entity/message_inbox_entity.dart';

abstract interface class IMessageRepository {
  Future<Either<Failure, List<MessageInboxEntity>>> getInbox(String userId);

  Future<Either<Failure, List<MessageEntity>>> getMessagesBetweenUsers(String user1Id, String user2Id);

  Future<Either<Failure, MessageEntity>> sendMessage(String senderId, String recipientId, String content);
  
  Future<Either<Failure, void>> deleteMessage(String messageId);
}
