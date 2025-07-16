import 'package:json_annotation/json_annotation.dart';
import 'package:softconnect/features/auth/data/model/user_api_model.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';
// import 'package:softconnect/features/posts/domain/entity/post_entity.dart';

part 'post_model.g.dart';

@JsonSerializable()
class PostModel {
  @JsonKey(name: '_id')
  final String id;

  final UserApiModel userId;

  final String content;
  final String? imageUrl;
  final String privacy;

  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.privacy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson(json);
  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  PostEntity toEntity() {
    return PostEntity(
      id: id,
      user: userId.toEntity(),
      content: content,
      imageUrl: imageUrl,
      privacy: privacy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
