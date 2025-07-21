import 'package:softconnect/core/network/hive_service.dart';
import 'package:softconnect/features/message/data/data_source/message_hive_datasource.dart';
import 'package:softconnect/features/message/data/model/message_inbox_hive_model.dart';

class MessageHiveDatasourceImpl implements IMessageLocalDataSource {
  final HiveService _hiveService;

  MessageHiveDatasourceImpl({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<void> cacheInboxMessages(List<MessageInboxHiveModel> messagesToCache) async {
    try {
      // Clear previous cache and add all new messages
      // Since HiveService does not have a bulk method, let's add each individually or add a batch method
      
      // Option 1: Clear inbox box manually then add messages one by one:
      final inboxes = await _hiveService.getAllInboxes();
      for (var inbox in inboxes) {
        await _hiveService.deleteInbox(inbox.id);
      }

      for (var message in messagesToCache) {
        await _hiveService.addOrUpdateInbox(message);
      }

      // Alternatively, implement a bulk method in HiveService if needed

    } catch (e) {
      throw Exception('Failed to cache inbox messages: $e');
    }
  }

  @override
  Future<List<MessageInboxHiveModel>> getLastInboxMessages() async {
    try {
      final messages = await _hiveService.getAllInboxes();
      return messages;
    } catch (e) {
      throw Exception('Failed to fetch cached inbox messages: $e');
    }
  }
}
