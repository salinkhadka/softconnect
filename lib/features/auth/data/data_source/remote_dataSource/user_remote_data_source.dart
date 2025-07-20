import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/features/auth/data/data_source/user_data_source.dart';
import 'package:softconnect/features/auth/data/model/user_api_model.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';

class UserRemoteDataSource implements IUserDataSource {
  final ApiService _apiService;

  UserRemoteDataSource({required ApiService apiService})
      : _apiService = apiService;

  @override
  Future<UserEntity> getCurrentUser(String id) async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.getUserById(id));

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true &&
            responseData['data'] != null) {
          final userData = responseData['data'] as Map<String, dynamic>;
          final userApiModel = UserApiModel.fromJson(userData);
          return userApiModel.toEntity();
        } else {
          throw Exception(
              "Invalid response structure or unsuccessful response");
        }
      } else {
        throw Exception("Failed to fetch user: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception('Failed to get current user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    try {
      final response = await _apiService.dio.post(
        ApiEndpoints.loginUser,
        data: {"email": username.toString(), "password": password.toString()},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final userData = response.data['data'];
        final userApiModel = UserApiModel.fromJson(userData);
        final userEntity = userApiModel.toEntity();

        return {
          'token': token,
          'user': userEntity,
        };
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      throw Exception('Failed to login user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to login user: $e');
    }
  }

  @override
  Future<void> registerUser(UserEntity user) async {
    try {
      final userApiModel = UserApiModel.fromEntity(user);
      final data = userApiModel.toJson();

      if (user.profilePhoto != null && user.profilePhoto!.isNotEmpty) {
        data['profilePhoto'] = user.profilePhoto;
      }

      final response = await _apiService.dio.post(
        ApiEndpoints.registerUser,
        data: data,
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Registration failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to register user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  @override
  Future<String> uploadProfilePicture(String filePath) async {
    try {
      final mimeType = lookupMimeType(filePath);
      final fileName = filePath.split('/').last;

      final formData = FormData.fromMap({
        'profilePhoto': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      });

      final response = await _apiService.dio.post(
        ApiEndpoints.uploadImg,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200) {
        final filename = response.data['data'];
        return filename;
      } else {
        throw Exception('Upload failed: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // New method added for user search
  @override
  Future<List<UserEntity>> searchUsers(String query) async {
    try {
      final response = await _apiService.dio.get(
        ApiEndpoints.getAllUsers,
        queryParameters: {'search': query},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true) {
          final List usersJson = responseData['data'] ?? [];
          return usersJson
              .map((json) => UserApiModel.fromJson(json).toEntity())
              .toList();
        } else {
          throw Exception('Invalid response for user search');
        }
      } else {
        throw Exception('Failed to search users: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Search users failed: ${e.message}');
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await _apiService.dio.post(
        ApiEndpoints.requestReset,
        data: {"email": email},
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Password reset request failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Request reset failed: ${e.message}');
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await _apiService.dio.post(
        ApiEndpoints.resetPassword(token), // call function properly
        data: {"password": newPassword},
      );

      if (response.statusCode != 200) {
        throw Exception('Password reset failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Reset password failed: ${e.message}');
    }
  }

  @override
  Future<String> verifyPassword(String userId, String currentPassword) async {
    try {
      final response = await _apiService.dio.post(
        ApiEndpoints.verifyPassword,
        data: {"userId": userId, "currentPassword": currentPassword},
      );

      final data = response.data;
      if (data['success'] == true && data['token'] != null) {
        return data['token'];
      } else {
        throw Exception(data['message'] ?? "Password verification failed");
      }
    } on DioException catch (e) {
      throw Exception('Verify password failed: ${e.message}');
    }
  }
}
