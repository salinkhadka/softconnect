import 'dart:io';

import 'package:softconnect/features/home/data/model/post_model.dart';

abstract interface class IPostsDataSource {
  /// Fetches all posts from the backend (GET /)
  Future<List<PostModel>> getAllPosts();

  /// Fetches posts created by a specific user (GET /user/:userId)
  Future<List<PostModel>> getPostsByUserId(String userId);

  /// Fetches a single post by its ID (GET /:id)
  Future<PostModel> getPostById(String postId);

  /// Creates a new post with optional image upload (POST /createPost)
  /// You will likely pass content, privacy, and optionally an image file.
  Future<PostModel> createPost({
    required String userId,
    required String content,
    required String privacy,
    String? imagePath, // local path or file reference to upload
  });

  /// Updates a post by its ID with new content/privacy/image (PUT /:id)
  Future<PostModel> updatePost({
    required String postId,
    String? content,
    String? privacy,
    String? imagePath,
  });

  /// Deletes a post by its ID (DELETE /:id)
  Future<void> deletePost(String postId);

   Future<String> uploadImage(File postImg);
}
