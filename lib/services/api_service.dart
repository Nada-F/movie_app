import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  
  String get _apiKey {
    final key = dotenv.env['TMDB_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('TMDB API Key not found');
    }
    return key;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(_baseUrl + endpoint).replace(
      queryParameters: {
        'api_key': _apiKey,
        'language': 'en-US',
        ...?queryParams,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(_baseUrl + endpoint).replace(
      queryParameters: {
        'api_key': _apiKey,
        'language': 'en-US',
        ...?queryParams,
      },
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('API Error: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}