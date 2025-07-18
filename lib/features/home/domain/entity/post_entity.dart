
import 'package:softconnect/features/home/domain/entity/user_preview_entity.dart';

class PostEntity {
  final String id;
  final UserPreviewEntity user; // lightweight user info for posts
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
