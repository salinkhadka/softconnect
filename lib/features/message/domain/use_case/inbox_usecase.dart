import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/message/domain/entity/message_inbox_entity.dart';
import 'package:softconnect/features/message/domain/repository/message_repository.dart';

class GetInboxParams extends Equatable {
  final String userId;

  const GetInboxParams(this.userId);

  @override
  List<Object?> get props => [userId];
}

class GetInboxUseCase implements UsecaseWithParams<List<MessageInboxEntity>, GetInboxParams> {
  final IMessageRepository repository;

  GetInboxUseCase({required this.repository});

  @override
  Future<Either<Failure, List<MessageInboxEntity>>> call(GetInboxParams params) {
    return repository.getInbox(params.userId);
  }
}
