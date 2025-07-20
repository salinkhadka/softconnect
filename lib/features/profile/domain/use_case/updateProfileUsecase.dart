import 'package:dartz/dartz.dart';
import 'package:softconnect/app/use_case/use_case.dart';
import 'package:softconnect/core/error/failure.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';
import 'package:softconnect/features/profile/domain/repository/profile_repository.dart';

/// ──────────────────────── Update User Profile ────────────────────────
class UpdateUserProfileParams {
  final String userId;
  final String username;
  final String email;
  final String? bio;
  final String? profilePhoto; // <-- Add this field

  UpdateUserProfileParams({
    required this.userId,
    required this.username,
    required this.email,
    this.bio,
    this.profilePhoto,
  });
}


class UpdateUserProfileUsecase
    implements UsecaseWithParams<UserEntity, UpdateUserProfileParams> {
  final IProfileRepository _profileRepository;

  UpdateUserProfileUsecase(this._profileRepository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateUserProfileParams params) {
    return _profileRepository.updateUserProfile(
      userId: params.userId,
      username: params.username,
      email: params.email,
      bio: params.bio,
      profilePhoto: params.profilePhoto
    );
  }
}
