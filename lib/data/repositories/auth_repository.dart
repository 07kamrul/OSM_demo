import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../models/user.dart';

class AuthRepository {
  final String baseUrl = ApiConfig.baseUrl + '/auth';

  Future<Map<String, dynamic>> register(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register user');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/login')
        .replace(queryParameters: {'email': email, 'password': password});

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Invalid credentials');
    }
  }
}
