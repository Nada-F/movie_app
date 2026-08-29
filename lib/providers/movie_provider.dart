import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieProvider extends ChangeNotifier {
  final TMDBService _tmdbService = TMDBService();

  List<Movie> _movies = [];

  List<Movie> _searchResults = [];

  bool _isLoading = false;

  String? _errorMessage;

  String _selectedFilter = 'Popular';

  List<Movie> get movies => _movies;

  List<Movie> get searchResults => _searchResults;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String get selectedFilter => _selectedFilter;

  Future<void> loadMovies() async {
    _setLoading(true);

    try {
      _errorMessage = null;

      switch (_selectedFilter) {
        case 'Now Playing':
          _movies = await _tmdbService.getNowPlayingMovies();
          break;

        case 'Top Rated':
          _movies = await _tmdbService.getTopRatedMovies();
          break;

        case 'Upcoming':
          _movies = await _tmdbService.getUpcomingMovies();
          break;

        case 'Popular':
        default:
          _movies = await _tmdbService.getPopularMovies();
          break;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _setLoading(false);
  }

  Future<void> changeFilter(String filter) async {
    _selectedFilter = filter;

    await loadMovies();
  }

  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      _errorMessage = null;

      _searchResults = await _tmdbService.searchMovies(query);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _setLoading(false);
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}