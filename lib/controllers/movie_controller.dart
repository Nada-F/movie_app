import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/movie_provider.dart';

class MovieController extends ChangeNotifier {
  late MovieProvider _provider;

  void init(MovieProvider provider) {
    _provider = provider;
    _provider.addListener(_onProviderChanged);
  }

  
  void _onProviderChanged() {
    notifyListeners();
  }

  
  List<Movie> get movies => _provider.movies;
  List<Movie> get searchResults => _provider.searchResults;
  bool get isLoading => _provider.isLoading;
  String? get errorMessage => _provider.errorMessage;
  String get selectedFilter => _provider.selectedFilter;

  Future<void> loadMovies() => _provider.loadMovies();
  Future<void> changeFilter(String filter) => _provider.changeFilter(filter);
  Future<void> searchMovies(String query) => _provider.searchMovies(query);
  void clearSearch() => _provider.clearSearch();

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    super.dispose();
  }
}