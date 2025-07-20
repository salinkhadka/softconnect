import 'package:softconnect/features/auth/domain/entity/user_entity.dart';

abstract interface class IUserDataSource {
  Future<void> registerUser(UserEntity user);
  Future<Map<String, dynamic>> loginUser(String username, String password);
  Future<String> uploadProfilePicture(String filePath);
  Future<UserEntity> getCurrentUser(String id);
  Future<List<UserEntity>> searchUsers(String query);

  // 👇 Add these methods
  Future<void> requestPasswordReset(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<String> verifyPassword(String userId, String currentPassword);
}
