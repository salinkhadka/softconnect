import 'package:softconnect/features/message/data/model/message_model.dart';
import 'package:softconnect/features/message/data/model/message_inbox_model.dart';

abstract interface class IMessageDataSource {
  Future<List<MessageInboxModel>> getInboxConversations(String userId);
  Future<List<MessageModel>> getMessagesBetweenUsers(String senderId, String receiverId);
  Future<MessageModel> sendMessage(String senderId, String recipientId, String content);
  Future<void> deleteMessage(String messageId);
}
