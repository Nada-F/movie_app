import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/database_service.dart';
import '../widgets/movie_card.dart';
import 'movie_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() =>
      _FavoritesScreenState();
}

class _FavoritesScreenState
    extends State<FavoritesScreen> {
  final DatabaseService _databaseService =
      DatabaseService.instance;

  List<Movie> _movies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    final movies =
        await _databaseService.getFavorites();

    if (!mounted) return;

    setState(() {
      _movies = movies;
      _loading = false;
    });
  }

  Future<void> _remove(Movie movie) async {
    await _databaseService.removeFavorite(movie.id);

    if (!mounted) return;

    setState(() {
      _movies.removeWhere(
        (item) => item.id == movie.id,
      );
    });

    _message('Removed from Favorites');
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF222222),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050505),
        title: const Text(
          'My Favorites',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : _movies.isEmpty
              ? _empty()
              : RefreshIndicator(
                  color: Colors.white,
                  backgroundColor:
                      const Color(0xFF1A1A1A),
                  onRefresh: _load,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _movies.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 190,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.64,
                    ),
                    itemBuilder: (context, index) {
                      final movie = _movies[index];

                      return Stack(
                        children: [
                          MovieCard(
                            movie: movie,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MovieDetailsScreen(
                                    movie: movie,
                                  ),
                                ),
                              ).then((_) => _load());
                            },
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _ActionButton(
                              icon:
                                  Icons.favorite_rounded,
                              color: Colors.redAccent,
                              onTap: () {
                                _remove(movie);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            color: Colors.white24,
            size: 70,
          ),
          SizedBox(height: 20),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add movies you love to your favorites.',
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.78),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: color,
            size: 19,
          ),
        ),
      ),
    );
  }
}