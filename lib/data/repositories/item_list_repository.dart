import 'dart:convert';
import 'package:gis_osm/data/models/item_list.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class AuthRepository {
  final String baseUrl = '${ApiConfig.serverBaseUrl}';

  Future<List<ItemList>> getItemList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/itemlist'));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody.containsKey('itemlist') &&
            responseBody['itemlist'] is List) {
          final data = responseBody['itemlist'] as List;
          return data.map((e) => ItemList.fromJson(e)).toList();
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception('Failed to load ItemList: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching uItemList: $e');
    }
  }
}
