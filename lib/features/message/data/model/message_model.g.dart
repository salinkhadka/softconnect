// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
      id: json['_id'] as String,
      sender: json['sender'] as String,
      recipient: json['recipient'] as String,
      content: json['content'] as String,
      isRead: json['isRead'] as bool,
      conversationId: json['conversationId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'sender': instance.sender,
      'recipient': instance.recipient,
      'content': instance.content,
      'isRead': instance.isRead,
      'conversationId': instance.conversationId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
