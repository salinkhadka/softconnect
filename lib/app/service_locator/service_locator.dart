import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/core/network/hive_service.dart';

// Auth imports
import 'package:softconnect/features/auth/data/data_source/local_datasource/user_hive_data_source.dart';
import 'package:softconnect/features/auth/data/data_source/remote_dataSource/user_remote_data_source.dart';
import 'package:softconnect/features/auth/data/data_source/user_data_source.dart';
import 'package:softconnect/features/auth/data/repository/remote_repository/user_remote_repository.dart';
import 'package:softconnect/features/auth/domain/repository/user_repository.dart';
import 'package:softconnect/features/auth/domain/use_case/user_login_usecase.dart';
import 'package:softconnect/features/auth/domain/use_case/user_register_usecase.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_viewmodel.dart';
import 'package:softconnect/features/friends/domain/use_case/get_following_usecase.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_viewmodel.dart';

// Home imports
import 'package:softconnect/features/home/data/data_source/remote_dataSource/comment_remote_datasource.dart';
import 'package:softconnect/features/home/data/data_source/remote_dataSource/like_remote_datasource.dart';
import 'package:softconnect/features/home/data/data_source/remote_dataSource/post_remote_datasource.dart';
import 'package:softconnect/features/home/data/repository/remote_repository/comment_remote_repository.dart';

import 'package:softconnect/features/home/data/repository/remote_repository/like_remote_repository.dart';
import 'package:softconnect/features/home/data/repository/remote_repository/post_remote_repository.dart';
import 'package:softconnect/features/home/domain/repository/comment_repository.dart';
import 'package:softconnect/features/home/domain/repository/like_repository.dart';
import 'package:softconnect/features/home/domain/repository/post_repository.dart';
import 'package:softconnect/features/home/domain/use_case/getCommentsUseCase.dart';
import 'package:softconnect/features/home/domain/use_case/getLikesUseCase.dart';
import 'package:softconnect/features/home/domain/use_case/getPostsUseCase.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_view_model.dart';
// import 'package:softconnect/features/home/presentation/view_model/feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/homepage_viewmodel.dart';
import 'package:softconnect/features/message/data/data_source/remote_dataSource/message_remote_datasource.dart';
import 'package:softconnect/features/message/data/repository/remote_repository/message_remote_repository.dart';
import 'package:softconnect/features/message/domain/repository/message_repository.dart';
import 'package:softconnect/features/message/domain/use_case/inbox_usecase.dart';
import 'package:softconnect/features/message/domain/use_case/message_usecase.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_viewmodel.dart';
import 'package:softconnect/features/message/presentation/view_model/message_view_model/message_view_model.dart';

// Splash imports
import 'package:softconnect/features/splash/presentation/view_model/splash_viewmodel.dart';

// Friends imports
import 'package:softconnect/features/friends/data/data_source/remote_dataSource/friends_api_datasource.dart';
import 'package:softconnect/features/friends/data/repository/remote_repository/friends_remote_repository.dart';
import 'package:softconnect/features/friends/domain/repository/friends_repository.dart';
import 'package:softconnect/features/friends/domain/use_case/follow_user_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/get_followers_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/unfollow_user_usecase.dart';


final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  await _initHiveService();
  await _initApiService();
  await _initSplashModule();
  await _initAuthModule();
  await _initHomeModule();
  await _initFriendsModule();
   await _initMessageModule();
}

Future<void> _initMessageModule() async {
  // Data source
  serviceLocator.registerLazySingleton<MessageApiDataSource>(
    () => MessageApiDataSource(apiService: serviceLocator<ApiService>()),
  );

  // Repository
  serviceLocator.registerLazySingleton<IMessageRepository>(
    () => MessageRemoteRepository(
      dataSource: serviceLocator<MessageApiDataSource>(),
    ),
  );

  // Use cases
  serviceLocator.registerLazySingleton<GetInboxUseCase>(
    () => GetInboxUseCase(repository: serviceLocator<IMessageRepository>()),
  );

  serviceLocator.registerLazySingleton<GetMessagesBetweenUsersUseCase>(
    () => GetMessagesBetweenUsersUseCase(repository: serviceLocator<IMessageRepository>()),
  );

  serviceLocator.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(repository: serviceLocator<IMessageRepository>()),
  );

  serviceLocator.registerLazySingleton<DeleteMessageUseCase>(
    () => DeleteMessageUseCase(repository: serviceLocator<IMessageRepository>()),
  );

  // ViewModels
  serviceLocator.registerFactory<InboxViewModel>(
    () => InboxViewModel(serviceLocator<GetInboxUseCase>()),
  );

  serviceLocator.registerFactory<MessageViewModel>(
    () => MessageViewModel(
      getMessagesBetweenUsersUseCase: serviceLocator<GetMessagesBetweenUsersUseCase>(),
      sendMessageUseCase: serviceLocator<SendMessageUseCase>(),
      deleteMessageUseCase: serviceLocator<DeleteMessageUseCase>(),
    ),
  );

  print("InboxViewModel registered: ${serviceLocator.isRegistered<InboxViewModel>()}");
  print("MessageViewModel registered: ${serviceLocator.isRegistered<MessageViewModel>()}");
}


Future<void> _initHiveService() async {
  serviceLocator.registerLazySingleton(() => HiveService());
}

Future<void> _initApiService() async {
  serviceLocator.registerLazySingleton<Dio>(() => Dio());
  serviceLocator.registerLazySingleton(() => ApiService(serviceLocator<Dio>()));
}

Future<void> _initAuthModule() async {
  // Data Sources
  serviceLocator.registerLazySingleton<IUserDataSource>(
      () => UserHiveDataSource(hiveService: serviceLocator<HiveService>()),
      instanceName: 'localDataSource');
  serviceLocator.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSource(apiService: serviceLocator<ApiService>()));

  // Repository
  serviceLocator.registerLazySingleton<IUserRepository>(() => UserRemoteRepository(
      remoteDataSource: serviceLocator<UserRemoteDataSource>()));

  // Use cases
  serviceLocator.registerLazySingleton<UserLoginUsecase>(
      () => UserLoginUsecase(userRepository: serviceLocator<IUserRepository>()));
  serviceLocator.registerLazySingleton<UserRegisterUsecase>(() =>
      UserRegisterUsecase(userRepository: serviceLocator<IUserRepository>()));

  // ViewModels
  serviceLocator.registerFactory<LoginViewModel>(
      () => LoginViewModel(userLoginUsecase: serviceLocator<UserLoginUsecase>()));
  serviceLocator.registerFactory<SignupViewModel>(() =>
      SignupViewModel(userRegisterUsecase: serviceLocator<UserRegisterUsecase>()));
}

Future<void> _initSplashModule() async {
  serviceLocator.registerFactory(() => SplashViewModel());
}

Future<void> _initHomeModule() async {
  // Repositories with inline data source injection
  serviceLocator.registerLazySingleton<IPostRepository>(
    () => PostRemoteRepository(
      postDataSource: PostRemoteDatasource(apiService: serviceLocator<ApiService>()),
    ),
  );

  serviceLocator.registerLazySingleton<ILikeRepository>(
    () => LikeRemoteRepository(
      likeDataSource: LikeRemoteDatasource(apiService: serviceLocator<ApiService>()),
    ),
  );

  serviceLocator.registerLazySingleton<ICommentRepository>(
    () => CommentRemoteRepository(
      commentDataSource: CommentRemoteDatasource(apiService: serviceLocator<ApiService>()),
    ),
  );

  // Use cases
  serviceLocator.registerLazySingleton<GetAllPostsUsecase>(
    () => GetAllPostsUsecase(serviceLocator<IPostRepository>()),
  );
  serviceLocator.registerLazySingleton<LikePostUsecase>(
    () => LikePostUsecase(likeRepository: serviceLocator<ILikeRepository>()),
  );
  serviceLocator.registerLazySingleton<UnlikePostUsecase>(
    () => UnlikePostUsecase(likeRepository: serviceLocator<ILikeRepository>()),
  );
  serviceLocator.registerLazySingleton<GetLikesByPostIdUsecase>(
    () => GetLikesByPostIdUsecase(likeRepository: serviceLocator<ILikeRepository>()),
  );
  
  // Comment-related use cases
  serviceLocator.registerLazySingleton<GetCommentsByPostIdUsecase>(
    () => GetCommentsByPostIdUsecase(commentRepository: serviceLocator<ICommentRepository>()),
  );
  serviceLocator.registerLazySingleton<CreateCommentUsecase>(
    () => CreateCommentUsecase(commentRepository: serviceLocator<ICommentRepository>()),
  );
  serviceLocator.registerLazySingleton<DeleteCommentUsecase>(
    () => DeleteCommentUsecase(commentRepository: serviceLocator<ICommentRepository>()),
  );

  // === Your new use cases for post creation and image upload ===
  serviceLocator.registerLazySingleton<CreatePostUsecase>(
    () => CreatePostUsecase(serviceLocator<IPostRepository>()),
  );

  serviceLocator.registerLazySingleton<UploadImageUsecase>(
    () => UploadImageUsecase(serviceLocator<IPostRepository>()),
  );

  // ViewModels
  serviceLocator.registerFactory<FeedViewModel>(
    () => FeedViewModel(
      getAllPostsUseCase: serviceLocator<GetAllPostsUsecase>(),
      likePostUseCase: serviceLocator<LikePostUsecase>(),
      unlikePostUseCase: serviceLocator<UnlikePostUsecase>(),
      getLikesByPostIdUsecase: serviceLocator<GetLikesByPostIdUsecase>(),
      getCommentsByPostIdUsecase: serviceLocator<GetCommentsByPostIdUsecase>(),
    ),
  );

  serviceLocator.registerFactory<CommentViewModel>(
  () => CommentViewModel(
    createCommentUsecase: serviceLocator<CreateCommentUsecase>(),
    getCommentsUsecase: serviceLocator<GetCommentsByPostIdUsecase>(),
    deleteCommentUsecase: serviceLocator<DeleteCommentUsecase>(), // ✅ FIXED
  ),
);


  serviceLocator.registerFactory<HomeViewModel>(() => HomeViewModel());

  print("FeedViewModel registered: ${serviceLocator.isRegistered<FeedViewModel>()}");
  print("CommentViewModel registered: ${serviceLocator.isRegistered<CommentViewModel>()}");
  print("CreatePostUsecase registered: ${serviceLocator.isRegistered<CreatePostUsecase>()}");
  print("UploadImageUsecase registered: ${serviceLocator.isRegistered<UploadImageUsecase>()}");
}




Future<void> _initFriendsModule() async {
  // Data source
  serviceLocator.registerLazySingleton<FriendsApiDatasource>(
      () => FriendsApiDatasource(apiService: serviceLocator<ApiService>()));

  // Repository
  serviceLocator.registerLazySingleton<IFriendsRepository>(() =>
      FriendsRemoteRepository(
          friendsDataSource: serviceLocator<FriendsApiDatasource>(),
          apiService: serviceLocator<ApiService>()));

  // Use cases
  serviceLocator.registerLazySingleton<FollowUserUseCase>(
      () => FollowUserUseCase(repository: serviceLocator<IFriendsRepository>()));
  serviceLocator.registerLazySingleton<UnfollowUserUseCase>(
      () => UnfollowUserUseCase(repository: serviceLocator<IFriendsRepository>()));
  serviceLocator.registerLazySingleton<GetFollowersUseCase>(
      () => GetFollowersUseCase(repository: serviceLocator<IFriendsRepository>()));
  serviceLocator.registerLazySingleton<GetFollowingUseCase>(
      () => GetFollowingUseCase(repository: serviceLocator<IFriendsRepository>()));

  // ViewModel
  serviceLocator.registerFactory<FollowViewModel>(() => FollowViewModel(
        followUserUseCase: serviceLocator<FollowUserUseCase>(),
        unfollowUserUseCase: serviceLocator<UnfollowUserUseCase>(),
        getFollowersUseCase: serviceLocator<GetFollowersUseCase>(),
        getFollowingUseCase: serviceLocator<GetFollowingUseCase>(),
      ));
}