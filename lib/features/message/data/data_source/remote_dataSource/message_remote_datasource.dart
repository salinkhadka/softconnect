import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/features/message/data/data_source/message_datsource.dart';
import 'package:softconnect/features/message/data/model/message_model.dart';

class MessageApiDataSource implements IMessageDataSource {
  final ApiService _apiService;

  MessageApiDataSource({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<List<MessageInboxModel>> getInboxConversations(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await _apiService.dio.get(
        ApiEndpoints.getConversationUsers(userId),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      final conversations = response.data['conversations'] as List;
      return conversations.map((json) => MessageInboxModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching inbox: $e');
    }
  }
}
