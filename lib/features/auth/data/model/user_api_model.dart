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
  final int? studentId; // Made nullable since it might not be present
  
  final String? password; // Made nullable for security and optional responses
  final String? profilePhoto;
  final String? bio;
  final String role;
  
  // Added these fields from your API response
  final int? followersCount;
  final int? followingCount;
  
  @JsonKey(name: 'createdAt')
  final String? createdAt;
  
  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  const UserApiModel({
    this.userId,
    required this.email,
    required this.username,
    this.studentId,
    this.password,
    this.profilePhoto,
    this.bio,
    this.role = 'Student', // Default to 'Student' to match your API
    this.followersCount,
    this.followingCount,
    this.createdAt,
    this.updatedAt,
  });

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
      studentId: studentId ?? 0, // Provide default value
      password: password ?? '', // Provide default value
      profilePhoto: profilePhoto,
      bio: bio,
      role: role,
      followersCount: followersCount,
      followingCount: followingCount,
    );
  }

  // From Entity
  factory UserApiModel.fromEntity(UserEntity entity) {
    return UserApiModel(
      userId: entity.userId,
      email: entity.email,
      username: entity.username,
      studentId: entity.studentId,
      password: entity.password.isNotEmpty ? entity.password : null,
      profilePhoto: entity.profilePhoto,
      bio: entity.bio,
      role: entity.role,
      followersCount: entity.followersCount,
      followingCount: entity.followingCount,
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
        createdAt,
        updatedAt,
      ];
}
