import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/notification/data/data_source/notification_data_source.dart';

import 'package:softconnect/features/notification/domain/entity/notification_entity.dart';
import 'package:softconnect/features/notification/domain/repository/notification_repository.dart';

class NotificationRemoteRepository implements INotificationRepository {
  final INotificationDataSource _dataSource;

  NotificationRemoteRepository({required INotificationDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getUserNotifications(String userId) async {
    try {
      final notifications = await _dataSource.getNotifications(userId);
      // notifications already List<NotificationEntity>
      return Right(notifications);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationAsRead(String notificationId) async {
    try {
      await _dataSource.markAsRead(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    try {
      await _dataSource.deleteNotification(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> createNotification(NotificationEntity notification) async {
    try {
      final createdNotification = await _dataSource.createNotification(
        recipient: notification.recipient,
        type: notification.type,
        message: notification.message,
        relatedId: notification.relatedId,
      );
      return Right(createdNotification);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }
}
