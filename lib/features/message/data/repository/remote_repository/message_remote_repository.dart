import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/features/message/data/data_source/message_datsource.dart';
import 'package:softconnect/features/message/data/model/message_model.dart';
import 'package:softconnect/features/message/domain/entity/message_entity.dart';
import 'package:softconnect/features/message/domain/repository/message_repository.dart';

class MessageRemoteRepository implements IMessageRepository {
  final IMessageDataSource _dataSource;

  MessageRemoteRepository({
    required IMessageDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Either<Failure, List<MessageInboxEntity>>> getInbox(String userId) async {
    try {
      final List<MessageInboxModel> models = await _dataSource.getInboxConversations(userId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }
}

