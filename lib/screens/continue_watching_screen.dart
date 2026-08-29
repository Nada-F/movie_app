import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../controllers/favorite_controller.dart';
import '../widgets/movie_card.dart';
import 'movie_details_screen.dart';

class ContinueWatchingScreen extends StatefulWidget {
  const ContinueWatchingScreen({super.key});

  @override
  State<ContinueWatchingScreen> createState() => _ContinueWatchingScreenState();
}

class _ContinueWatchingScreenState extends State<ContinueWatchingScreen> {
  List<Movie> _movies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final controller = context.read<FavoriteController>();
    final movies = await controller.getContinueWatchingMovies();

    if (!mounted) return;

    setState(() {
      _movies = movies;
      _loading = false;
    });
  }

  Future<void> _remove(Movie movie) async {
    await context.read<FavoriteController>().removeFromContinueWatching(movie.id);

    if (!mounted) return;

    setState(() {
      _movies.removeWhere((item) => item.id == movie.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from Continue Watching'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF222222),
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
          'Continue Watching',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _movies.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        color: Colors.white24,
                        size: 70,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Nothing Here Yet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Movies you start watching will appear here.',
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: const Color(0xFF1A1A1A),
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
                                  builder: (_) => MovieDetailsScreen(
                                    movie: movie,
                                  ),
                                ),
                              ).then((_) => _load());
                            },
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Material(
                              color: Colors.black.withOpacity(0.78),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => _remove(movie),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: Colors.greenAccent,
                                    size: 19,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}