import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../services/database_service.dart';

class FavoriteController extends ChangeNotifier {
  final DatabaseService _database = DatabaseService.instance;

  Set<int> _favorites = {};
  Set<int> _watchlist = {};
  Set<int> _continueWatching = {};

  bool _isLoading = false;

  Set<int> get favorites => _favorites;
  Set<int> get watchlist => _watchlist;
  Set<int> get continueWatching => _continueWatching;
  bool get isLoading => _isLoading;

  
  Future<void> loadAllLists() async {
    _setLoading(true);

    try {
      final favMovies = await _database.getFavorites();
      final watchMovies = await _database.getWantToWatch();
      final continueMovies = await _database.getContinueWatching();

      _favorites = favMovies.map((m) => m.id).toSet();
      _watchlist = watchMovies.map((m) => m.id).toSet();
      _continueWatching = continueMovies.map((m) => m.id).toSet();
    } catch (_) {
      
    }

    _setLoading(false);
  }

  
  bool isFavorite(int movieId) => _favorites.contains(movieId);

  Future<void> toggleFavorite(Movie movie) async {
    final exists = _favorites.contains(movie.id);

    if (exists) {
      await _database.removeFavorite(movie.id);
      _favorites.remove(movie.id);
    } else {
      await _database.addFavorite(movie);
      _favorites.add(movie.id);
    }

    notifyListeners();
  }

  Future<List<Movie>> getFavoriteMovies() async {
    return await _database.getFavorites();
  }

  bool isInWatchlist(int movieId) => _watchlist.contains(movieId);

  Future<void> toggleWatchlist(Movie movie) async {
    final exists = _watchlist.contains(movie.id);

    if (exists) {
      await _database.removeWantToWatch(movie.id);
      _watchlist.remove(movie.id);
    } else {
      await _database.addWantToWatch(movie);
      _watchlist.add(movie.id);
    }

    notifyListeners();
  }

  Future<List<Movie>> getWatchlistMovies() async {
    return await _database.getWantToWatch();
  }

  bool isInContinueWatching(int movieId) =>
      _continueWatching.contains(movieId);

  Future<void> toggleContinueWatching(Movie movie) async {
    final exists = _continueWatching.contains(movie.id);

    if (exists) {
      await _database.removeContinueWatching(movie.id);
      _continueWatching.remove(movie.id);
    } else {
      await _database.addContinueWatching(movie);
      _continueWatching.add(movie.id);
    }

    notifyListeners();
  }

  Future<List<Movie>> getContinueWatchingMovies() async {
    return await _database.getContinueWatching();
  }

  Future<Map<String, bool>> getMovieStatus(int movieId) async {
    final favorite = await _database.isFavorite(movieId);
    final watchlist = await _database.getWantToWatch();
    final continueWatching = await _database.getContinueWatching();

    return {
      'isFavorite': favorite,
      'isInWatchlist': watchlist.any((m) => m.id == movieId),
      'isInContinueWatching': continueWatching.any((m) => m.id == movieId),
    };
  }

  Future<void> removeFavorite(int movieId) async {
    await _database.removeFavorite(movieId);
    _favorites.remove(movieId);
    notifyListeners();
  }

  Future<void> removeFromWatchlist(int movieId) async {
    await _database.removeWantToWatch(movieId);
    _watchlist.remove(movieId);
    notifyListeners();
  }

  Future<void> removeFromContinueWatching(int movieId) async {
    await _database.removeContinueWatching(movieId);
    _continueWatching.remove(movieId);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}