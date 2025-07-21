// lib/features/home/data/data_source/post_local_datasource_impl.dart

import 'package:softconnect/core/network/hive_service.dart';
import 'package:softconnect/features/home/data/data_source/post_local_datasource.dart';
import 'package:softconnect/features/home/data/model/post_hive_model.dart';

class PostLocalDataSourceImpl implements IPostLocalDataSource {
  final HiveService _hiveService;

  PostLocalDataSourceImpl({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<void> cachePosts(List<PostHiveModel> postsToCache) async {
    try {
      await _hiveService.addPosts(postsToCache);
    } catch (e) {
      throw Exception('Failed to cache posts: $e');
    }
  }

  @override
  Future<List<PostHiveModel>> getLastPosts() async {
    try {
      final posts = await _hiveService.getAllPosts();
      return posts;
    } catch (e) {
      throw Exception('Failed to retrieve posts from cache: $e');
    }
  }
}