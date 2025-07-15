// domain/entity/follow_entity.dart
import 'package:equatable/equatable.dart';

class FollowEntity extends Equatable {
  final String? id;
  final String followerId;
  final String followeeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FollowEntity({
    this.id,
    required this.followerId,
    required this.followeeId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, followerId, followeeId, createdAt, updatedAt];
}
