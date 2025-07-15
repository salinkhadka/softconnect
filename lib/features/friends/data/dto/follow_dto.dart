// data/dto/follow_dto.dart

import 'package:json_annotation/json_annotation.dart';

part 'follow_dto.g.dart';

@JsonSerializable()
class FolloweeDto {
  @JsonKey(name: '_id')
  final String id;
  final String username;
  final String? profilePhoto;

  FolloweeDto({
    required this.id,
    required this.username,
    this.profilePhoto,
  });

  factory FolloweeDto.fromJson(Map<String, dynamic> json) => _$FolloweeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FolloweeDtoToJson(this);
}

@JsonSerializable()
class FollowDto {
  @JsonKey(name: '_id')
  final String? id;

  final String follower;
  final FolloweeDto followee;

  final DateTime createdAt;
  final DateTime updatedAt;

  FollowDto({
    this.id,
    required this.follower,
    required this.followee,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FollowDto.fromJson(Map<String, dynamic> json) => _$FollowDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FollowDtoToJson(this);
}
