import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_location.dart';

class UserLocationRepository {
  final String baseUrl = "http://localhost:5000/api/UserLocation";

  Future<List<UserLocation>> getAllUserLocations() async {
    final response = await http.get(Uri.parse('$baseUrl/GetAllUserLocations'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['Data'] as List;
      return data.map((e) => UserLocation.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch user locations: ${response.body}');
    }
  }

  Future<UserLocation> getUserLocationById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/GetUserLocation?id=$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['Data'];
      return UserLocation.fromJson(data);
    } else {
      throw Exception('Failed to fetch user location: ${response.body}');
    }
  }

  Future<UserLocation> addUserLocation(UserLocation userLocation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/AddUserLocation'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userLocation.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['Data'];
      return UserLocation.fromJson(data);
    } else {
      throw Exception('Failed to add user location: ${response.body}');
    }
  }
}
