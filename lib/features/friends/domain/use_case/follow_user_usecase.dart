import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/friends/domain/entity/follow_entity.dart';
import 'package:softconnect/features/friends/domain/repository/friends_repository.dart';

class FollowUserParams extends Equatable {
  final String followeeId;

  const FollowUserParams(this.followeeId);

  @override
  List<Object?> get props => [followeeId];
}

class FollowUserUseCase implements UsecaseWithParams<FollowEntity, FollowUserParams> {
  final IFriendsRepository repository;

  FollowUserUseCase({required this.repository});

  @override
  Future<Either<Failure, FollowEntity>> call(FollowUserParams params) {
    return repository.followUser(params.followeeId);
  }
}
