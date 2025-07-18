import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/features/home/data/data_source/post_datasource.dart';
import 'package:softconnect/features/home/data/model/post_model.dart';

class PostRemoteDatasource implements IPostsDataSource {
  final ApiService _apiService;

  PostRemoteDatasource({required ApiService apiService}) : _apiService = apiService;

  // === AUTH HEADER RETRIEVAL ===
  Future<Options> _getAuthHeaders({Map<String, String>? extraHeaders}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Auth token not found');

    final baseHeaders = {'Authorization': 'Bearer $token'};
    if (extraHeaders != null) {
      baseHeaders.addAll(extraHeaders);
    }

    return Options(headers: baseHeaders);
  }

  // === FETCH ALL POSTS ===
  @override
  Future<List<PostModel>> getAllPosts() async {
    try {
      final options = await _getAuthHeaders();
      final response = await _apiService.dio.get(ApiEndpoints.getAllPosts, options: options);
      final data = response.data['data'];

      if (data is! List) throw Exception("Unexpected format");

      return data.map((e) => PostModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  @override
  Future<List<PostModel>> getPostsByUserId(String userId) async {
    try {
      final options = await _getAuthHeaders();
      final response = await _apiService.dio.get(ApiEndpoints.getUserPosts(userId), options: options);
      final data = response.data['data'] as List;
      return data.map((json) => PostModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user posts: $e');
    }
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    try {
      final options = await _getAuthHeaders();
      final response = await _apiService.dio.get(ApiEndpoints.getPostById(postId), options: options);
      return PostModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch post: $e');
    }
  }

  // === CREATE POST ===
  @override
  Future<PostModel> createPost({
  required String userId,
  required String content,
  required String privacy,
  String? imageUrl,   // change from imagePath to imageUrl (string URL or filename)
}) async {
  try {
    final data = {
      "userId": userId,
      "content": content,
      "privacy": privacy,
      if (imageUrl != null) "imageUrl": imageUrl,
    };

    final options = await _getAuthHeaders();

    final response = await _apiService.dio.post(
      ApiEndpoints.createPost,
      data: data,
      options: options,
    );

    return PostModel.fromJson(response.data['data']);
  } catch (e) {
    throw Exception('Failed to create post: $e');
  }
}


  // === UPDATE POST ===
  @override
  Future<PostModel> updatePost({
    required String postId,
    String? content,
    String? privacy,
    String? imageUrl,
  }) async {
    try {
      final formData = FormData();

      if (content != null) formData.fields.add(MapEntry('content', content));
      if (privacy != null) formData.fields.add(MapEntry('privacy', privacy));
      if (imageUrl != null) {
        formData.files.add(
          MapEntry(
            "imageUrl",
            await MultipartFile.fromFile(
              imageUrl,
              filename: imageUrl.split('/').last,
              contentType: MediaType.parse(lookupMimeType(imageUrl) ?? 'image/jpeg'),
            ),
          ),
        );
      }

      final options = await _getAuthHeaders(extraHeaders: {
        "Content-Type": "multipart/form-data",
      });

      final response = await _apiService.dio.put(
        ApiEndpoints.updatePost(postId),
        data: formData,
        options: options,
      );

      return PostModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  // === DELETE POST ===
  @override
  Future<void> deletePost(String postId) async {
    try {
      final options = await _getAuthHeaders();
      final response = await _apiService.dio.delete(ApiEndpoints.deletePost(postId), options: options);
      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception("Post deletion failed");
      }
    } catch (e) {
      throw Exception("Failed to delete post: $e");
    }
  }

  // === UPLOAD IMAGE (separate like uploadProfilePicture) ===
  @override
  Future<String> uploadImage(File postImg) async {
    try {
      final mimeType = lookupMimeType(postImg.path);
      final fileName = postImg.path.split('/').last;

      final formData = FormData.fromMap({
        "postImg": await MultipartFile.fromFile(
          postImg.path,
          filename: fileName,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      });

      final options = await _getAuthHeaders(extraHeaders: {
        "Content-Type": "multipart/form-data",
      });

      final response = await _apiService.dio.post(
        "post/uploadImg",
        data: formData,
        options: options,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Upload failed: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to upload post image: $e');
    }
  }
}
