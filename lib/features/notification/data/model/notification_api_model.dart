import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:softconnect/features/home/data/model/user_preview_model.dart';
import 'package:softconnect/features/notification/domain/entity/notification_entity.dart';

part 'notification_api_model.g.dart';

@JsonSerializable()
class NotificationApiModel extends Equatable {
  @JsonKey(name: '_id')
  final String id;

  final UserPreviewModel sender;

  final String recipient;
  final String type;
  final String message;
  final String? relatedId;
  final bool isRead;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  const NotificationApiModel({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.type,
    required this.message,
    this.relatedId,
    this.isRead = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// From JSON
  factory NotificationApiModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationApiModelFromJson(json);

  /// To JSON
  Map<String, dynamic> toJson() => _$NotificationApiModelToJson(this);

  /// To Domain Entity
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      sender: sender.toEntity(),
      recipient: recipient,
      type: type,
      message: message,
      relatedId: relatedId,
      isRead: isRead,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// From Domain Entity
  factory NotificationApiModel.fromEntity(NotificationEntity entity) {
    return NotificationApiModel(
      id: entity.id,
      sender: UserPreviewModel.fromEntity(entity.sender),
      recipient: entity.recipient,
      type: entity.type,
      message: entity.message,
      relatedId: entity.relatedId,
      isRead: entity.isRead,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        sender,
        recipient,
        type,
        message,
        relatedId,
        isRead,
        createdAt,
        updatedAt,
      ];
}
