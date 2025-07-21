// lib/features/home/data/model/post_hive_model.dart

import 'package:hive/hive.dart';
import 'package:softconnect/features/home/data/model/post_model.dart';
// import 'package:softconnect/features/home/data/model/post_remote_model.dart';
import 'package:softconnect/features/home/data/model/user_preview_hive_model.dart';
import 'package:softconnect/features/home/domain/entity/post_entity.dart';

part 'post_hive_model.g.dart';

@HiveType(typeId: 1) // Unique ID for the PostHiveModel
class PostHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final UserPreviewHiveModel user; 

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String? imageUrl;

  @HiveField(4)
  final String privacy;

  @HiveField(5)
  final DateTime? createdAt;

  @HiveField(6)
  final DateTime? updatedAt;

  PostHiveModel({
    required this.id,
    required this.user,
    required this.content,
    this.imageUrl,
    required this.privacy,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a local Hive model from a remote API model.
  factory PostHiveModel.fromRemoteModel(PostModel remoteModel) {
    return PostHiveModel(
      id: remoteModel.id,
      user: UserPreviewHiveModel.fromRemoteModel(remoteModel.user),
      content: remoteModel.content,
      imageUrl: remoteModel.imageUrl,
      privacy: remoteModel.privacy,
      createdAt: remoteModel.createdAt,
      updatedAt: remoteModel.updatedAt,
    );
  }

  /// Converts the local Hive model to a domain entity.
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