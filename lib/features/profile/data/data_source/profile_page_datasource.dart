import 'package:softconnect/features/auth/domain/entity/user_entity.dart';

abstract class IProfilePageDataSource {
  Future<UserEntity> updateUserProfile({
    required String userId,
    required String username,
    required String email,
    String? bio,
    String? profilePhoto,
  });
}
