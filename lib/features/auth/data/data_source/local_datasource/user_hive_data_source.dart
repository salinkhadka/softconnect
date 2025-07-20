import 'package:softconnect/core/network/hive_service.dart';
import 'package:softconnect/features/auth/data/data_source/user_data_source.dart';
import 'package:softconnect/features/auth/data/model/user_hive_model.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';

class UserHiveDataSource implements IUserDataSource {
  final HiveService _hiveService;

  UserHiveDataSource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    try {
      final userData = await _hiveService.login(username, password);
      if (userData != null && userData.password == password) {
        // Simulate a token for local login, or generate one if needed
        final token = "local_dummy_token";

        return {
          'token': token,
          'user': userData.toEntity(),
        };
      } else {
        throw Exception("Invalid username or password");
      }
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  @override
  Future<void> registerUser(UserEntity user) async {
    try {
      final userHiveModel = UserHiveModel.fromEntity(user);
      await _hiveService.register(userHiveModel);
    } catch (e) {
      throw Exception("Registration failed: $e");
    }
  }

  @override
  Future<String> uploadProfilePicture(String filePath) {
    // You can add actual file upload logic if needed
    throw UnimplementedError("Upload profile picture not implemented yet");
  }
  
  @override
  Future<UserEntity> getCurrentUser(String id) {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }
  
  @override
  Future<List<UserEntity>> searchUsers(String query) {
    // TODO: implement searchUsers
    throw UnimplementedError();
  }

  // @override
  // Future<UserEntity> getCurrentUser(String id) async {
  //   final users = await _hiveService.getAllUsers();
  //   if (users.isNotEmpty) {
  //     // Optionally, filter by id here
  //     final user = users.firstWhere(
  //       (u) => u.id == id,
  //       orElse: () => throw Exception("User not found with id $id"),
  //     );
  //     return user.toEntity();
  //   } else {
  //     throw Exception("No user found in Hive.");
  //   }
  // }
}
