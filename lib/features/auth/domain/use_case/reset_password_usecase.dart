import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/auth/domain/repository/user_repository.dart';

class ResetPasswordParams extends Equatable {
  final String token;
  final String newPassword;

  const ResetPasswordParams({
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [token, newPassword];
}

class ResetPasswordUsecase implements UsecaseWithParams<void, ResetPasswordParams> {
  final IUserRepository _userRepository;

  ResetPasswordUsecase({required IUserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return _userRepository.resetPassword(params.token, params.newPassword);
  }
}
