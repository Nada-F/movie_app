import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../services/database_service.dart';

class FavoriteController extends ChangeNotifier {
  final DatabaseService _database = DatabaseService.instance;

  Set<int> _favorites = {};
  Set<int> _watchlist = {};
  Set<int> _continueWatching = {};

  bool _isLoading = false;
  String? _errorMessage;

  Set<int> get favorites => _favorites;
  Set<int> get watchlist => _watchlist;
  Set<int> get continueWatching => _continueWatching;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAllLists() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final favMovies = await _database.getFavorites();
      final watchMovies = await _database.getWantToWatch();
      final continueMovies = await _database.getContinueWatching();

      _favorites = favMovies.map((m) => m.id).toSet();
      _watchlist = watchMovies.map((m) => m.id).toSet();
      _continueWatching = continueMovies.map((m) => m.id).toSet();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _setLoading(false);
  }

  bool isFavorite(int movieId) => _favorites.contains(movieId);

  Future<void> toggleFavorite(Movie movie) async {
    try {
      final exists = _favorites.contains(movie.id);

      if (exists) {
        await _database.removeFavorite(movie.id);
        _favorites.remove(movie.id);
      } else {
        await _database.addFavorite(movie);
        _favorites.add(movie.id);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Movie>> getFavoriteMovies() async {
    try {
      return await _database.getFavorites();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  bool isInWatchlist(int movieId) => _watchlist.contains(movieId);

  Future<void> toggleWatchlist(Movie movie) async {
    try {
      final exists = _watchlist.contains(movie.id);

      if (exists) {
        await _database.removeWantToWatch(movie.id);
        _watchlist.remove(movie.id);
      } else {
        await _database.addWantToWatch(movie);
        _watchlist.add(movie.id);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Movie>> getWatchlistMovies() async {
    try {
      return await _database.getWantToWatch();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  bool isInContinueWatching(int movieId) =>
      _continueWatching.contains(movieId);

  Future<void> toggleContinueWatching(Movie movie) async {
    try {
      final exists = _continueWatching.contains(movie.id);

      if (exists) {
        await _database.removeContinueWatching(movie.id);
        _continueWatching.remove(movie.id);
      } else {
        await _database.addContinueWatching(movie);
        _continueWatching.add(movie.id);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Movie>> getContinueWatchingMovies() async {
    try {
      return await _database.getContinueWatching();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<Map<String, bool>> getMovieStatus(int movieId) async {
    try {
      final favorite = await _database.isFavorite(movieId);
      final watchlist = await _database.getWantToWatch();
      final continueWatching = await _database.getContinueWatching();

      return {
        'isFavorite': favorite,
        'isInWatchlist': watchlist.any((m) => m.id == movieId),
        'isInContinueWatching': continueWatching.any((m) => m.id == movieId),
      };
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return {
        'isFavorite': false,
        'isInWatchlist': false,
        'isInContinueWatching': false,
      };
    }
  }

  Future<void> removeFavorite(int movieId) async {
    try {
      await _database.removeFavorite(movieId);
      _favorites.remove(movieId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeFromWatchlist(int movieId) async {
    try {
      await _database.removeWantToWatch(movieId);
      _watchlist.remove(movieId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeFromContinueWatching(int movieId) async {
    try {
      await _database.removeContinueWatching(movieId);
      _continueWatching.remove(movieId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}