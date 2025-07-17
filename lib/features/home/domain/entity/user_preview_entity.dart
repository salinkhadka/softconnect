import 'package:equatable/equatable.dart';

class UserPreviewEntity extends Equatable {
  final String userId;
  final String username;
  final String? profilePhoto;

  const UserPreviewEntity({
    required this.userId,
    required this.username,
    this.profilePhoto,
  });

  @override
  List<Object?> get props => [userId, username, profilePhoto];
}
