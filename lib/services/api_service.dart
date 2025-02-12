import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String serverBaseUrl = ApiService().serverBaseUrl;

  // Register User
  Future<dynamic> registerUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$serverBaseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
    return jsonDecode(response.body);
  }

  // Login User
  Future<dynamic> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$serverBaseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // Get All User Locations
  Future<dynamic> getAllUserLocations() async {
    final response = await http.get(Uri.parse('$serverBaseUrl/GetAllUserLocations'));
    return jsonDecode(response.body);
  }

  // Get User Location by ID
  Future<dynamic> getUserLocationById(int id) async {
    final response = await http.get(Uri.parse('$serverBaseUrl/GetUserLocation?id=$id'));
    return jsonDecode(response.body);
  }

  // Add User Location
  Future<dynamic> addUserLocation(Map<String, dynamic> locationData) async {
    final response = await http.post(
      Uri.parse('$serverBaseUrl/AddUserLocation'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(locationData),
    );
    return jsonDecode(response.body);
  }

  // Update User Location
  Future<dynamic> updateUserLocation(int id, Map<String, dynamic> locationData) async {
    final response = await http.put(
      Uri.parse('$serverBaseUrl/UpdateUserLocation?id=$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(locationData),
    );
    return jsonDecode(response.body);
  }

  // Delete User Location
  Future<dynamic> deleteUserLocation(int id) async {
    final response = await http.delete(Uri.parse('$serverBaseUrl/$id'));
    return jsonDecode(response.body);
  }
}