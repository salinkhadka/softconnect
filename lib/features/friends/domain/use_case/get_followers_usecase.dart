import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/friends/domain/entity/follow_entity.dart';
import 'package:softconnect/features/friends/domain/repository/friends_repository.dart';

class GetFollowersParams extends Equatable {
  final String userId;

  const GetFollowersParams(this.userId);

  @override
  List<Object?> get props => [userId];
}

class GetFollowersUseCase implements UsecaseWithParams<List<FollowEntity>, GetFollowersParams> {
  final IFriendsRepository repository;

  GetFollowersUseCase({required this.repository});

  @override
  Future<Either<Failure, List<FollowEntity>>> call(GetFollowersParams params) {
    return repository.getFollowers(params.userId);
  }
}
