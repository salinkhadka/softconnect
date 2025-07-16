import 'package:json_annotation/json_annotation.dart';
import 'package:softconnect/features/friends/domain/entity/follow_entity.dart';

part 'follow_model.g.dart';

@JsonSerializable()
class FollowUserModel {
  @JsonKey(name: '_id')
  final String id;
  final String username;
  final String? profilePhoto;

  FollowUserModel({
    required this.id,
    required this.username,
    this.profilePhoto,
  });

  factory FollowUserModel.fromJson(Map<String, dynamic> json) =>
      _$FollowUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$FollowUserModelToJson(this);
}

@JsonSerializable()
class FollowModel {
  @JsonKey(name: '_id')
  final String? id;

  /// Can be either a string or an object in the response
  final dynamic follower;
  final dynamic followee;

  final DateTime createdAt;
  final DateTime updatedAt;

  FollowModel({
    this.id,
    required this.follower,
    required this.followee,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FollowModel.fromJson(Map<String, dynamic> json) =>
      _$FollowModelFromJson(json);

  Map<String, dynamic> toJson() => _$FollowModelToJson(this);

  FollowEntity toEntity() {
    final followerObj = follower is Map<String, dynamic>
        ? FollowUserModel.fromJson(follower as Map<String, dynamic>)
        : null;

    final followeeObj = followee is Map<String, dynamic>
        ? FollowUserModel.fromJson(followee as Map<String, dynamic>)
        : null;

    final isFollowersList = followee is String;

    final targetUser = isFollowersList ? followerObj : followeeObj;

    return FollowEntity(
      id: id,
      followerId: followerObj?.id ?? (follower is String ? follower : ''),
      followeeId: followeeObj?.id ?? (followee is String ? followee : ''),
      username: targetUser?.username,
      profilePhoto: targetUser?.profilePhoto,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory FollowModel.fromEntity(FollowEntity entity) {
    return FollowModel(
      id: entity.id,
      follower: {
        '_id': entity.followerId,
        'username': entity.username ?? '',
        'profilePhoto': entity.profilePhoto,
      },
      followee: entity.followeeId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
