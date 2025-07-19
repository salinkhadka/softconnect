// lib/features/message/domain/entity/message_entity.dart
import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String sender;
  final String recipient;
  final String content;
  final bool isRead;
  final String conversationId;
  final DateTime createdAt;

  const MessageEntity({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.content,
    required this.isRead,
    required this.conversationId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, sender, recipient, content, isRead, conversationId, createdAt];
}
