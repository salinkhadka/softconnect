import 'package:softconnect/features/home/data/model/like_model.dart';

abstract class ILikeDataSource {
  /// Likes a post by given userId and postId (POST /like)
  Future<LikeModel> likePost({required String userId, required String postId});

  /// Unlikes a post by given userId and postId (POST /unlike)
  Future<void> unlikePost({required String userId, required String postId});

  /// Gets all likes for a post by postId (GET /like/:postId)
  Future<List<LikeModel>> getLikesByPostId(String postId);
}
