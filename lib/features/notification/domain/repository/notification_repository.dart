import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/notification/domain/entity/notification_entity.dart';

abstract interface class INotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getUserNotifications(String userId);
  Future<Either<Failure, void>> markNotificationAsRead(String notificationId);
  Future<Either<Failure, void>> deleteNotification(String notificationId);
  Future<Either<Failure, NotificationEntity>> createNotification(NotificationEntity notification);
}
