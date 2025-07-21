// lib/core/network/hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:softconnect/app/constants/hive_table_constant.dart';

// --- IMPORT ALL HIVE MODELS THAT NEED TO BE REGISTERED ---
import 'package:softconnect/features/auth/data/model/user_hive_model.dart';
import 'package:softconnect/features/home/data/model/post_hive_model.dart';
import 'package:softconnect/features/home/data/model/user_preview_hive_model.dart';
import 'package:softconnect/features/message/data/model/message_inbox_hive_model.dart';


class HiveService {
  Future<void> init() async {
  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);

  Hive.registerAdapter(UserHiveModelAdapter());
  Hive.registerAdapter(PostHiveModelAdapter());
  Hive.registerAdapter(UserPreviewHiveModelAdapter());

  // ✅ Add this:
  Hive.registerAdapter(MessageInboxHiveModelAdapter());
}

  // =================== POST METHODS (NEW) ===================

  /// Gets all posts from the PostBox.
  Future<List<PostHiveModel>> getAllPosts() async {
    final box = await Hive.openBox<PostHiveModel>(HiveTableConstant.postBox);
    return box.values.toList();
  }

  /// Clears the PostBox and adds a new list of posts.
  Future<void> addPosts(List<PostHiveModel> posts) async {
    final box = await Hive.openBox<PostHiveModel>(HiveTableConstant.postBox);
    await box.clear();
    // Hive's putAll is efficient for adding many items. We create a map of {id: object}.
    final Map<String, PostHiveModel> postMap = {for (var p in posts) p.id: p};
    await box.putAll(postMap);
  }

  // =================== EXISTING USER METHODS ===================

  // Register (add user)
  Future<void> register(UserHiveModel user) async {
    var box = await Hive.openBox<UserHiveModel>(HiveTableConstant.userBox);
    await box.put(user.userId, user);
  }

  // Delete user by ID
  Future<void> deleteUser(String id) async {
    var box = await Hive.openBox<UserHiveModel>(HiveTableConstant.userBox);
    await box.delete(id);
  }

  // Get all users
  Future<List<UserHiveModel>> getAllUsers() async {
    var box = await Hive.openBox<UserHiveModel>(HiveTableConstant.userBox);
    return box.values.toList();
  }

  // Login
  Future<UserHiveModel?> login(String username, String password) async {
    var box = await Hive.openBox<UserHiveModel>(HiveTableConstant.userBox);
    try {
      final user = box.values.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<void> addOrUpdateInbox(MessageInboxHiveModel inbox) async {
  final box = await Hive.openBox<MessageInboxHiveModel>(HiveTableConstant.messageInboxBox);
  await box.put(inbox.id, inbox); // assuming inbox.id is unique
}

// Get all inboxes
Future<List<MessageInboxHiveModel>> getAllInboxes() async {
  final box = await Hive.openBox<MessageInboxHiveModel>(HiveTableConstant.messageInboxBox);
  return box.values.toList();
}

// Delete inbox by id
Future<void> deleteInbox(String id) async {
  final box = await Hive.openBox<MessageInboxHiveModel>(HiveTableConstant.messageInboxBox);
  await box.delete(id);
}

// Get inbox by id
Future<MessageInboxHiveModel?> getInboxById(String id) async {
  final box = await Hive.openBox<MessageInboxHiveModel>(HiveTableConstant.messageInboxBox);
  return box.get(id);
}


  // =================== UTILITY METHODS ===================

  // Clear all boxes and data
  Future<void> clearAll() async {
    await Hive.deleteFromDisk();
    // No need to call deleteBoxFromDisk if using deleteFromDisk
  }

  // Close Hive
  Future<void> close() async {
    await Hive.close();
  }
}