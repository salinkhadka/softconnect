import 'package:json_annotation/json_annotation.dart';
import 'package:softconnect/features/auth/domain/entity/user_entity.dart';

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

  UserEntity toEntity() => UserEntity(
        userId: userId,
        username: username,
        profilePhoto: profilePhoto,
        email: '',
        password: '',
        studentId: 0,
        bio: '',
        role: 'normal',
      );
}
