import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';
import 'package:softconnect/features/auth/domain/repository/user_repository.dart';
import 'package:softconnect/app/use_case/use_case.dart';

class SearchUsersParams extends Equatable {
  final String query;

  const SearchUsersParams({required this.query});

  @override
  List<Object?> get props => [query];
}

class SearchUsersUsecase implements UsecaseWithParams<List<UserEntity>, SearchUsersParams> {
  final IUserRepository _userRepository;

  SearchUsersUsecase({required IUserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<Either<Failure, List<UserEntity>>> call(SearchUsersParams params) async {
    return await _userRepository.searchUsers(params.query);
  }
}
