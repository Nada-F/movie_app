import '../models/movie.dart';
import 'api_service.dart';

class TMDBService {
  final ApiService _api = ApiService();
  static const int _pagesToLoad = 3;

  Future<List<Movie>> _getMovies(String endpoint) async {
    final List<Movie> allMovies = [];

    for (int page = 1; page <= _pagesToLoad; page++) {
      final data = await _api.get(
        endpoint,
        queryParams: {'page': page.toString()},
      );

      final results = data['results'] as List? ?? [];
      final movies = results
          .whereType<Map<String, dynamic>>()
          .map(Movie.fromJson)
          .where((movie) => movie.id != 0)
          .toList();

      allMovies.addAll(movies);
    }

    final uniqueMovies = <int, Movie>{};
    for (final movie in allMovies) {
      uniqueMovies[movie.id] = movie;
    }

    return uniqueMovies.values.toList();
  }

  Future<List<Movie>> getPopularMovies() => _getMovies('/movie/popular');

  Future<List<Movie>> getNowPlayingMovies() => _getMovies('/movie/now_playing');

  Future<List<Movie>> getTopRatedMovies() => _getMovies('/movie/top_rated');

  Future<List<Movie>> getUpcomingMovies() => _getMovies('/movie/upcoming');

  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];

    final data = await _api.get(
      '/search/movie',
      queryParams: {
        'query': query.trim(),
        'include_adult': 'false',
      },
    );

    final results = data['results'] as List? ?? [];
    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((movie) => movie.id != 0)
        .toList();
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    return await _api.get(
      '/movie/$movieId',
      queryParams: {'append_to_response': 'credits'},
    );
  }
}