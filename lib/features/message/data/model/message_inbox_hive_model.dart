// message_inbox_hive_model.dart
import 'package:hive/hive.dart';
import 'package:softconnect/app/constants/hive_table_constant.dart';
import 'package:softconnect/features/message/data/model/message_inbox_model.dart';
import 'package:softconnect/features/message/domain/entity/message_inbox_entity.dart';

part 'message_inbox_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.messageInboxTypeId)
class MessageInboxHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? profilePhoto;

  @HiveField(4)
  String lastMessage;

  @HiveField(5)
  DateTime lastMessageTime;

  @HiveField(6)
  bool lastMessageIsRead;

  @HiveField(7)
  String lastMessageSenderId;

  MessageInboxHiveModel({
    required this.id,
    required this.username,
    required this.email,
    this.profilePhoto,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageIsRead,
    required this.lastMessageSenderId,
  });

  /// ✅ Convert from MessageInboxModel to HiveModel
  factory MessageInboxHiveModel.fromModel(MessageInboxModel model) {
    return MessageInboxHiveModel(
      id: model.id,
      username: model.username,
      email: model.email,
      profilePhoto: model.profilePhoto,
      lastMessage: model.lastMessage,
      lastMessageTime: model.lastMessageTime,
      lastMessageIsRead: model.lastMessageIsRead,
      lastMessageSenderId: model.lastMessageSenderId,
    );
  }

  /// ✅ Convert HiveModel back to MessageInboxModel
  MessageInboxModel toModel() {
    return MessageInboxModel(
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
  MessageInboxEntity toEntity() {
  return MessageInboxEntity(
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

}
