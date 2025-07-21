import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/features/home/data/data_source/like_datasource.dart';
import 'package:softconnect/features/home/data/model/like_model.dart';

class LikeRemoteDatasource implements ILikeDataSource {
  final ApiService _apiService;

  LikeRemoteDatasource({required ApiService apiService})
      : _apiService = apiService;

  Future<Options> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Auth token not found');
    }
    return Options(
      headers: {'Authorization': 'Bearer $token'},
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    );
  }

  @override
  Future<LikeModel> likePost({
    required String userId,
    required String postId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final username = prefs.getString('username') ?? 'Unknown';
      final options = await _getAuthHeaders();

      print("DEBUG: Sending like for postId: $postId by userId: $userId");

      // Step 1: Like the post
      final response = await _apiService.dio.post(
        ApiEndpoints.likePost,
        data: {
          'userId': userId,
          'postId': postId,
        },
        options: options,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data['data'];
        final postOwnerId = responseData['postOwnerId']?.toString();

        print("DEBUG: Like successful, postOwnerId = $postOwnerId");

        // Step 2: Send notification if not liking own post
        if (postOwnerId != null && postOwnerId != userId) {
          final notificationPayload = {
            "recipient": postOwnerId,
            "type": "like",
            "message": "$username liked your post",
            "relatedId": postId,
          };

          print("DEBUG: Sending notification: $notificationPayload");

          try {
            final notificationResponse = await _apiService.dio.post(
              ApiEndpoints.createNotification,
              data: notificationPayload,
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              ),
            );
            print("DEBUG: Notification created: ${notificationResponse.statusCode}");
          } catch (notificationError) {
            print("ERROR: Failed to send notification");
            if (notificationError is DioException) {
              print("DioError: ${notificationError.response?.data}");
            } else {
              print(notificationError);
            }
          }
        } else {
          print("DEBUG: Skipped notification (self-like or null postOwnerId)");
        }

        return LikeModel.fromJson(responseData);
      } else {
        throw Exception('Failed to like post: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print("DioException: ${e.response?.data}");
      throw Exception('Failed to like post: ${e.message}');
    }
  }

  @override
  Future<void> unlikePost({
    required String userId,
    required String postId,
  }) async {
    try {
      final options = await _getAuthHeaders();

      final response = await _apiService.dio.post(
        ApiEndpoints.unlikePost,
        data: {
          'userId': userId,
          'postId': postId,
        },
        options: options,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unlike post: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to unlike post: ${e.message}');
    }
  }

  @override
  Future<List<LikeModel>> getLikesByPostId(String postId) async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.getPostLikes(postId));

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((e) => LikeModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch likes: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch likes: ${e.message}');
    }
  }
}
