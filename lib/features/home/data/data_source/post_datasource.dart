import 'dart:io';
import 'package:softconnect/features/home/data/model/post_model.dart';

abstract interface class IPostsDataSource {
  /// Fetches all posts from the backend (GET /)
  Future<List<PostModel>> getAllPosts();

  /// Fetches posts created by a specific user (GET /user/:userId)
  Future<List<PostModel>> getPostsByUserId(String userId);

  /// Fetches a single post by its ID (GET /:id)
  Future<PostModel> getPostById(String postId);

  /// Creates a new post (POST /createPost)
  /// Sends the content, privacy, and image URL (if available).
  Future<PostModel> createPost({
    required String userId,
    required String content,
    required String privacy,
    String? imageUrl, // URL or filename returned from uploadImage
  });

  /// Updates a post by its ID (PUT /:id)
  /// Can update content, privacy, and optionally image URL.
  Future<PostModel> updatePost({
    required String postId,
    String? content,
    String? privacy,
    String? imageUrl,
  });

  /// Deletes a post by its ID (DELETE /:id)
  Future<void> deletePost(String postId);

  /// Uploads an image file to the backend and returns the image URL or filename
  Future<String> uploadImage(File postImg);
}
