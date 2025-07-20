import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/auth/domain/repository/user_repository.dart';

class VerifyPasswordParams extends Equatable {
  final String userId;
  final String currentPassword;

  const VerifyPasswordParams({
    required this.userId,
    required this.currentPassword,
  });

  @override
  List<Object?> get props => [userId, currentPassword];
}

class VerifyPasswordUsecase
    implements UsecaseWithParams<String, VerifyPasswordParams> {
  final IUserRepository _userRepository;

  VerifyPasswordUsecase({required IUserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Either<Failure, String>> call(VerifyPasswordParams params) {
    return _userRepository.verifyPassword(params.userId, params.currentPassword);
  }
}
