// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationApiModel _$NotificationApiModelFromJson(
        Map<String, dynamic> json) =>
    NotificationApiModel(
      id: json['_id'] as String,
      sender: UserPreviewModel.fromJson(json['sender'] as Map<String, dynamic>),
      recipient: json['recipient'] as String,
      type: json['type'] as String,
      message: json['message'] as String,
      relatedId: json['relatedId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$NotificationApiModelToJson(
        NotificationApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'sender': instance.sender,
      'recipient': instance.recipient,
      'type': instance.type,
      'message': instance.message,
      'relatedId': instance.relatedId,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
