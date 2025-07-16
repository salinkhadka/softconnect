import 'package:equatable/equatable.dart';

class LikeEntity extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LikeEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, postId, userId, createdAt, updatedAt];
}
