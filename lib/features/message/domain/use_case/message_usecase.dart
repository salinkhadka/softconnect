import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/message/domain/entity/message_entity.dart';
import 'package:softconnect/features/message/domain/repository/message_repository.dart';

/// Params and UseCase to get messages between two users
class GetMessagesParams extends Equatable {
  final String user1Id;
  final String user2Id;

  const GetMessagesParams(this.user1Id, this.user2Id);

  @override
  List<Object?> get props => [user1Id, user2Id];
}

class GetMessagesBetweenUsersUseCase implements UsecaseWithParams<List<MessageEntity>, GetMessagesParams> {
  final IMessageRepository repository;

  GetMessagesBetweenUsersUseCase({required this.repository});

  @override
  Future<Either<Failure, List<MessageEntity>>> call(GetMessagesParams params) {
    return repository.getMessagesBetweenUsers(params.user1Id, params.user2Id);
  }
}

/// Params and UseCase to send a message
class SendMessageParams extends Equatable {
  final String senderId;
  final String recipientId;
  final String content;
  

  const SendMessageParams(this.recipientId, this.content, this.senderId);

  @override
  List<Object?> get props => [recipientId, content,senderId];
}

class SendMessageUseCase implements UsecaseWithParams<MessageEntity, SendMessageParams> {
  final IMessageRepository repository;

  SendMessageUseCase({required this.repository});

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) {
    return repository.sendMessage(params.senderId,params.recipientId, params.content);
  }
}

/// Params and UseCase to delete a message
class DeleteMessageParams extends Equatable {
  final String messageId;

  const DeleteMessageParams(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class DeleteMessageUseCase implements UsecaseWithParams<void, DeleteMessageParams> {
  final IMessageRepository repository;

  DeleteMessageUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeleteMessageParams params) {
    return repository.deleteMessage(params.messageId);
  }
}
