import 'package:json_annotation/json_annotation.dart';
import 'package:softconnect/features/message/domain/entity/message_entity.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  @JsonKey(name: '_id')
  final String id;
  final String sender;
  final String recipient;
  final String content;
  final bool isRead;
  final String conversationId;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.content,
    required this.isRead,
    required this.conversationId,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  /// Converts this model to the domain entity
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      sender: sender,
      recipient: recipient,
      content: content,
      isRead: isRead,
      conversationId: conversationId,
      createdAt: createdAt,
    );
  }

  /// Creates this model from a domain entity
  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      sender: entity.sender,
      recipient: entity.recipient,
      content: entity.content,
      isRead: entity.isRead,
      conversationId: entity.conversationId,
      createdAt: entity.createdAt,
    );
  }
}
