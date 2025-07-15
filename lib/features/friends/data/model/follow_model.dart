import 'package:json_annotation/json_annotation.dart';
import 'package:softconnect/features/friends/domain/entity/follow_entity.dart';

part 'follow_model.g.dart';

@JsonSerializable()
class FolloweeModel {
  @JsonKey(name: '_id')
  final String id;
  final String username;
  final String? profilePhoto;

  FolloweeModel({
    required this.id,
    required this.username,
    this.profilePhoto,
  });

  factory FolloweeModel.fromJson(Map<String, dynamic> json) =>
      _$FolloweeModelFromJson(json);

  Map<String, dynamic> toJson() => _$FolloweeModelToJson(this);
}

@JsonSerializable()
class FollowModel {
  @JsonKey(name: '_id')
  final String? id;

  final String follower; // Assuming follower is still string ID
  final FolloweeModel followee;

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
    return FollowEntity(
      id: id,
      followerId: follower,
      followeeId: followee.id, // only keep id for entity
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory FollowModel.fromEntity(FollowEntity entity) {
    // Since entity only has followeeId, cannot construct full FolloweeModel here
    return FollowModel(
      id: entity.id,
      follower: entity.followerId,
      followee: FolloweeModel(id: entity.followeeId, username: '', profilePhoto: null),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
