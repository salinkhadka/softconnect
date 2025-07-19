import 'package:equatable/equatable.dart';
import 'package:softconnect/features/message/domain/entity/message_entity.dart';

abstract class MessageState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MessageInitialState extends MessageState {}

class MessageLoadingState extends MessageState {}

class MessageLoadedMessagesState extends MessageState {
  final List<MessageEntity> messages;

  MessageLoadedMessagesState(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessageSentState extends MessageState {}

class MessageDeletedState extends MessageState {}

class MessageErrorState extends MessageState {
  final String message;

  MessageErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
