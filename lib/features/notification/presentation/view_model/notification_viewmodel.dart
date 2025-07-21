import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/notification/domain/entity/notification_entity.dart';
import 'package:softconnect/features/notification/domain/use_case/notification_usecases.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  NotificationLoaded(this.notifications);
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

class NotificationViewModel extends Cubit<NotificationState> {
  final GetNotificationsByUserIdUsecase _getNotificationsUsecase;
  final MarkNotificationAsReadUsecase _markAsReadUsecase;
  final DeleteNotificationUsecase _deleteNotificationUsecase;

  NotificationViewModel({
    required GetNotificationsByUserIdUsecase getNotificationsUsecase,
    required MarkNotificationAsReadUsecase markAsReadUsecase,
    required DeleteNotificationUsecase deleteNotificationUsecase,
  })  : _getNotificationsUsecase = getNotificationsUsecase,
        _markAsReadUsecase = markAsReadUsecase,
        _deleteNotificationUsecase = deleteNotificationUsecase,
        super(NotificationInitial());

  Future<void> loadNotifications(String userId) async {
    emit(NotificationLoading());
    final result = await _getNotificationsUsecase.call(GetNotificationsByUserIdParams(userId));
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) => emit(NotificationLoaded(notifications)),
    );
  }

  Future<void> markNotificationRead(String notificationId, String userId) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      // Optimistic update of UI: mark notification as read locally
      final updatedNotifications = currentState.notifications.map((n) {
        if (n.id == notificationId) {
          return NotificationEntity(
            id: n.id,
            sender: n.sender,
            recipient: n.recipient,
            type: n.type,
            message: n.message,
            relatedId: n.relatedId,
            isRead: true,
            createdAt: n.createdAt,
            updatedAt: DateTime.now(), // add updatedAt here for consistency
          );
        }
        return n;
      }).toList();

      emit(NotificationLoaded(updatedNotifications));

      // Call backend to mark as read
      final result = await _markAsReadUsecase.call(MarkNotificationAsReadParams(notificationId));
      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (_) => loadNotifications(userId), // reload notifications fresh from backend
      );
    }
  }

  Future<void> deleteNotification(String notificationId, String userId) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      // Optimistically remove notification from UI
      final updatedNotifications = currentState.notifications.where((n) => n.id != notificationId).toList();
      emit(NotificationLoaded(updatedNotifications));

      // Call backend to delete
      final result = await _deleteNotificationUsecase.call(DeleteNotificationParams(notificationId));
      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (_) => loadNotifications(userId), // reload notifications fresh from backend
      );
    }
  }
}
