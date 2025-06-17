import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:softconnect/app/constants/hive_table_constant.dart';
import 'package:softconnect/features/auth/data/model/user_hive_model.dart';

class HiveService {
  Future<void> init() async {
    // Initialize Hive with custom path
    var directory = await getApplicationDocumentsDirectory();
    var path = '${directory.path}/softconnect.db';
    Hive.init(path);

    // Register Adapter
    Hive.registerAdapter(UserHiveModelAdapter());
  }

  // Register (add user)
  Future<void> register(UserHiveModel user) async {
    var box = await Hive.openBox<UserHiveModel>(HiveTableConstant.UserBox);
    await box.put(user.userId, user);
  }

  // Delete user by ID
  Future<void> deleteUser(String id) async {
    var box = await Hive.openBox<UserHiveModel>(HiveTableConstant.UserBox);
    await box.delete(id);
  }

  // Get all users
  Future<List<UserHiveModel>> getAllUsers() async {
    var box = await Hive.openBox<UserHiveModel>(HiveTableConstant.UserBox);
    return box.values.toList();
  }

  // Login
  Future<UserHiveModel?> login(String username, String password) async {
    var box = await Hive.openBox<UserHiveModel>(HiveTableConstant.UserBox);
    try {
      final user = box.values.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      return user;
    } catch (_) {
      return null;
    }
  }

  // Clear all boxes and data
  Future<void> clearAll() async {
    await Hive.deleteFromDisk();
    await Hive.deleteBoxFromDisk(HiveTableConstant.UserBox);
  }

  // Close Hive
  Future<void> close() async {
    await Hive.close();
  }
}
