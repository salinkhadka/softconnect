import 'package:equatable/equatable.dart';

abstract class MessageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMessagesEvent extends MessageEvent {
  final String senderId;
  final String receiverId;

  LoadMessagesEvent(this.senderId, this.receiverId);

  @override
  List<Object?> get props => [senderId, receiverId];
}

class SendMessageEvent extends MessageEvent {
  final String senderId;
  final String recipientId;
  final String content;

  SendMessageEvent({
    required this.senderId,
    required this.recipientId,
    required this.content,
  });

  @override
  List<Object?> get props => [senderId, recipientId, content];
}

class DeleteMessageEvent extends MessageEvent {
  final String messageId;

  DeleteMessageEvent({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}
