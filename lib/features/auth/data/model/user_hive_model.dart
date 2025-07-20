import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:softconnect/app/constants/hive_table_constant.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';
import 'package:uuid/uuid.dart';

part 'user_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userId)
class UserHiveModel extends Equatable {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final int? studentId;

  @HiveField(4)
  final String password;

  @HiveField(5)
  final String? profilePhoto;

  @HiveField(6)
  final String? bio;

  @HiveField(7)
  final String role;

  UserHiveModel({
    String? userId,
    required this.email,
    required this.username,
    required this.studentId,
    required this.password,
    this.profilePhoto,
    this.bio,
    this.role = 'normal',
  }) : userId = userId ?? const Uuid().v4();

  // Initial Constructor
  const UserHiveModel.initial()
      : userId = '',
        email = '',
        username = '',
        studentId = 0,
        password = '',
        profilePhoto = '',
        bio = '',
        role = 'normal';

  // From Entity
  factory UserHiveModel.fromEntity(UserEntity entity) {
    return UserHiveModel(
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

  // To Entity
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      email: email,
      username: username,
      studentId: studentId,
      password: password,
      profilePhoto: profilePhoto,
      bio: bio,
      role: role,
    );
  }

  // Convert List of HiveModels to List of Entities
  static List<UserEntity> toEntityList(List<UserHiveModel> hiveList) {
    return hiveList.map((data) => data.toEntity()).toList();
  }

  // Convert List of Entities to List of HiveModels
  static List<UserHiveModel> fromEntityList(List<UserEntity> entityList) {
    return entityList.map((data) => UserHiveModel.fromEntity(data)).toList();
  }

  @override
  List<Object?> get props =>
      [userId, email, username, studentId, password, profilePhoto, bio, role];
}
