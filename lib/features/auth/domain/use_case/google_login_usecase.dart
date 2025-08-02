// lib/features/auth/domain/use_case/google_login_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/auth/domain/repository/user_repository.dart';

class GoogleLoginParams extends Equatable {
  final String idToken;

  const GoogleLoginParams({required this.idToken});

  @override
  List<Object?> get props => [idToken];
}

class GoogleLoginUsecase implements UsecaseWithParams<Map<String, dynamic>, GoogleLoginParams> {
  final IUserRepository _userRepository;

  GoogleLoginUsecase({required IUserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GoogleLoginParams params) async {
    return await _userRepository.googleLogin(params.idToken);
  }
}