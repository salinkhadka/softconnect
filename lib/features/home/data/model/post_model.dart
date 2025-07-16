import 'package:json_annotation/json_annotation.dart';
import 'package:softconnect/features/home/data/model/user_preview_model.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';

part 'post_model.g.dart';

@JsonSerializable()
class PostModel {
  @JsonKey(name: '_id')
  final String id;

  final UserPreviewModel user;

  final String content;
  final String? imageUrl;
  final String privacy;

  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  PostModel({
    required this.id,
    required this.user,
    required this.content,
    this.imageUrl,
    required this.privacy,
    this.createdAt,
    this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['userId'];
    return PostModel(
      id: json['_id'] as String? ?? '',
      user: userJson is Map<String, dynamic>
          ? UserPreviewModel.fromJson(userJson)
          : const UserPreviewModel(userId: '', username: '', profilePhoto: ''),
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      privacy: json['privacy'] as String? ?? 'public',
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  PostEntity toEntity() {
    return PostEntity(
      id: id,
      user: user.toEntity(),
      content: content,
      imageUrl: imageUrl,
      privacy: privacy,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
