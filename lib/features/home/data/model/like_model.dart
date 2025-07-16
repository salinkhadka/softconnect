import 'package:json_annotation/json_annotation.dart';
import 'package:softconnect/features/home/domain/entity/like_entity.dart';
import 'package:softconnect/features/home/data/model/user_preview_model.dart';

part 'like_model.g.dart';

@JsonSerializable()
class LikeModel {
  @JsonKey(name: '_id')
  final String id;

  @JsonKey(name: 'postId')
  final String postId;

  @JsonKey(name: 'userId')
  final UserPreviewModel user; // Nested user object like in PostModel

  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  LikeModel({
    required this.id,
    required this.postId,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) =>
      _$LikeModelFromJson(json);

  Map<String, dynamic> toJson() => _$LikeModelToJson(this);

  LikeEntity toEntity() {
    return LikeEntity(
      id: id,
      postId: postId,
      userId: user.userId, // Extract nested user ID
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
