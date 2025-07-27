// lib/features/home/data/data_source/post_local_datasource.dart
import 'package:softconnect/features/home/data/model/post_hive_model.dart';

/// The interface defining operations for the local post cache.
/// Its only job is to get and save lists of posts.
abstract interface class IPostLocalDataSource {
  /// Retrieves the cached list of [PostHiveModel] from local storage.
  /// Throws an exception if there's a fatal error reading the cache.
  Future<List<PostHiveModel>> getLastPosts();

  /// Deletes all existing posts and saves a new list to the cache.
  Future<void> cachePosts(List<PostHiveModel> postsToCache);
}
