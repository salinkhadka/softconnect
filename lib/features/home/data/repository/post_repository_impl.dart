// lib/features/home/data/repository/post_repository_impl.dart

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/home/data/data_source/post_datasource.dart';
import 'package:softconnect/features/home/data/data_source/post_local_datasource.dart';
import 'package:softconnect/features/home/data/model/post_hive_model.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';
import 'package:softconnect/features/home/domain/repository/post_repository.dart';

class PostRepositoryImpl implements IPostRepository {
  final IPostsDataSource remoteDataSource;
  final IPostLocalDataSource localDataSource;
  final Connectivity connectivity;

  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  /// Enhanced connectivity check that actually tests internet access
  Future<bool> _hasInternetConnection() async {
    try {
      // First check basic connectivity
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Then test actual internet access with a quick ping
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      // If any error occurs, assume no internet
      return false;
    }
  }

  /// Alternative method using HTTP head request (more reliable for API connectivity)
  Future<bool> _canReachServer() async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Try to make a quick HEAD request to your server
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      
      final request = await client.headUrl(Uri.parse('http://10.0.2.2:2000/'))
          .timeout(const Duration(seconds: 5));
      
      final response = await request.close()
          .timeout(const Duration(seconds: 5));
      
      client.close();
      return response.statusCode == 200 || response.statusCode == 404; // Server is reachable
      
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getAllPosts() async {
    // Use the enhanced connectivity check
    final hasInternet = await _hasInternetConnection();
    // OR use the server-specific check:
    // final hasInternet = await _canReachServer();
    
    if (hasInternet) {
      // --- ONLINE PATH ---
      try {
        print("🌐 Fetching posts from server...");
        final remotePosts = await remoteDataSource.getAllPosts();
        
        // Cache the fresh data
        final hiveModels = remotePosts
            .map((remoteModel) => PostHiveModel.fromRemoteModel(remoteModel))
            .toList();
        await localDataSource.cachePosts(hiveModels);
        
        print("✅ Successfully fetched ${remotePosts.length} posts from server");
        return Right(remotePosts.map((model) => model.toEntity()).toList());
      } catch (e) {
        print("❌ Failed to fetch from server: $e");
        print("📱 Falling back to cached data...");
        
        // Fallback to cache if server fails
        return await _getFromCache();
      }
    } else {
      // --- OFFLINE PATH ---
      print("📱 No internet connection, loading from cache...");
      return await _getFromCache();
    }
  }

  /// Helper method to get posts from cache
  Future<Either<Failure, List<PostEntity>>> _getFromCache() async {
    try {
      final localPosts = await localDataSource.getLastPosts();
      
      if (localPosts.isEmpty) {
        return Left(LocalDatabaseFailure(
          message: 'No cached data available. Please connect to the internet to load posts.'
        ));
      }
      
      print("✅ Successfully loaded ${localPosts.length} posts from cache");
      return Right(localPosts.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(LocalDatabaseFailure(
        message: 'Failed to retrieve data from cache: ${e.toString()}'
      ));
    }
  }

  // --- MUTATION METHODS (Create, Update, Delete) ---
  @override
  Future<Either<Failure, PostEntity>> createPost({
    required String userId,
    required String content,
    required String privacy,
    String? imageUrl,
  }) async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      return Left(RemoteDatabaseFailure(
        message: "You must be online to create a post."
      ));
    }
    
    try {
      final remotePost = await remoteDataSource.createPost(
        userId: userId, 
        content: content, 
        privacy: privacy, 
        imageUrl: imageUrl
      );
      return Right(remotePost.toEntity());
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> updatePost({
    required String postId,
    String? content,
    String? privacy,
    String? imageUrl,
  }) async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      return Left(RemoteDatabaseFailure(
        message: "You must be online to update a post."
      ));
    }
    
    try {
      final model = await remoteDataSource.updatePost(
        postId: postId,
        content: content,
        privacy: privacy,
        imageUrl: imageUrl,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      return Left(RemoteDatabaseFailure(
        message: "You must be online to delete a post."
      ));
    }
    
    try {
      await remoteDataSource.deletePost(postId);
      return const Right(null);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(File postImg) async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      return Left(RemoteDatabaseFailure(
        message: "You must be online to upload an image."
      ));
    }
    
    try {
      final url = await remoteDataSource.uploadImage(postImg);
      return Right(url);
    } catch (e) {
      return Left(RemoteDatabaseFailure(message: e.toString()));
    }
  }

  // Enhanced methods that can fallback to cache
  @override
  Future<Either<Failure, List<PostEntity>>> getPostsByUserId(String userId) async {
    final hasInternet = await _hasInternetConnection();
    
    if (hasInternet) {
      try {
        final models = await remoteDataSource.getPostsByUserId(userId);
        return Right(models.map((e) => e.toEntity()).toList());
      } catch (e) {
        // Could implement user-specific cache here if needed
        return Left(RemoteDatabaseFailure(message: e.toString()));
      }
    } else {
      // For now, require internet for user-specific posts
      return Left(RemoteDatabaseFailure(
        message: "You must be online to view this user's posts."
      ));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(String postId) async {
    final hasInternet = await _hasInternetConnection();
    
    if (hasInternet) {
      try {
        final model = await remoteDataSource.getPostById(postId);
        return Right(model.toEntity());
      } catch (e) {
        // Could implement post-specific cache lookup here if needed
        return Left(RemoteDatabaseFailure(message: e.toString()));
      }
    } else {
      return Left(RemoteDatabaseFailure(
        message: "You must be online to view this post."
      ));
    }
  }
}