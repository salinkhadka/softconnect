import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:softconnect/app/theme/theme_provider.dart';

import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/core/network/hive_service.dart';
import 'package:softconnect/features/home/data/data_source/local_datasource/post_lcoal_datasource.dart';

// --- DATA SOURCE & REPO CONTRACTS (INTERFACES) ---
import 'package:softconnect/features/home/domain/repository/post_repository.dart';
import 'package:softconnect/features/home/data/data_source/post_datasource.dart';
import 'package:softconnect/features/home/data/data_source/post_local_datasource.dart';
import 'package:softconnect/features/home/domain/repository/like_repository.dart';
import 'package:softconnect/features/home/domain/repository/comment_repository.dart';
import 'package:softconnect/features/auth/domain/repository/user_repository.dart';
import 'package:softconnect/features/friends/domain/repository/friends_repository.dart';
import 'package:softconnect/features/message/data/data_source/local_datasource/message_hive_datasource_impl.dart';
import 'package:softconnect/features/message/data/data_source/message_datsource.dart';
import 'package:softconnect/features/message/data/data_source/message_hive_datasource.dart';
import 'package:softconnect/features/message/domain/repository/message_repository.dart';
import 'package:softconnect/features/message/domain/repository/message_repository_impl.dart';
import 'package:softconnect/features/profile/domain/repository/profile_repository.dart';
import 'package:softconnect/features/notification/domain/repository/notification_repository.dart';
import 'package:softconnect/features/auth/data/data_source/user_data_source.dart';
import 'package:softconnect/features/notification/data/data_source/notification_data_source.dart';

// --- DATA SOURCE & REPO IMPLEMENTATIONS ---
import 'package:softconnect/features/home/data/data_source/remote_dataSource/post_remote_datasource.dart';
// import 'package:softconnect/features/home/data/data_source/post_local_datasource_impl.dart';
import 'package:softconnect/features/home/data/repository/post_repository_impl.dart';
import 'package:softconnect/features/auth/data/data_source/local_datasource/user_hive_data_source.dart';
import 'package:softconnect/features/auth/data/data_source/remote_dataSource/user_remote_data_source.dart';
import 'package:softconnect/features/auth/data/repository/remote_repository/user_remote_repository.dart';
import 'package:softconnect/features/home/data/data_source/remote_dataSource/comment_remote_datasource.dart';
import 'package:softconnect/features/home/data/data_source/remote_dataSource/like_remote_datasource.dart';
import 'package:softconnect/features/home/data/repository/remote_repository/comment_remote_repository.dart';
import 'package:softconnect/features/home/data/repository/remote_repository/like_remote_repository.dart';
import 'package:softconnect/features/message/data/data_source/remote_dataSource/message_remote_datasource.dart';
import 'package:softconnect/features/message/data/repository/remote_repository/message_remote_repository.dart';
import 'package:softconnect/features/notification/data/data_source/remote_dataSource/notification_remote_datasource.dart';
import 'package:softconnect/features/notification/data/repository/remote_repository/notification_remote_repository.dart';
import 'package:softconnect/features/profile/data/data_source/remote_dataSource/profile_page_remote_datasource.dart';
import 'package:softconnect/features/profile/data/repository/remote_repository/profile_remote_repository.dart';
import 'package:softconnect/features/friends/data/data_source/remote_dataSource/friends_api_datasource.dart';
import 'package:softconnect/features/friends/data/repository/remote_repository/friends_remote_repository.dart';

// --- ALL USE CASES ---
import 'package:softconnect/features/auth/domain/use_case/getall_users_usecase.dart';
import 'package:softconnect/features/auth/domain/use_case/request_passsword_reset_usecase.dart';
import 'package:softconnect/features/auth/domain/use_case/reset_password_usecase.dart';
import 'package:softconnect/features/auth/domain/use_case/user_get_current_user_usecase.dart';
import 'package:softconnect/features/auth/domain/use_case/user_login_usecase.dart';
import 'package:softconnect/features/auth/domain/use_case/user_register_usecase.dart';
import 'package:softconnect/features/auth/domain/use_case/verify_password.dart';
import 'package:softconnect/features/home/domain/use_case/getCommentsUseCase.dart';
import 'package:softconnect/features/home/domain/use_case/getLikesUseCase.dart';
import 'package:softconnect/features/home/domain/use_case/getPostsUseCase.dart';
import 'package:softconnect/features/message/domain/use_case/inbox_usecase.dart';
import 'package:softconnect/features/message/domain/use_case/message_usecase.dart';
import 'package:softconnect/features/notification/domain/use_case/notification_usecases.dart';
import 'package:softconnect/features/profile/domain/use_case/updateProfileUsecase.dart';
import 'package:softconnect/features/friends/domain/use_case/follow_user_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/get_followers_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/unfollow_user_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/get_following_usecase.dart';

// --- ALL VIEWMODELS ---
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_viewmodel.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/Feed_view_model/feed_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/Comment_view_model/comment_view_model.dart';
import 'package:softconnect/features/home/presentation/view_model/homepage_viewmodel.dart';
import 'package:softconnect/features/home/presentation/view_model/user_search_viewmodel.dart';
import 'package:softconnect/features/message/presentation/view_model/inbox_viewmodel.dart';
import 'package:softconnect/features/message/presentation/view_model/message_view_model/message_view_model.dart';
import 'package:softconnect/features/notification/presentation/view_model/notification_viewmodel.dart';
import 'package:softconnect/features/profile/presentation/view_model/user_profile_viewmodel.dart';
import 'package:softconnect/features/splash/presentation/view_model/splash_viewmodel.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  await _initCoreServices();

  // New Post module must be initialized before Home and Profile
  await _initPostModule();

  await _initSplashModule();
  await _initAuthModule();
  await _initHomeModule();
  await _initFriendsModule();
  await _initMessageModule();
  await _initProfileModule();
  await _initNotificationModule();
}

Future<void> _initCoreServices() async {
  serviceLocator.registerLazySingleton(() => HiveService());
  serviceLocator.registerLazySingleton<Dio>(() => Dio());
  serviceLocator.registerLazySingleton(() => ApiService(serviceLocator<Dio>()));
  
  // Register ThemeProvider as a singleton
  serviceLocator.registerLazySingleton<ThemeProvider>(() => ThemeProvider());
}

// =========================================================================
// === NEW UNIFIED POST MODULE (This contains all the new post logic) ===
// =========================================================================
Future<void> _initPostModule() async {
  // External Dependencies
  serviceLocator.registerLazySingleton(() => Connectivity());

  // Data Sources for Posts
  serviceLocator.registerFactory<IPostsDataSource>(
    () => PostRemoteDatasource(apiService: serviceLocator<ApiService>()),
  );
  serviceLocator.registerFactory<IPostLocalDataSource>(
    () => PostLocalDataSourceImpl(hiveService: serviceLocator<HiveService>()),
  );

  // THE NEW UNIFIED REPOSITORY
  serviceLocator.registerLazySingleton<IPostRepository>(
    () => PostRepositoryImpl(
      remoteDataSource: serviceLocator<IPostsDataSource>(),
      localDataSource: serviceLocator<IPostLocalDataSource>(),
      connectivity: serviceLocator<Connectivity>(),
    ),
  );

  // ALL POST-RELATED USE CASES ARE NOW REGISTERED HERE
  serviceLocator.registerLazySingleton<GetAllPostsUsecase>(
    () => GetAllPostsUsecase(serviceLocator<IPostRepository>()),
  );
  serviceLocator.registerLazySingleton<CreatePostUsecase>(
    () => CreatePostUsecase(serviceLocator<IPostRepository>()),
  );
  serviceLocator.registerLazySingleton<UploadImageUsecase>(
    () => UploadImageUsecase(serviceLocator<IPostRepository>()),
  );
  serviceLocator.registerLazySingleton<UpdatePostUsecase>(
    () => UpdatePostUsecase(serviceLocator<IPostRepository>()),
  );
  serviceLocator.registerLazySingleton<DeletePostUsecase>(
    () => DeletePostUsecase(serviceLocator<IPostRepository>()),
  );
  serviceLocator.registerLazySingleton<GetPostsByUserIdUsecase>(
    () => GetPostsByUserIdUsecase(serviceLocator<IPostRepository>()),
  );

  print("✅ Unified Post Module Initialized Successfully.");
}

Future<void> _initHomeModule() async {
  // --- OLD IPostRepository Registration ---
  // serviceLocator.registerLazySingleton<IPostRepository>(
  //   () => PostRemoteRepository(
  //     postDataSource:
  //         PostRemoteDatasource(apiService: serviceLocator<ApiService>()),
  //   ),
  // );

  // Like and Comment functionality remains online-only for now
  serviceLocator.registerLazySingleton<ILikeRepository>(
    () => LikeRemoteRepository(
      likeDataSource:
          LikeRemoteDatasource(apiService: serviceLocator<ApiService>()),
    ),
  );
  serviceLocator.registerLazySingleton<ICommentRepository>(
    () => CommentRemoteRepository(
      commentDataSource:
          CommentRemoteDatasource(apiService: serviceLocator<ApiService>()),
    ),
  );

  // Post use cases were moved to _initPostModule.

  // Use cases for Like and Comment
  serviceLocator.registerLazySingleton<LikePostUsecase>(
    () => LikePostUsecase(likeRepository: serviceLocator<ILikeRepository>()),
  );
  serviceLocator.registerLazySingleton<UnlikePostUsecase>(
    () => UnlikePostUsecase(likeRepository: serviceLocator<ILikeRepository>()),
  );
  serviceLocator.registerLazySingleton<GetLikesByPostIdUsecase>(
    () => GetLikesByPostIdUsecase(
        likeRepository: serviceLocator<ILikeRepository>()),
  );
  serviceLocator.registerLazySingleton<GetCommentsByPostIdUsecase>(
    () => GetCommentsByPostIdUsecase(
        commentRepository: serviceLocator<ICommentRepository>()),
  );
  serviceLocator.registerLazySingleton<CreateCommentUsecase>(
    () => CreateCommentUsecase(
        commentRepository: serviceLocator<ICommentRepository>()),
  );
  serviceLocator.registerLazySingleton<DeleteCommentUsecase>(
    () => DeleteCommentUsecase(
        commentRepository: serviceLocator<ICommentRepository>()),
  );

  // ViewModels - No changes needed, they get dependencies from the locator
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
      deleteCommentUsecase: serviceLocator<DeleteCommentUsecase>(),
    ),
  );
  serviceLocator.registerFactory<HomeViewModel>(() => HomeViewModel());
}

Future<void> _initProfileModule() async {
  // Profile specific data source and repository
  serviceLocator.registerLazySingleton<ProfilePageRemoteDataSource>(
    () => ProfilePageRemoteDataSource(apiService: serviceLocator<ApiService>()),
  );
  serviceLocator.registerLazySingleton<IProfileRepository>(
    () => ProfileRemoteRepository(
        dataSource: serviceLocator<ProfilePageRemoteDataSource>()),
  );

  // Use cases for Profile
  serviceLocator.registerLazySingleton<GetUserByIdUsecase>(
    () => GetUserByIdUsecase(userRepository: serviceLocator<IUserRepository>()),
  );
  serviceLocator.registerLazySingleton<UpdateUserProfileUsecase>(
    () => UpdateUserProfileUsecase(serviceLocator<IProfileRepository>()),
  );

  // Post use cases are now registered in _initPostModule.

  // ViewModel - No changes needed
  serviceLocator.registerFactory<UserProfileViewModel>(
    () => UserProfileViewModel(
      getUserById: serviceLocator<GetUserByIdUsecase>(),
      getPostsByUserId: serviceLocator<GetPostsByUserIdUsecase>(),
      updateUserProfileUsecase: serviceLocator<UpdateUserProfileUsecase>(),
      uploadImageUsecase: serviceLocator<UploadImageUsecase>(),
      updatePostUsecase: serviceLocator<UpdatePostUsecase>(),
      deletePostUsecase: serviceLocator<DeletePostUsecase>(),
    ),
  );
}

// Keep the rest of your `_init...` functions (`_initAuthModule`, `_initFriendsModule`, etc.) exactly as they were.
// I have included them below for completeness.

Future<void> _initSplashModule() async {
  serviceLocator.registerFactory(() => SplashViewModel());
}

Future<void> _initAuthModule() async {
  serviceLocator.registerLazySingleton<IUserDataSource>(
    () => UserHiveDataSource(hiveService: serviceLocator<HiveService>()),
    instanceName: 'localDataSource',
  );
  serviceLocator.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(apiService: serviceLocator<ApiService>()),
  );
  serviceLocator.registerLazySingleton<IUserRepository>(
    () => UserRemoteRepository(
      remoteDataSource: serviceLocator<UserRemoteDataSource>(),
    ),
  );
  serviceLocator.registerLazySingleton<UserLoginUsecase>(
    () => UserLoginUsecase(userRepository: serviceLocator<IUserRepository>()),
  );
  serviceLocator.registerLazySingleton<VerifyPasswordUsecase>(
    () => VerifyPasswordUsecase(
        userRepository: serviceLocator<IUserRepository>()),
  );
  serviceLocator.registerLazySingleton<ResetPasswordUsecase>(
    () =>
        ResetPasswordUsecase(userRepository: serviceLocator<IUserRepository>()),
  );
  serviceLocator.registerLazySingleton<RequestPasswordResetUsecase>(
    () => RequestPasswordResetUsecase(
        userRepository: serviceLocator<IUserRepository>()),
  );
  serviceLocator.registerLazySingleton<UserRegisterUsecase>(
    () =>
        UserRegisterUsecase(userRepository: serviceLocator<IUserRepository>()),
  );
  serviceLocator.registerLazySingleton<SearchUsersUsecase>(
    () => SearchUsersUsecase(userRepository: serviceLocator<IUserRepository>()),
  );
  serviceLocator.registerFactory<LoginViewModel>(
    () => LoginViewModel(userLoginUsecase: serviceLocator<UserLoginUsecase>()),
  );
  serviceLocator.registerFactory<SignupViewModel>(
    () => SignupViewModel(
        userRegisterUsecase: serviceLocator<UserRegisterUsecase>()),
  );
  serviceLocator.registerFactory<UserSearchViewModel>(
    () => UserSearchViewModel(
        searchUsersUsecase: serviceLocator<SearchUsersUsecase>()),
  );
}

Future<void> _initFriendsModule() async {
  serviceLocator.registerLazySingleton<FriendsApiDatasource>(
      () => FriendsApiDatasource(apiService: serviceLocator<ApiService>()));
  serviceLocator.registerLazySingleton<IFriendsRepository>(() =>
      FriendsRemoteRepository(
          friendsDataSource: serviceLocator<FriendsApiDatasource>(),
          apiService: serviceLocator<ApiService>()));
  serviceLocator.registerLazySingleton<FollowUserUseCase>(() =>
      FollowUserUseCase(repository: serviceLocator<IFriendsRepository>()));
  serviceLocator.registerLazySingleton<UnfollowUserUseCase>(() =>
      UnfollowUserUseCase(repository: serviceLocator<IFriendsRepository>()));
  serviceLocator.registerLazySingleton<GetFollowersUseCase>(() =>
      GetFollowersUseCase(repository: serviceLocator<IFriendsRepository>()));
  serviceLocator.registerLazySingleton<GetFollowingUseCase>(() =>
      GetFollowingUseCase(repository: serviceLocator<IFriendsRepository>()));
  serviceLocator.registerFactory<FollowViewModel>(() => FollowViewModel(
        followUserUseCase: serviceLocator<FollowUserUseCase>(),
        unfollowUserUseCase: serviceLocator<UnfollowUserUseCase>(),
        getFollowersUseCase: serviceLocator<GetFollowersUseCase>(),
        getFollowingUseCase: serviceLocator<GetFollowingUseCase>(),
      ));
}

// Updated _initMessageModule function for your service locator

Future<void> _initMessageModule() async {
  // Register Connectivity (if not already registered in core services)
  if (!serviceLocator.isRegistered<Connectivity>()) {
    serviceLocator.registerLazySingleton(() => Connectivity());
  }

  // Register Remote Data Source
  serviceLocator.registerLazySingleton<IMessageDataSource>(
    () => MessageApiDataSource(apiService: serviceLocator<ApiService>()),
  );

  // Register Local Data Source
  serviceLocator.registerLazySingleton<IMessageLocalDataSource>(
    () => MessageHiveDatasourceImpl(hiveService: serviceLocator<HiveService>()),
  );

  // Register the Hybrid Repository (MessageRepositoryImpl)
  serviceLocator.registerLazySingleton<IMessageRepository>(
    () => MessageRepositoryImpl(
      remoteDataSource: serviceLocator<IMessageDataSource>(),
      localDataSource: serviceLocator<IMessageLocalDataSource>(),
      connectivity: serviceLocator<Connectivity>(),
    ),
  );

  // Register Use Cases
  serviceLocator.registerLazySingleton<GetInboxUseCase>(
    () => GetInboxUseCase(repository: serviceLocator<IMessageRepository>()),
  );
  serviceLocator.registerLazySingleton<MarkMessagesAsReadUseCase>(
    () => MarkMessagesAsReadUseCase(
        repository: serviceLocator<IMessageRepository>()),
  );
  serviceLocator.registerLazySingleton<GetMessagesBetweenUsersUseCase>(
    () => GetMessagesBetweenUsersUseCase(
        repository: serviceLocator<IMessageRepository>()),
  );
  serviceLocator.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(repository: serviceLocator<IMessageRepository>()),
  );
  serviceLocator.registerLazySingleton<DeleteMessageUseCase>(
    () =>
        DeleteMessageUseCase(repository: serviceLocator<IMessageRepository>()),
  );

  // Register ViewModels
  serviceLocator.registerFactory<InboxViewModel>(
    () => InboxViewModel(
      serviceLocator<GetInboxUseCase>(),
      serviceLocator<MarkMessagesAsReadUseCase>(),
    ),
  );
  serviceLocator.registerFactory<MessageViewModel>(
    () => MessageViewModel(
      getMessagesBetweenUsersUseCase:
          serviceLocator<GetMessagesBetweenUsersUseCase>(),
      sendMessageUseCase: serviceLocator<SendMessageUseCase>(),
      deleteMessageUseCase: serviceLocator<DeleteMessageUseCase>(),
    ),
  );

  print("✅ Message Module with Offline Support Initialized Successfully.");
}

Future<void> _initNotificationModule() async {
  serviceLocator.registerLazySingleton<INotificationDataSource>(
    () =>
        NotificationRemoteDataSource(apiService: serviceLocator<ApiService>()),
  );
  serviceLocator.registerLazySingleton<INotificationRepository>(
    () => NotificationRemoteRepository(
      dataSource: serviceLocator<INotificationDataSource>(),
    ),
  );
  serviceLocator.registerLazySingleton<GetNotificationsByUserIdUsecase>(
    () => GetNotificationsByUserIdUsecase(
      notificationRepository: serviceLocator<INotificationRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<CreateNotificationUsecase>(
    () => CreateNotificationUsecase(
      notificationRepository: serviceLocator<INotificationRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<MarkNotificationAsReadUsecase>(
    () => MarkNotificationAsReadUsecase(
      notificationRepository: serviceLocator<INotificationRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<DeleteNotificationUsecase>(
    () => DeleteNotificationUsecase(
      notificationRepository: serviceLocator<INotificationRepository>(),
    ),
  );
  serviceLocator.registerFactory<NotificationViewModel>(
    () => NotificationViewModel(
      deleteNotificationUsecase: serviceLocator<DeleteNotificationUsecase>(),
      getNotificationsUsecase:
          serviceLocator<GetNotificationsByUserIdUsecase>(),
      markAsReadUsecase: serviceLocator<MarkNotificationAsReadUsecase>(),
    ),
  );
}
