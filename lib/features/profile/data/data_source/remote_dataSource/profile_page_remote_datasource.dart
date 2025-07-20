import 'package:dio/dio.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/features/auth/data/model/user_api_model.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';
import 'package:softconnect/features/profile/data/data_source/profile_page_datasource.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProfilePageRemoteDataSource implements IProfilePageDataSource {
  final ApiService _apiService;

  ProfilePageRemoteDataSource({required ApiService apiService})
      : _apiService = apiService;

  @override
  Future<UserEntity> updateUserProfile({
    required String userId,
    required String username,
    required String email,
    String? bio,
    String? profilePhoto,
  }) async {
    // Get token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Prepare data body
    final data = {
      'username': username,
      'email': email,
    };

    if (bio != null) data['bio'] = bio;
    if (profilePhoto != null) data['profilePhoto'] = profilePhoto;

    // Set headers, include token if available
    final options = Options(
      headers: {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Content-Type': 'application/json',
      },
    );

    final response = await _apiService.dio.put(
      '/user/$userId',
      data: data,
      options: options,
    );

    // Debug prints to inspect response
    print('Raw response.data: ${response.data}');
    print('Type of response.data: ${response.data.runtimeType}');

    dynamic jsonData;
    try {
      if (response.data is String) {
        jsonData = jsonDecode(response.data);
      } else {
        jsonData = response.data;
      }
    } catch (e) {
      throw Exception('Failed to parse response data: $e');
    }

    print('Parsed jsonData: $jsonData');

    if (response.statusCode == 200 &&
        jsonData is Map<String, dynamic> &&
        jsonData['success'] == true) {
      final userData = jsonData['data'];

      if (userData is Map<String, dynamic>) {
        return UserApiModel.fromJson(userData).toEntity();
      } else {
        throw Exception('Unexpected data format: "data" is not a Map');
      }
    } else {
      throw Exception('Failed to update user profile');
    }
  }
}