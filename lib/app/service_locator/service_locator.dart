import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/core/network/hive_service.dart';
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
import 'package:softconnect/features/home/presentation/view_model/homepage_viewmodel.dart';
import 'package:softconnect/features/splash/presentation/view_model/splash_viewmodel.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  await _initHiveService();
  await _initApiService();
  await _initSplashModule();
  await _initAuthModule();
  await _initHomeModule();
}

Future<void> _initHiveService() async {
  serviceLocator.registerLazySingleton(() => HiveService());
}

Future<void> _initApiService() async {
  serviceLocator.registerLazySingleton<Dio>(() => Dio());
  serviceLocator.registerLazySingleton(() => ApiService(serviceLocator<Dio>()));
}

Future<void> _initAuthModule() async {
  // Register local data source
  serviceLocator.registerLazySingleton<IUserDataSource>(
    () => UserHiveDataSource(hiveService: serviceLocator<HiveService>()),
    instanceName: 'localDataSource',
  );

  // Register remote data source
  serviceLocator.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(apiService: serviceLocator<ApiService>()),
  );

  // Choose either local or remote repository below:

  // Local repository (uses local data source)
  // serviceLocator.registerLazySingleton<IUserRepository>(
  //   () => UserLocalRepository(
  //     dataSource: serviceLocator<IUserDataSource>(instanceName: 'localDataSource'),
  //   ),
  // );

  // Remote repository (use this instead if you want remote server)
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
