import 'package:get_it/get_it.dart';
import 'package:softconnect/core/network/hive_service.dart';
import 'package:softconnect/features/auth/data/data_source/local_datasource/user_hive_data_source.dart';
import 'package:softconnect/features/auth/data/data_source/user_data_source.dart';
import 'package:softconnect/features/auth/data/repository/local_repository/user_local_repository.dart';
import 'package:softconnect/features/auth/domain/repository/user_repository.dart';
import 'package:softconnect/features/auth/domain/use_case/user_login_usecase.dart';
import 'package:softconnect/features/auth/domain/use_case/user_register_usecase.dart';  // import register use case
import 'package:softconnect/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';
import 'package:softconnect/features/auth/presentation/view_model/signup_viewmodel/signup_viewmodel.dart'; // import signup VM

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  await _initHiveService();

  await _initAuthModule();
}

Future<void> _initHiveService() async {
  serviceLocator.registerLazySingleton(() => HiveService());
}

Future<void> _initAuthModule() async {
  // Register data source implementation using the initialized HiveService
  serviceLocator.registerLazySingleton<IUserDataSource>(
    () => UserHiveDataSource(hiveService: serviceLocator<HiveService>()),
  );

  // Register repository implementation
  serviceLocator.registerLazySingleton<IUserRepository>(
    () => UserLocalRepository(
      dataSource: serviceLocator<IUserDataSource>(),
    ),
  );

  // Register use cases
  serviceLocator.registerLazySingleton<UserLoginUsecase>(
    () => UserLoginUsecase(
      userRepository: serviceLocator<IUserRepository>(),
    ),
  );

  serviceLocator.registerLazySingleton<UserRegisterUsecase>(
    () => UserRegisterUsecase(
      userRepository: serviceLocator<IUserRepository>(),
    ),
  );

  // Register view models
  serviceLocator.registerFactory<LoginViewModel>(
    () => LoginViewModel(
      userLoginUsecase: serviceLocator<UserLoginUsecase>(),
    ),
  );

  serviceLocator.registerFactory<SignupViewModel>(
    () => SignupViewModel(
      userRegisterUsecase: serviceLocator<UserRegisterUsecase>(),
    ),
  );
}
