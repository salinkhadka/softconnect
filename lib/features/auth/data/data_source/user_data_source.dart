import 'package:softconnect/features/auth/domain/entity/user_entity.dart';

abstract interface class IUserDataSource {
  Future<void> registerUser(UserEntity user);

  Future<Map<String, dynamic>> loginUser(String username, String password);

  Future<String> uploadProfilePicture(String filePath);

  Future<UserEntity> getCurrentUser(String id);
}