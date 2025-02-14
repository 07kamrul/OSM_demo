import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../models/user_location.dart';

class UserLocationRepository {
  final String baseUrl = '${ApiConfig.serverBaseUrl}';

  Future<List<UserLocation>> getAllUserLocations() async {
    final response = await http.get(Uri.parse('$baseUrl/GetAllUserLocations'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((e) => UserLocation.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load user locations');
    }
  }

  Future<UserLocation> getUserLocationByUserId(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/GetUserLocationByUserId/$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return UserLocation.fromJson(data);
    } else {
      throw Exception('User location not found');
    }
  }

  Future<void> updateUserLocation(UserLocation userLocation) async {
    try {
      final int? userId = userLocation.userid; // Use nullable type to handle missing values
      if (userId == null) {
        throw Exception('User ID is missing in the UserLocation object.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/UpdateUserLocation/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userLocation.toJson()),
      );

      if (response.statusCode == 200) {
        print('User location updated successfully.');
      } else {
        // Decode the error response body
        final errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Unknown error'; // Provide a default message

        // Throw an exception with the error details
        throw Exception('Failed to update user location: $errorMessage');
      }
    } catch (e) {
      // Rethrow the exception to propagate it to the caller
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