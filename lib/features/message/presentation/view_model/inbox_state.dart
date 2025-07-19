import 'package:equatable/equatable.dart';
import 'package:softconnect/features/message/domain/entity/message_inbox_entity.dart';
// import 'package:softconnect/features/message/domain/entity/message_inbox_entity.dart';

abstract class InboxState extends Equatable {
  const InboxState();

  @override
  List<Object?> get props => [];
}

class MessageInitialState extends InboxState {}

class MessageLoadingState extends InboxState {}

class MessageLoadedState extends InboxState {
  final List<MessageInboxEntity> inboxList;

  const MessageLoadedState(this.inboxList);

  @override
  List<Object?> get props => [inboxList];
}

class MessageErrorState extends InboxState {
  final String message;

  const MessageErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
