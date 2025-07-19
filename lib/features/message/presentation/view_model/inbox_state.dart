import 'package:equatable/equatable.dart';
import 'package:softconnect/features/message/domain/entity/message_entity.dart';
// import 'package:softconnect/features/message/domain/entity/message_inbox_entity.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

class MessageInitialState extends MessageState {}

class MessageLoadingState extends MessageState {}

class MessageLoadedState extends MessageState {
  final List<MessageInboxEntity> inboxList;

  const MessageLoadedState(this.inboxList);

  @override
  List<Object?> get props => [inboxList];
}

class MessageErrorState extends MessageState {
  final String message;

  const MessageErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
