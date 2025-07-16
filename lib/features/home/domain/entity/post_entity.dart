import 'package:softconnect/features/auth/domain/entity/user_entity.dart';

class PostEntity {
  final String id;
  final UserEntity user; // or just userId if you prefer
  final String content;
  final String? imageUrl;
  final String privacy;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostEntity({
    required this.id,
    required this.user,
    required this.content,
    this.imageUrl,
    required this.privacy,
    required this.createdAt,
    required this.updatedAt,
  });
}
