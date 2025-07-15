import 'package:softconnect/features/friends/data/model/follow_model.dart';

class FollowResponse {
  final bool success;
  final String message;
  final FollowModel? data;

  FollowResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory FollowResponse.fromJson(Map<String, dynamic> json) {
    return FollowResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? FollowModel.fromJson(json['data']) : null,
    );
  }
}
