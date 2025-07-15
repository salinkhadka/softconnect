// data/model/follow_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:softconnect/features/friends/domain/entity/follow_entity.dart';

part 'follow_model.g.dart';

@JsonSerializable()
class FollowModel {
  @JsonKey(name: '_id')
  final String? id;

  final String follower;
  final String followee;

  final DateTime createdAt;
  final DateTime updatedAt;

  FollowModel({
    this.id,
    required this.follower,
    required this.followee,
    required this.createdAt,
    required this.updatedAt,
  });

  /// From JSON
  factory FollowModel.fromJson(Map<String, dynamic> json) =>
      _$FollowModelFromJson(json);

  /// To JSON
  Map<String, dynamic> toJson() => _$FollowModelToJson(this);

  /// Convert to Entity
  FollowEntity toEntity() {
    return FollowEntity(
      id: id,
      followerId: follower,
      followeeId: followee,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert from Entity
  factory FollowModel.fromEntity(FollowEntity entity) {
    return FollowModel(
      id: entity.id,
      follower: entity.followerId,
      followee: entity.followeeId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
