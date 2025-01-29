import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://your-backend-url/api';

  // Register a new user
  static Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  // Login an existing user
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  // Fetch all user locations
  static Future<List<dynamic>> getUserLocations() async {
    final response = await http.get(Uri.parse('$baseUrl/UserLocation'));
    return jsonDecode(response.body)['data'];
  }

  // Add a new user location
  static Future<Map<String, dynamic>> addUserLocation(Map<String, dynamic> location) async {
    final response = await http.post(
      Uri.parse('$baseUrl/UserLocation'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(location),
    );

    return jsonDecode(response.body);
  }

  // Update an existing user location
  static Future<Map<String, dynamic>> updateUserLocation(int id, Map<String, dynamic> location) async {
    final response = await http.put(
      Uri.parse('$baseUrl/UserLocation/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(location),
    );

    return jsonDecode(response.body);
  }

  // Delete a user location
  static Future<Map<String, dynamic>> deleteUserLocation(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/UserLocation/$id'));
    return jsonDecode(response.body);
  }
}