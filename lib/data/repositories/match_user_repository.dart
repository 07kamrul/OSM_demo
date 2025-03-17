import 'dart:convert';
import 'package:gis_osm/data/models/match_users.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class MatchUsersRepository {
  final String baseUrl = '${ApiConfig.serverBaseUrl}';

  Future<List<MatchUsers>> getMatchUsers(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/matchusers/$userId'));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody.containsKey('data') && responseBody['data'] is List) {
          final data = responseBody['data'] as List;
          return data.map((e) => MatchUsers.fromJson(e)).toList();
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
}
