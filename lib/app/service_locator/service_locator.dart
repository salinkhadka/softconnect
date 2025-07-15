import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/core/network/hive_service.dart';

// Auth imports
import 'package:softconnect/features/auth/data/data_source/local_datasource/user_hive_data_source.dart';
import 'package:softconnect/features/auth/data/data_source/remote_dataSource/user_remote_data_source.dart';
import 'package:softconnect/features/auth/data/data_source/user_data_source.dart';
import 'package:softconnect/features/auth/data/repository/local_repository/user_local_repository.dart';
import 'package:softconnect/features/auth/data/repository/remote_repository/user_remote_repository.dart';
import 'package:softconnect/features/auth/domain/repository/user_repository.dart';
import 'package:softconnect/features/auth/domain/use_case/user_login_usecase.dart';
import 'package:softconnect/features/auth/domain/use_case/user_register_usecase.dart';
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_viewmodel.dart';

// Home imports
import 'package:softconnect/features/home/presentation/view_model/homepage_viewmodel.dart';

// Splash imports
import 'package:softconnect/features/splash/presentation/view_model/splash_viewmodel.dart';

// Friends imports
import 'package:softconnect/features/friends/data/data_source/remote_dataSource/friends_api_datasource.dart';
import 'package:softconnect/features/friends/data/repository/remote_repository/friends_remote_repository.dart';
import 'package:softconnect/features/friends/domain/repository/friends_repository.dart';

import 'package:softconnect/features/friends/domain/use_case/follow_user_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/unfollow_user_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/get_followers_usecase.dart';
import 'package:softconnect/features/friends/domain/use_case/get_following_usecase.dart';
import 'package:softconnect/features/friends/presentation/view_model/follow_viewmodel.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  await _initHiveService();
  await _initApiService();
  await _initSplashModule();
  await _initAuthModule();
  await _initHomeModule();
  await _initFriendsModule();
}

Future<void> _initHiveService() async {
  serviceLocator.registerLazySingleton(() => HiveService());
}

Future<void> _initApiService() async {
  serviceLocator.registerLazySingleton<Dio>(() => Dio());
  serviceLocator.registerLazySingleton(() => ApiService(serviceLocator<Dio>()));
}

Future<void> _initAuthModule() async {
  // Local data source
  serviceLocator.registerLazySingleton<IUserDataSource>(
    () => UserHiveDataSource(hiveService: serviceLocator<HiveService>()),
    instanceName: 'localDataSource',
  );

  // Remote data source
  serviceLocator.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(apiService: serviceLocator<ApiService>()),
  );

  // Remote user repository
  serviceLocator.registerLazySingleton<IUserRepository>(
    () => UserRemoteRepository(
      remoteDataSource: serviceLocator<UserRemoteDataSource>(),
    ),
  );

  // Use cases
  serviceLocator.registerLazySingleton<UserLoginUsecase>(
    () => UserLoginUsecase(userRepository: serviceLocator<IUserRepository>()),
  );

  serviceLocator.registerLazySingleton<UserRegisterUsecase>(
    () => UserRegisterUsecase(userRepository: serviceLocator<IUserRepository>()),
  );

  // ViewModels
  serviceLocator.registerFactory<LoginViewModel>(
    () => LoginViewModel(userLoginUsecase: serviceLocator<UserLoginUsecase>()),
  );

  serviceLocator.registerFactory<SignupViewModel>(
    () => SignupViewModel(userRegisterUsecase: serviceLocator<UserRegisterUsecase>()),
  );
}

Future<void> _initSplashModule() async {
  serviceLocator.registerFactory(() => SplashViewModel());
}

Future<void> _initHomeModule() async {
  serviceLocator.registerFactory(() => HomeViewModel());
}

Future<void> _initFriendsModule() async {
  // Register FriendsApiDatasource with ApiService injected
  serviceLocator.registerLazySingleton<FriendsApiDatasource>(
    () => FriendsApiDatasource(apiService: serviceLocator<ApiService>()),
  );

  // Register FriendsRemoteRepository with FriendsApiDatasource injected
  serviceLocator.registerLazySingleton<IFriendsRepository>(
    () => FriendsRemoteRepository(
      friendsDataSource: serviceLocator<FriendsApiDatasource>(),
      apiService: serviceLocator<ApiService>(),
    ),
  );

  // Register use cases with the repository injected
  serviceLocator.registerLazySingleton<FollowUserUseCase>(
    () => FollowUserUseCase(repository: serviceLocator<IFriendsRepository>()),
  );
  serviceLocator.registerLazySingleton<UnfollowUserUseCase>(
    () => UnfollowUserUseCase(repository: serviceLocator<IFriendsRepository>()),
  );
  serviceLocator.registerLazySingleton<GetFollowersUseCase>(
    () => GetFollowersUseCase(repository: serviceLocator<IFriendsRepository>()),
  );
  serviceLocator.registerLazySingleton<GetFollowingUseCase>(
    () => GetFollowingUseCase(repository: serviceLocator<IFriendsRepository>()),
  );

  // Register FollowViewModel with injected use cases
  serviceLocator.registerFactory<FollowViewModel>(
    () => FollowViewModel(
      followUserUseCase: serviceLocator<FollowUserUseCase>(),
      unfollowUserUseCase: serviceLocator<UnfollowUserUseCase>(),
      getFollowersUseCase: serviceLocator<GetFollowersUseCase>(),
      getFollowingUseCase: serviceLocator<GetFollowingUseCase>(),
    ),
  );
}


