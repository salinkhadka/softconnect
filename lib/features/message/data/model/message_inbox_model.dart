import 'package:json_annotation/json_annotation.dart';
import 'package:softconnect/features/message/domain/entity/message_inbox_entity.dart';
// import 'package:softconnect/features/message/domain/entity/MessageInboxEntity.dart';


part 'message_inbox_model.g.dart';

@JsonSerializable()
class MessageInboxModel {
  @JsonKey(name: '_id')
  final String id;
  final String username;
  final String email;
  final String? profilePhoto;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool lastMessageIsRead;
  final String lastMessageSenderId;

  MessageInboxModel({
    required this.id,
    required this.username,
    required this.email,
    this.profilePhoto,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageIsRead,
    required this.lastMessageSenderId,
  });

  factory MessageInboxModel.fromJson(Map<String, dynamic> json) =>
      _$MessageInboxModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageInboxModelToJson(this);

  MessageInboxEntity toEntity() => MessageInboxEntity(
        id: id,
        username: username,
        email: email,
        profilePhoto: profilePhoto,
        lastMessage: lastMessage,
        lastMessageTime: lastMessageTime,
        lastMessageIsRead: lastMessageIsRead,
        lastMessageSenderId: lastMessageSenderId,
      );
}
