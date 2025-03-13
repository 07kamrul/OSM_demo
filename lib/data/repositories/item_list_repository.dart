import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart'; // Assuming this contains API base URL configuration
import '../models/item_list.dart';
import '../models/item_list_response.dart';

class ItemListRepository {
  // Base URL from ApiConfig (assumed to be a static class or singleton)
  final String baseUrl = ApiConfig.serverBaseUrl;

  /// Fetches the ItemListResponse from the server
  Future<ItemListResponse> getItemList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/itemlist'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if required, e.g., 'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Validate the response format
        if (responseBody is Map<String, dynamic> &&
            responseBody.containsKey('itemlist')) {
          final response = ItemListResponse.fromJson(responseBody);

          return response;
        } else {
          throw Exception(
              'Invalid API response format: Missing "itemlist" key');
        }
      } else {
        throw Exception(
            'Failed to load ItemList: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching ItemList: $e');
    }
  }

  /// Saves or updates an ItemList on the server (optional, if API supports it)
  Future<void> saveItemList(ItemList itemList) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/itemlist'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if required
        },
        body: jsonEncode(ItemListResponse(
          itemList: itemList,
          status: 'OK',
          message: 'Data Saved!',
        ).toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Failed to save ItemList: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saving ItemList: $e');
    }
  }
}
