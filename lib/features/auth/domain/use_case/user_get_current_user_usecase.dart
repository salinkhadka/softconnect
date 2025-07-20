import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';
import 'package:softconnect/features/auth/domain/repository/user_repository.dart';
import 'package:softconnect/app/use_case/use_case.dart';

class GetUserByIdParams extends Equatable {
  final String userId;

  const GetUserByIdParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetUserByIdUsecase implements UsecaseWithParams<UserEntity, GetUserByIdParams> {
  final IUserRepository _userRepository;

  GetUserByIdUsecase({required IUserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Either<Failure, UserEntity>> call(GetUserByIdParams params) async {
    return await _userRepository.getCurrentUser(params.userId);
  }
}
