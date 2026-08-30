import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  
  String get _apiKey {
    final key = dotenv.env['TMDB_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('TMDB API Key not found');
    }
    return key;
  }

  Future<bool> _hasInternet() async {
    try {
      if (kIsWeb) {
        final response = await http.get(
          Uri.parse('$_baseUrl/configuration?api_key=$_apiKey'),
        );
        return response.statusCode == 200;
      } else {
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      }
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      throw Exception('No internet connection. Please check your network.');
    }

    final uri = Uri.parse(_baseUrl + endpoint).replace(
      queryParameters: {
        'api_key': _apiKey,
        'language': 'en-US',
        ...?queryParams,
      },
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode}');
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      throw Exception('No internet connection. Please check your network.');
    }

    final uri = Uri.parse(_baseUrl + endpoint).replace(
      queryParameters: {
        'api_key': _apiKey,
        'language': 'en-US',
        ...?queryParams,
      },
    );

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('API Error: ${response.statusCode}');
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      rethrow;
    }
  }
}