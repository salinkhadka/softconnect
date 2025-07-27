import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/features/home/data/data_source/comment_datasource.dart';
import 'package:softconnect/features/home/data/model/comment_model.dart';

class CommentRemoteDatasource implements ICommentDataSource {
  final ApiService _apiService;

  CommentRemoteDatasource({required ApiService apiService})
      : _apiService = apiService;

  Future<Options> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Auth token not found');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
Future<CommentModel> createComment({
  required String userId,
  required String postId,
  required String content,
  String? parentCommentId,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final username = prefs.getString('username') ?? 'Unknown';
    final options = await _getAuthHeaders();

    final response = await _apiService.dio.post(
      ApiEndpoints.createComment,
      data: {
        "userId": userId,
        "postId": postId,
        "content": content,
        if (parentCommentId != null) "parentCommentId": parentCommentId,
      },
      options: options,
    );

    if (response.statusCode == 201) {
      dynamic dataRaw = response.data['data'];

      if (dataRaw is String) dataRaw = jsonDecode(dataRaw);

      if (dataRaw is Map<String, dynamic>) {
        // Transform data
        if (dataRaw['userId'] is String) {
          dataRaw['userId'] = {
            '_id': dataRaw['userId'],
            'username': 'Unknown',
            'profilePhoto': null,
          };
        }

        final postOwnerId = dataRaw['postOwnerId']?.toString();

        // 🔔 Create notification (if not commenting on own post)
        if (postOwnerId != null && postOwnerId != userId) {
          final notificationPayload = {
            "recipient": postOwnerId,
            "type": "comment",
            "message": "$username commented on your post",
            "relatedId": postId,
          };

          try {
            final notificationResponse = await _apiService.dio.post(
              ApiEndpoints.createNotification,
              data: notificationPayload,
              options: Options(headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              }),
            );

            print("DEBUG: Notification created: ${notificationResponse.statusCode}");
          } catch (notificationError) {
            print("ERROR: Failed to send comment notification");
            if (notificationError is DioException) {
              print("DioError: ${notificationError.response?.data}");
            } else {
              print(notificationError);
            }
          }
        }

        return CommentModel.fromJson(dataRaw);
      } else {
        throw Exception('Unexpected response format in "data".');
      }
    } else {
      throw Exception("Failed to create comment: ${response.statusMessage}");
    }
  } on DioException catch (e) {
    throw Exception("Failed to create comment: ${e.message}");
  }
}


  @override
  Future<List<CommentModel>> getCommentsByPostId(String postId) async {
    try {
      final options = await _getAuthHeaders();

      final response = await _apiService.dio.get(
        ApiEndpoints.getCommentsByPost(postId),
        options: options,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data['data'];
        return jsonList.map((json) => CommentModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch comments: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception("Failed to fetch comments: ${e.message}");
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      final options = await _getAuthHeaders();

      final response = await _apiService.dio.delete(
        ApiEndpoints.deleteComment(commentId),
        options: options,
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to delete comment: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception("Failed to delete comment: ${e.message}");
    }
  }
}
