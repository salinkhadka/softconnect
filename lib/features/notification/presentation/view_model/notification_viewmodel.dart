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

class NotificationProcessing extends NotificationState {
  final List<NotificationEntity> notifications;
  final String processingId;
  final String action; // 'read' or 'delete'
  
  NotificationProcessing(this.notifications, this.processingId, this.action);
}

class NotificationViewModel extends Cubit<NotificationState> {
  final GetNotificationsByUserIdUsecase _getNotificationsUsecase;
  final MarkNotificationAsReadUsecase _markAsReadUsecase;
  final DeleteNotificationUsecase _deleteNotificationUsecase;

  List<NotificationEntity> _cachedNotifications = [];
  String? _currentUserId;

  NotificationViewModel({
    required GetNotificationsByUserIdUsecase getNotificationsUsecase,
    required MarkNotificationAsReadUsecase markAsReadUsecase,
    required DeleteNotificationUsecase deleteNotificationUsecase,
  })  : _getNotificationsUsecase = getNotificationsUsecase,
        _markAsReadUsecase = markAsReadUsecase,
        _deleteNotificationUsecase = deleteNotificationUsecase,
        super(NotificationInitial());

  Future<void> loadNotifications(String userId, {bool showLoader = true}) async {
    _currentUserId = userId;
    
    if (showLoader) {
      emit(NotificationLoading());
    }
    
    try {
      final result = await _getNotificationsUsecase.call(GetNotificationsByUserIdParams(userId));
      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (notifications) {
          _cachedNotifications = List.from(notifications);
          emit(NotificationLoaded(notifications));
        },
      );
    } catch (e) {
      emit(NotificationError('Failed to load notifications: ${e.toString()}'));
    }
  }

  Future<void> markNotificationRead(String notificationId, String userId) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    // Optimistic update: immediately mark as read in UI
    final optimisticNotifications = _cachedNotifications.map((notification) {
      if (notification.id == notificationId) {
        return NotificationEntity(
          id: notification.id,
          sender: notification.sender,
          recipient: notification.recipient,
          type: notification.type,
          message: notification.message,
          relatedId: notification.relatedId,
          isRead: true, // Optimistically mark as read
          createdAt: notification.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      return notification;
    }).toList();

    // Update cache and emit optimistic state
    _cachedNotifications = optimisticNotifications;
    emit(NotificationLoaded(optimisticNotifications));

    try {
      // Make API call in background
      final result = await _markAsReadUsecase.call(MarkNotificationAsReadParams(notificationId));
      
      await result.fold(
        (failure) async {
          // If API call fails, revert optimistic update
          await _revertOptimisticUpdate(notificationId, false);
          emit(NotificationError('Failed to mark notification as read: ${failure.message}'));
        },
        (_) async {
          // Success - refresh from server to ensure consistency
          await loadNotifications(userId, showLoader: false);
        },
      );
    } catch (e) {
      // If error occurs, revert optimistic update
      await _revertOptimisticUpdate(notificationId, false);
      emit(NotificationError('Network error: ${e.toString()}'));
    }
  }

  Future<void> deleteNotification(String notificationId, String userId) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    // Store the notification in case we need to revert
    final notificationToDelete = _cachedNotifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => throw Exception('Notification not found'),
    );

    // Optimistic update: immediately remove from UI
    final optimisticNotifications = _cachedNotifications
        .where((notification) => notification.id != notificationId)
        .toList();

    // Update cache and emit optimistic state
    _cachedNotifications = optimisticNotifications;
    emit(NotificationLoaded(optimisticNotifications));

    try {
      // Make API call in background
      final result = await _deleteNotificationUsecase.call(DeleteNotificationParams(notificationId));
      
      await result.fold(
        (failure) async {
          // If API call fails, revert optimistic update
          await _revertOptimisticDelete(notificationToDelete, userId);
          emit(NotificationError('Failed to delete notification: ${failure.message}'));
        },
        (_) async {
          // Success - refresh from server to ensure consistency
          await loadNotifications(userId, showLoader: false);
        },
      );
    } catch (e) {
      // If error occurs, revert optimistic update by adding back the deleted notification
      await _revertOptimisticDelete(notificationToDelete, userId);
      emit(NotificationError('Network error: ${e.toString()}'));
    }
  }

  Future<void> _revertOptimisticUpdate(String notificationId, bool originalReadStatus) async {
    // Revert the read status to original
    final revertedNotifications = _cachedNotifications.map((notification) {
      if (notification.id == notificationId) {
        return NotificationEntity(
          id: notification.id,
          sender: notification.sender,
          recipient: notification.recipient,
          type: notification.type,
          message: notification.message,
          relatedId: notification.relatedId,
          isRead: originalReadStatus, // Revert to original status
          createdAt: notification.createdAt,
          updatedAt: notification.updatedAt,
        );
      }
      return notification;
    }).toList();

    _cachedNotifications = revertedNotifications;
    emit(NotificationLoaded(revertedNotifications));
  }

  Future<void> _revertOptimisticDelete(NotificationEntity deletedNotification, String userId) async {
    // Add back the deleted notification to its original position
    final revertedNotifications = List<NotificationEntity>.from(_cachedNotifications);
    
    // Find the correct position to insert based on creation date
    int insertIndex = 0;
    for (int i = 0; i < revertedNotifications.length; i++) {
      if (revertedNotifications[i].createdAt.isBefore(deletedNotification.createdAt)) {
        insertIndex = i;
        break;
      }
      insertIndex = i + 1;
    }
    
    revertedNotifications.insert(insertIndex, deletedNotification);
    _cachedNotifications = revertedNotifications;
    emit(NotificationLoaded(revertedNotifications));
  }

  // Batch operations for better performance
  Future<void> markAllAsRead(String userId) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    // Optimistic update: mark all as read
    final optimisticNotifications = _cachedNotifications.map((notification) {
      if (!notification.isRead) {
        return NotificationEntity(
          id: notification.id,
          sender: notification.sender,
          recipient: notification.recipient,
          type: notification.type,
          message: notification.message,
          relatedId: notification.relatedId,
          isRead: true,
          createdAt: notification.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      return notification;
    }).toList();

    _cachedNotifications = optimisticNotifications;
    emit(NotificationLoaded(optimisticNotifications));

    try {
      // If you have a batch mark all as read API, use it here
      // For now, we'll refresh from server
      await loadNotifications(userId, showLoader: false);
    } catch (e) {
      emit(NotificationError('Failed to mark all notifications as read: ${e.toString()}'));
    }
  }

  Future<void> deleteAllRead(String userId) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    // Store read notifications in case we need to revert
    final readNotifications = _cachedNotifications.where((n) => n.isRead).toList();
    
    // Optimistic update: remove all read notifications
    final optimisticNotifications = _cachedNotifications.where((n) => !n.isRead).toList();

    _cachedNotifications = optimisticNotifications;
    emit(NotificationLoaded(optimisticNotifications));

    try {
      // If you have a batch delete API, use it here
      // For now, we'll refresh from server
      await loadNotifications(userId, showLoader: false);
    } catch (e) {
      // Revert by adding back all read notifications
      _cachedNotifications = [..._cachedNotifications, ...readNotifications]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(NotificationLoaded(_cachedNotifications));
      emit(NotificationError('Failed to delete read notifications: ${e.toString()}'));
    }
  }

  // Utility method to get unread count
  int getUnreadCount() {
    return _cachedNotifications.where((n) => !n.isRead).length;
  }

  // Method to refresh notifications silently (without showing loader)
  Future<void> refreshSilently() async {
    if (_currentUserId != null) {
      await loadNotifications(_currentUserId!, showLoader: false);
    }
  }
}
