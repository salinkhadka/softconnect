import 'package:dartz/dartz.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/home/domain/entity/user_preview_entity.dart';
import 'package:softconnect/features/notification/domain/entity/notification_entity.dart';
import 'package:softconnect/features/notification/domain/repository/notification_repository.dart';

/// Params class for getting notifications by userId
class GetNotificationsByUserIdParams {
  final String userId;
  GetNotificationsByUserIdParams(this.userId);
}

/// UseCase: Get all notifications for a user
class GetNotificationsByUserIdUsecase
    implements UsecaseWithParams<List<NotificationEntity>, GetNotificationsByUserIdParams> {
  final INotificationRepository _notificationRepository;

  GetNotificationsByUserIdUsecase({required INotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository;

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(GetNotificationsByUserIdParams params) async {
    return await _notificationRepository.getUserNotifications(params.userId);
  }
}

/// Params class for creating a notification
class CreateNotificationParams {
  final String recipient;
  final String type;
  final String message;
  final String? relatedId;

  CreateNotificationParams({
    required this.recipient,
    required this.type,
    required this.message,
    this.relatedId,
  });
}

/// UseCase: Create a notification
class CreateNotificationUsecase implements UsecaseWithParams<NotificationEntity, CreateNotificationParams> {
  final INotificationRepository _notificationRepository;

  CreateNotificationUsecase({required INotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository;

  @override
  Future<Either<Failure, NotificationEntity>> call(CreateNotificationParams params) async {
    // Notice: We DO NOT pass `sender` because backend assigns it from auth
    final notificationToCreate = NotificationEntity(
      id: '', // backend generates
      sender: UserPreviewEntity(userId: '', username: '', profilePhoto: null), // dummy placeholder, not sent
      recipient: params.recipient,
      type: params.type,
      message: params.message,
      relatedId: params.relatedId,
      isRead: false,
      createdAt: DateTime.now(), // placeholder, backend overwrites
      updatedAt: DateTime.now(),
    );

    return await _notificationRepository.createNotification(notificationToCreate);
  }
}

/// Params class for marking notification as read
class MarkNotificationAsReadParams {
  final String notificationId;
  MarkNotificationAsReadParams(this.notificationId);
}

/// UseCase: Mark notification as read
class MarkNotificationAsReadUsecase implements UsecaseWithParams<void, MarkNotificationAsReadParams> {
  final INotificationRepository _notificationRepository;

  MarkNotificationAsReadUsecase({required INotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository;

  @override
  Future<Either<Failure, void>> call(MarkNotificationAsReadParams params) async {
    return await _notificationRepository.markNotificationAsRead(params.notificationId);
  }
}

/// Params class for deleting notification
class DeleteNotificationParams {
  final String notificationId;
  DeleteNotificationParams(this.notificationId);
}

/// UseCase: Delete a notification
class DeleteNotificationUsecase implements UsecaseWithParams<void, DeleteNotificationParams> {
  final INotificationRepository _notificationRepository;

  DeleteNotificationUsecase({required INotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository;

  @override
  Future<Either<Failure, void>> call(DeleteNotificationParams params) async {
    return await _notificationRepository.deleteNotification(params.notificationId);
  }
}
