import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/auth/domain/repository/user_repository.dart';

class RequestPasswordResetParams extends Equatable {
  final String email;

  const RequestPasswordResetParams({required this.email});

  @override
  List<Object?> get props => [email];
}

class RequestPasswordResetUsecase
    implements UsecaseWithParams<void, RequestPasswordResetParams> {
  final IUserRepository _userRepository;

  RequestPasswordResetUsecase({required IUserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Either<Failure, void>> call(RequestPasswordResetParams params) {
    return _userRepository.requestPasswordReset(params.email);
  }
}
