import 'package:softconnect/features/message/data/model/message_model.dart';

abstract interface class IMessageDataSource {
  Future<List<MessageInboxModel>> getInboxConversations(String userId);
}
