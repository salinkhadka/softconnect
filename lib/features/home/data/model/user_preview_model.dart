// lib/features/home/data/model/user_preview_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:softconnect/features/home/domain/entity/user_preview_entity.dart';

part 'user_preview_model.g.dart';

@JsonSerializable()
class UserPreviewModel {
  @JsonKey(name: '_id', defaultValue: '')
  final String userId;

  @JsonKey(defaultValue: '')
  final String username;

  @JsonKey(defaultValue: '')
  final String? profilePhoto;

  const UserPreviewModel({
    required this.userId,
    required this.username,
    this.profilePhoto,
  });

  factory UserPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$UserPreviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreviewModelToJson(this);

  /// Convert model to domain entity
  UserPreviewEntity toEntity() => UserPreviewEntity(
        userId: userId,
        username: username,
        profilePhoto: profilePhoto,
      );

  /// Create model from domain entity
  factory UserPreviewModel.fromEntity(UserPreviewEntity entity) {
    return UserPreviewModel(
      userId: entity.userId,
      username: entity.username,
      profilePhoto: entity.profilePhoto,
    );
  }
}
