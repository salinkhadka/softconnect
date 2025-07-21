import 'package:equatable/equatable.dart';
import 'package:softconnect/features/notification/domain/entity/notification_entity.dart';

class NotificationState extends Equatable {
  final bool isLoading;
  final List<NotificationEntity> notifications;
  final String? error;

  const NotificationState({
    this.isLoading = false,
    this.notifications = const [],
    this.error,
  });

  NotificationState copyWith({
    bool? isLoading,
    List<NotificationEntity>? notifications,
    String? error,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, notifications, error];
}
