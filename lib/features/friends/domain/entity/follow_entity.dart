import 'package:equatable/equatable.dart';

class FollowEntity extends Equatable {
  final String? id;
  final String followerId;
  final String followeeId;
  final String? username;        // 🔁 Generic for both follower/followee
  final String? profilePhoto;    // 🔁 Generic for both follower/followee
  final DateTime createdAt;
  final DateTime updatedAt;

  const FollowEntity({
    this.id,
    required this.followerId,
    required this.followeeId,
    this.username,
    this.profilePhoto,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props =>
      [id, followerId, followeeId, username, profilePhoto, createdAt, updatedAt];
}
