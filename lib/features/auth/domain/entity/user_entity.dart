import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? userId;
  final String email;
  final String username;
  final int studentId;
  final String password;
  final String? profilePhoto;
  final String? bio;
  final String role;

  const UserEntity({
    this.userId,
    required this.email,
    required this.username,
    required this.studentId,
    required this.password,
    this.profilePhoto,
    this.bio,
    this.role = 'normal',
  });

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
      ];
}
