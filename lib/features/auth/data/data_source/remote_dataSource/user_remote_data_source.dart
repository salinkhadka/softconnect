import 'package:dio/dio.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/features/auth/data/data_source/user_data_source.dart';
import 'package:softconnect/features/auth/data/model/user_api_model.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';

class UserRemoteDataSource implements IUserDataSource {
  final ApiService _apiService;

  UserRemoteDataSource({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<UserEntity> getCurrentUser(String id) async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.getUserById(id));

      if (response.statusCode == 200) {
        final userData = response.data;
        final userApiModel = UserApiModel.fromJson(userData);
        return userApiModel.toEntity();  // convert to UserEntity
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
  Future<String> loginUser(String username, String password) async {
    try {
      final response = await _apiService.dio.post(
        ApiEndpoints.loginUser,
        data: {"email": username.toString(), "password": password.toString()},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        return token;
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
      final response = await _apiService.dio.post(
        ApiEndpoints.registerUser,
        data: userApiModel.toJson(),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Registration failed: ${response.statusMessage}');
      }
      // If needed, you can handle successful registration logic here
    } on DioException catch (e) {
      throw Exception('Failed to register user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  @override
  Future<String> uploadProfilePicture(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'profilePhoto': await MultipartFile.fromFile(filePath),
      });

      final response = await _apiService.dio.post(
        ApiEndpoints.uploadImg,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200) {
        final fileUrl = response.data['filePath'] ?? '';
        return fileUrl;
      } else {
        throw Exception('Upload failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to upload profile picture: ${e.message}');
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }
}
