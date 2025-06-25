import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';

part 'user_api_model.g.dart';

@JsonSerializable()
class UserApiModel extends Equatable {
  @JsonKey(name: '_id')
  final String? userId;
  final String email;
  final String username;

   @JsonKey(name: 'StudentId')
  final int studentId;

  final String password;
  final String? profilePhoto;
  final String? bio;
  final String role;

  UserApiModel(
      { this.userId,
      required this.email,
      required this.username,
      required this.studentId,
      required this.password,
       this.profilePhoto,
       this.bio,
      required this.role});

  // JSON serialization
  factory UserApiModel.fromJson(Map<String, dynamic> json) =>
      _$UserApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserApiModelToJson(this);

  // To Entity
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      email: email,
      username: username,
      studentId: studentId,
      password: password,
      profilePhoto: profilePhoto ?? '',
      bio: bio ?? '',
      role: role ?? 'normal',
    );
  }

  // From Entity
  factory UserApiModel.fromEntity(UserEntity entity) {
    return UserApiModel(
      userId: entity.userId,
      email: entity.email,
      username: entity.username,
      studentId: entity.studentId,
      password: entity.password,
      profilePhoto: entity.profilePhoto,
      bio: entity.bio,
      role: entity.role,
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
      ];
}
