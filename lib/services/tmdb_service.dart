import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/movie.dart';

class TMDBService {
  static const String _baseUrl =
      'https://api.themoviedb.org/3';

  
  static const int _pagesToLoad = 3;

  String get _apiKey {
    final key = dotenv.env['TMDB_API_KEY'];

    if (key == null || key.isEmpty) {
      throw Exception('TMDB API Key not found');
    }

    return key;
  }

 

  Future<List<Movie>> _getMovies(
    String endpoint,
  ) async {
    final List<Movie> allMovies = [];

    for (int page = 1;
        page <= _pagesToLoad;
        page++) {
      final separator =
          endpoint.contains('?') ? '&' : '?';

      final url = Uri.parse(
        '$_baseUrl$endpoint'
        '${separator}api_key=$_apiKey'
        '&language=en-US'
        '&page=$page',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
          'TMDB Error: ${response.statusCode}',
        );
      }

      final data =
          jsonDecode(response.body);

      final List results =
          data['results'] ?? [];

      final movies = results
          .whereType<Map<String, dynamic>>()
          .map(Movie.fromJson)
          .where(
            (movie) => movie.id != 0,
          )
          .toList();

      allMovies.addAll(movies);
    }

    
    final Map<int, Movie> uniqueMovies = {};

    for (final movie in allMovies) {
      uniqueMovies[movie.id] = movie;
    }

    return uniqueMovies.values.toList();
  }

  

  Future<List<Movie>> getPopularMovies() {
    return _getMovies(
      '/movie/popular',
    );
  }

  

  Future<List<Movie>> getTrendingMovies() {
    return _getMovies(
      '/trending/movie/week',
    );
  }

  

  Future<List<Movie>> getNowPlayingMovies() {
    return _getMovies(
      '/movie/now_playing',
    );
  }

  

  Future<List<Movie>> getTopRatedMovies() {
    return _getMovies(
      '/movie/top_rated',
    );
  }

  

  Future<List<Movie>> getUpcomingMovies() {
    return _getMovies(
      '/movie/upcoming',
    );
  }

  

  Future<List<Movie>> searchMovies(
    String query,
  ) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final url = Uri.parse(
      '$_baseUrl/search/movie'
      '?api_key=$_apiKey'
      '&language=en-US'
      '&query=${Uri.encodeComponent(query.trim())}'
      '&page=1'
      '&include_adult=false',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Search failed: ${response.statusCode}',
      );
    }

    final data =
        jsonDecode(response.body);

    final List results =
        data['results'] ?? [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where(
          (movie) => movie.id != 0,
        )
        .toList();
  }

  

  Future<Map<String, dynamic>> getMovieDetails(
    int movieId,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/movie/$movieId'
      '?api_key=$_apiKey'
      '&language=en-US'
      '&append_to_response=credits',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Movie details error: ${response.statusCode}',
      );
    }

    return jsonDecode(response.body)
        as Map<String, dynamic>;
  }
}
