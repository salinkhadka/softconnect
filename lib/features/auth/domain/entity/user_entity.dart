import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? userId;
  final String email;
  final String username;
  final int? studentId; // Made nullable to handle cases where it might not be present
  final String password;
  final String? profilePhoto;
  final String? bio;
  final String role;
  final int? followersCount;
  final int? followingCount;

  const UserEntity({
    this.userId,
    required this.email,
    required this.username,
    this.studentId,
    this.password = '', // Default empty string
    this.profilePhoto,
    this.bio,
    this.role = 'Student',
    this.followersCount,
    this.followingCount,
  });

  // Copy with method for easy updates
  UserEntity copyWith({
    String? userId,
    String? email,
    String? username,
    int? studentId,
    String? password,
    String? profilePhoto,
    String? bio,
    String? role,
    int? followersCount,
    int? followingCount,
  }) {
    return UserEntity(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      username: username ?? this.username,
      studentId: studentId ?? this.studentId,
      password: password ?? this.password,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        email,
        username,
        studentId,
        password,
        profilePhoto,
        bio,
        role,
        followersCount,
        followingCount,
      ];
}