import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/friends/domain/entity/follow_entity.dart';
import 'package:softconnect/features/friends/domain/repository/friends_repository.dart';

class GetFollowingParams extends Equatable {
  final String userId;

  const GetFollowingParams(this.userId);

  @override
  List<Object?> get props => [userId];
}

class GetFollowingUseCase implements UsecaseWithParams<List<FollowEntity>, GetFollowingParams> {
  final IFriendsRepository repository;

  GetFollowingUseCase({required this.repository});

  @override
  Future<Either<Failure, List<FollowEntity>>> call(GetFollowingParams params) {
    return repository.getFollowing(params.userId);
  }
}
