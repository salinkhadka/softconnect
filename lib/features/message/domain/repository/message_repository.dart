import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/message/domain/entity/message_entity.dart';

abstract interface class IMessageRepository {
  Future<Either<Failure, List<MessageInboxEntity>>> getInbox(String userId);
}
