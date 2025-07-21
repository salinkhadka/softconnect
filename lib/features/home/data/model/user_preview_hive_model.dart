// lib/features/home/data/model/user_preview_hive_model.dart

import 'package:hive/hive.dart';
import 'package:softconnect/features/home/data/model/user_preview_model.dart';
import 'package:softconnect/features/home/domain/entity/user_preview_entity.dart';

part 'user_preview_hive_model.g.dart';

@HiveType(typeId: 2) // Unique ID for the UserPreviewHiveModel
class UserPreviewHiveModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String? profilePhoto;

  UserPreviewHiveModel({
    required this.userId,
    required this.username,
    this.profilePhoto,
  });

  /// Creates a local Hive model from a remote API model.
  factory UserPreviewHiveModel.fromRemoteModel(UserPreviewModel remoteModel) {
    return UserPreviewHiveModel(
      userId: remoteModel.userId,
      username: remoteModel.username,
      profilePhoto: remoteModel.profilePhoto,
    );
  }

  /// Converts the local Hive model to a domain entity.
  UserPreviewEntity toEntity() {
    return UserPreviewEntity(
      userId: userId,
      username: username,
      profilePhoto: profilePhoto,
    );
  }
}