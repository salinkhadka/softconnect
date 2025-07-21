import 'package:softconnect/features/notification/domain/entity/notification_entity.dart';

abstract class INotificationDataSource {
  /// Create a new notification and return the created notification entity
  Future<NotificationEntity> createNotification({
    required String recipient,
    required String type,
    required String message,
    String? relatedId,
  });

  /// Get all notifications for a user by userId
  Future<List<NotificationEntity>> getNotifications(String userId);

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId);

  /// Delete a specific notification
  Future<void> deleteNotification(String notificationId);
}
