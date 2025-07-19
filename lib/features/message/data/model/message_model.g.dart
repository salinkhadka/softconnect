// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageInboxModel _$MessageInboxModelFromJson(Map<String, dynamic> json) =>
    MessageInboxModel(
      id: json['_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      profilePhoto: json['profilePhoto'] as String?,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      lastMessageIsRead: json['lastMessageIsRead'] as bool,
      lastMessageSenderId: json['lastMessageSenderId'] as String,
    );

Map<String, dynamic> _$MessageInboxModelToJson(MessageInboxModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'profilePhoto': instance.profilePhoto,
      'lastMessage': instance.lastMessage,
      'lastMessageTime': instance.lastMessageTime.toIso8601String(),
      'lastMessageIsRead': instance.lastMessageIsRead,
      'lastMessageSenderId': instance.lastMessageSenderId,
    };
