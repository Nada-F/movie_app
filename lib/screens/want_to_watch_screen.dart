import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../controllers/favorite_controller.dart';
import '../widgets/movie_card.dart';
import 'movie_details_screen.dart';

class WantToWatchScreen extends StatefulWidget {
  const WantToWatchScreen({super.key});

  @override
  State<WantToWatchScreen> createState() => _WantToWatchScreenState();
}

class _WantToWatchScreenState extends State<WantToWatchScreen> {
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
    final movies = await controller.getWatchlistMovies();

    if (!mounted) return;

    setState(() {
      _movies = movies;
      _loading = false;
    });
  }

  Future<void> _remove(Movie movie) async {
    await context.read<FavoriteController>().removeFromWatchlist(movie.id);

    if (!mounted) return;

    setState(() {
      _movies.removeWhere((item) => item.id == movie.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from My List'),
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
          'My List',
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
                        Icons.bookmark_border_rounded,
                        color: Colors.white24,
                        size: 70,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Your List Is Empty',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Save movies you want to watch later.',
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
                                    Icons.bookmark_rounded,
                                    color: Colors.amber,
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