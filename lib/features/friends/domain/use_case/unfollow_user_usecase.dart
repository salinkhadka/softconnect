import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/friends/domain/repository/friends_repository.dart';

class UnfollowUserParams extends Equatable {
  final String followeeId;

  const UnfollowUserParams(this.followeeId);

  @override
  List<Object?> get props => [followeeId];
}

class UnfollowUserUseCase implements UsecaseWithParams<void, UnfollowUserParams> {
  final IFriendsRepository repository;

  UnfollowUserUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(UnfollowUserParams params) {
    return repository.unfollowUser(params.followeeId);
  }
}
