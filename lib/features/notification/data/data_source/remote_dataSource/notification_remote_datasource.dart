import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/features/notification/data/data_source/notification_data_source.dart';
import 'package:softconnect/features/notification/data/model/notification_api_model.dart';
import 'package:softconnect/features/notification/domain/entity/notification_entity.dart';

class NotificationRemoteDataSource implements INotificationDataSource {
  final ApiService _apiService;

  NotificationRemoteDataSource({required ApiService apiService})
      : _apiService = apiService;

  // Get auth headers with token
  Future<Options> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('Auth token not found');

    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  @override
  Future<NotificationEntity> createNotification({
    required String recipient,
    required String type,
    required String message,
    String? relatedId,
  }) async {
    final options = await _getAuthHeaders();

    final response = await _apiService.dio.post(
      'notifications/',
      data: {
        'recipient': recipient,
        'type': type,
        'message': message,
        if (relatedId != null) 'relatedId': relatedId,
      },
      options: options,
    );

    if (response.statusCode == 201 && response.data['success'] == true) {
      final jsonData = response.data['data'] as Map<String, dynamic>;
      final model = NotificationApiModel.fromJson(jsonData);
      return model.toEntity();
    } else {
      throw Exception('Failed to create notification');
    }
  }

  @override
  Future<List<NotificationEntity>> getNotifications(String userId) async {
    final options = await _getAuthHeaders();

    final response = await _apiService.dio.get(
      'notifications/$userId',
      options: options,
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> list = response.data['data'];
      return list
          .map((json) => NotificationApiModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final options = await _getAuthHeaders();

    final response = await _apiService.dio.put(
      'notifications/read/$notificationId',
      options: options,
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception('Failed to mark notification as read');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final options = await _getAuthHeaders();

    final response = await _apiService.dio.delete(
      'notifications/$notificationId',
      options: options,
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception('Failed to delete notification');
    }
  }
}
