import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softconnect/core/network/api_service.dart';
import 'package:softconnect/app/constants/api_endpoints.dart';
import 'package:softconnect/features/message/data/data_source/message_datsource.dart';
import 'package:softconnect/features/message/data/model/message_model.dart';
import 'package:softconnect/features/message/data/model/message_inbox_model.dart';

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

  @override
  Future<List<MessageModel>> getMessagesBetweenUsers(String senderId, String receiverId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await _apiService.dio.get(
        ApiEndpoints.getMessages(senderId, receiverId),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      final messages = response.data as List;
      return messages.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  @override
  Future<MessageModel> sendMessage(String senderId, String recipientId, String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await _apiService.dio.post(
        ApiEndpoints.sendMessage,
        data: {
          "sender": senderId,
          "recipient": recipientId,
          "content": content,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      return MessageModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      await _apiService.dio.delete(
        ApiEndpoints.deleteMessage(messageId),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }
   @override
  Future<void> markMessagesAsRead(String otherUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      await _apiService.dio.put(
        ApiEndpoints.markMessagesAsRead,  // no URL params
        data: {
          'otherUserId': otherUserId, // send in body
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
    } catch (e) {
      throw Exception('Error marking messages as read: $e');
    }
  }
}
