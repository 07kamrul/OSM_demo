import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../models/user.dart';

class AuthRepository {
  final String baseUrl = ApiConfig.baseUrl + '/auth';

  Future<Map<String, dynamic>> register(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['Message'] ?? 'Failed to register user');
      }
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/login')
          .replace(queryParameters: {'email': email, 'password': password});

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return the parsed JSON response
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }
}
