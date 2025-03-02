import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../models/message.dart';

class MessageRepository {
  final String baseUrl = '${ApiConfig.serverBaseUrl}';

  // Send a message
  Future<Message> sendMessage(int senderId, int receiverId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
      }),
    );
    if (response.statusCode == 201) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send message');
    }
  }

  // Fetch messages between two users
  Future<List<Message>> getMessages(int senderId, int receiverId) async {
    final response = await http.get(Uri.parse('$baseUrl/messages/$senderId/$receiverId'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }
}