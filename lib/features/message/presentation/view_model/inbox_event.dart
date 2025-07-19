import 'package:equatable/equatable.dart';
import 'package:softconnect/features/message/domain/use_case/inbox_usecase.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

class LoadInboxEvent extends MessageEvent {
  final GetInboxParams params;

  const LoadInboxEvent(this.params);

  @override
  List<Object?> get props => [params];
}
