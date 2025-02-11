import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_location.dart';

class UserLocationRepository {
  final String baseUrl = 'http://192.168.0.150:5143/api/UserLocation';

  Future<List<UserLocation>> getAllUserLocations() async {
    final response = await http.get(Uri.parse('$baseUrl/GetAllUserLocations'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((e) => UserLocation.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load user locations');
    }
  }

  Future<UserLocation> getUserLocationById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/GetUserLocation?id=$id'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return UserLocation.fromJson(data);
    } else {
      throw Exception('User location not found');
    }
  }

  Future<void> addUserLocation(UserLocation userLocation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/AddUserLocation'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userLocation.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add user location');
    }
  }

  Future<void> updateUserLocation(UserLocation userLocation) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/UpdateUserLocation'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userLocation.toJson()),
      );

      if (response.statusCode == 200) {
        print('User location updated successfully.');
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Failed to update user location: $errorMessage');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUserLocation(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user location');
    }
  }
}