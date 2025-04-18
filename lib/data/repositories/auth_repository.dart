import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../models/user.dart';

class AuthRepository {
  final String baseUrl = '${ApiConfig.serverBaseUrl}';

  Future<Map<String, dynamic>> register(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 422) {
        // Handle the 422 error case
        final errorResponse = jsonDecode(response.body);
        throw Exception(
            'Validation Error: ${errorResponse['message'] ?? 'Unprocessable Entity'}');
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to register user');
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
        final decodedResponse = jsonDecode(response.body);

        if (decodedResponse is Map<String, dynamic>) {
          return decodedResponse;
        } else {
          throw Exception("Unexpected response format from server.");
        }
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody.containsKey('users') &&
            responseBody['users'] is List) {
          final data = responseBody['users'] as List;
          return data.map((e) => User.fromJson(e)).toList();
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception(
            'Failed to load user locations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user locations: $e');
    }
  }

  Future<User> getUser(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/$userId'));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody.containsKey('user') && responseBody['user'] is Map) {
          final userData = responseBody['user'] as Map<String, dynamic>;

          return User.fromJson(userData);
        } else {
          throw Exception(
              'Invalid API response format: Expected "user" key with a map value');
        }
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  Future<User> updateUser(User user) async {
    try {
      final url = Uri.parse('$baseUrl/UpdateUser/${user.id}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody.containsKey('data') &&
            responseBody['data'] is Map<String, dynamic>) {
          final abc = User.fromJson(responseBody['data']);
          return abc;
        } else {
          throw Exception(
              'Invalid API response: Missing or invalid "data" field');
        }
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  Future<void> changePassword(
      int userId, String currentPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/changePassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to change password: ${response.statusCode}');
      }

      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] != true) {
        throw Exception(responseBody['message'] ?? 'Password change failed');
      }
    } catch (e) {
      throw Exception('Error changing password: $e');
    }
  }
}
