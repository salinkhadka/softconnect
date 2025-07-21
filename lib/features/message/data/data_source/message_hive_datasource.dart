// lib/features/message/data/data_source/message_local_datasource.dart

import 'package:softconnect/features/message/data/model/message_inbox_hive_model.dart';

/// The interface defining operations for the local message inbox cache.
abstract interface class IMessageLocalDataSource {
  /// Retrieves the cached list of [MessageInboxHiveModel] from local storage.
  /// Throws an exception if there's a fatal error reading the cache.
  Future<List<MessageInboxHiveModel>> getLastInboxMessages();

  /// Deletes all existing inbox entries and saves a new list to the cache.
  Future<void> cacheInboxMessages(List<MessageInboxHiveModel> messagesToCache);
}
