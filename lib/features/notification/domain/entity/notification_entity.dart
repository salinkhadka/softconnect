import 'package:softconnect/features/home/domain/entity/user_preview_entity.dart';

class NotificationEntity {
  final String id;
  final UserPreviewEntity sender;
  final String recipient;
  final String type;
  final String message;
  final String? relatedId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationEntity({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.type,
    required this.message,
    required this.relatedId,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });
}
