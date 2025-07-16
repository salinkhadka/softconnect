import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/features/friends/data/data_source/friends_data_source.dart';
import 'package:softconnect/features/friends/data/model/follow_model.dart';
import 'package:softconnect/features/friends/data/model/follow_response.dart';

class FriendsApiDatasource implements IFriendsDataSource {
  final ApiService _apiService;

  FriendsApiDatasource({required ApiService apiService})
      : _apiService = apiService;


  @override
Future<FollowModel> followUser(String followeeId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await _apiService.dio.post(
      ApiEndpoints.followUser,
      data: {"followeeId": followeeId},
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    final followResponse = FollowResponse.fromJson(response.data);
    if (followResponse.success && followResponse.data != null) {
      return followResponse.data!;
    } else {
      throw Exception("Follow failed: ${followResponse.message}");
    }
  } catch (e) {
    throw Exception("Follow error: $e");
  }
}


  @override
  Future<void> unfollowUser(String followeeId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await _apiService.dio.post(
      ApiEndpoints.unfollowUser,
      data: {"followeeId": followeeId},
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    if (response.statusCode != 200 || response.data["success"] != true) {
      throw Exception("Unfollow failed: ${response.data["message"] ?? response.statusMessage}");
    }
  } catch (e) {
    throw Exception("Unfollow error: $e");
  }
}


  @override
  Future<List<FollowModel>> getFollowers(String userId) async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.getFollowers(userId));
      final data = response.data['data'] as List;
      return data.map((e) => FollowModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Get followers error: $e");
    }
  }

  @override
  Future<List<FollowModel>> getFollowing(String userId) async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.getFollowing(userId));
      final data = response.data['data'] as List;
      return data.map((e) => FollowModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Get following error: $e");
    }
  }
}
