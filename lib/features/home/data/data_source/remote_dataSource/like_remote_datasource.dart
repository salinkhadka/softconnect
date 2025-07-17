import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/features/home/data/data_source/like_datasource.dart';
import 'package:softconnect/features/home/data/model/like_model.dart';

class LikeRemoteDatasource implements ILikeDataSource {
  final ApiService _apiService;

  LikeRemoteDatasource({required ApiService apiService}) : _apiService = apiService;

  Future<Options> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Auth token not found');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<LikeModel> likePost({required String userId, required String postId}) async {
    try {
      final options = await _getAuthHeaders();

      final response = await _apiService.dio.post(
        ApiEndpoints.likePost,
        data: {
          'userId': userId,
          'postId': postId,
        },
        options: options,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return LikeModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to like post: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to like post: ${e.message}');
    }
  }

  @override
  Future<void> unlikePost({required String userId, required String postId}) async {
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
