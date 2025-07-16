import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/features/home/data/data_source/post_datasource.dart';
import 'package:softconnect/features/home/data/model/post_model.dart';

class PostRemoteDatasource implements IPostsDataSource {
  final ApiService _apiService;

  PostRemoteDatasource({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<List<PostModel>> getAllPosts() async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.getAllPosts);
      final data = response.data['data'] as List;
      return data.map((json) => PostModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  @override
  Future<List<PostModel>> getPostsByUserId(String userId) async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.getUserPosts(userId));
      final data = response.data['data'] as List;
      return data.map((json) => PostModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user posts: $e');
    }
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.getPostById(postId));
      final data = response.data['data'];
      return PostModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch post: $e');
    }
  }

  @override
  Future<PostModel> createPost({
    required String userId,
    required String content,
    required String privacy,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        "userId": userId,
        "content": content,
        "privacy": privacy,
        if (imagePath != null)
          "imageUrl": await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
            contentType: MediaType.parse(lookupMimeType(imagePath) ?? 'image/jpeg'),
          ),
      });

      final response = await _apiService.dio.post(
        ApiEndpoints.createPost,
        data: formData,
        options: Options(headers: {
          "Content-Type": "multipart/form-data",
        }),
      );

      return PostModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  @override
  Future<PostModel> updatePost({
    required String postId,
    String? content,
    String? privacy,
    String? imagePath,
  }) async {
    try {
      final formData = FormData();

      if (content != null) formData.fields.add(MapEntry('content', content));
      if (privacy != null) formData.fields.add(MapEntry('privacy', privacy));
      if (imagePath != null) {
        formData.files.add(
          MapEntry(
            "imageUrl",
            await MultipartFile.fromFile(
              imagePath,
              filename: imagePath.split('/').last,
              contentType: MediaType.parse(lookupMimeType(imagePath) ?? 'image/jpeg'),
            ),
          ),
        );
      }

      final response = await _apiService.dio.put(
        ApiEndpoints.updatePost(postId),
        data: formData,
        options: Options(headers: {
          "Content-Type": "multipart/form-data",
        }),
      );

      return PostModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      final response = await _apiService.dio.delete(ApiEndpoints.deletePost(postId));
      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception("Post deletion failed");
      }
    } catch (e) {
      throw Exception("Failed to delete post: $e");
    }
  }

  @override
  Future<String> uploadImage(File postImg) async {
    try {
      final mimeType = lookupMimeType(postImg.path);
      final formData = FormData.fromMap({
        "postImg": await MultipartFile.fromFile(
          postImg.path,
          filename: postImg.path.split('/').last,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        )
      });

      final response = await _apiService.dio.post(
        "post/uploadImg",
        data: formData,
        options: Options(headers: {
          "Content-Type": "multipart/form-data",
        }),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']; // Return filename like "uploads/postImg-xyz.png"
      } else {
        throw Exception('Image upload failed: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
