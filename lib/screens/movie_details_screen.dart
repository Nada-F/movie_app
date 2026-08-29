import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/database_service.dart';
import '../services/tmdb_service.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailsScreen> createState() =>
      _MovieDetailsScreenState();
}

class _MovieDetailsScreenState
    extends State<MovieDetailsScreen> {
  final DatabaseService _database =
      DatabaseService.instance;

  final TMDBService _tmdbService =
      TMDBService();

  bool _isFavorite = false;
  bool _isWantToWatch = false;
  bool _isContinueWatching = false;

  bool _loading = true;
  bool _detailsLoading = true;

  Map<String, dynamic>? _details;

  @override
  void initState() {
    super.initState();

    _loadStatus();
    _loadDetails();
  }

  Future<void> _loadStatus() async {
    final favorite =
        await _database.isFavorite(
      widget.movie.id,
    );

    final watchlist =
        await _database.getWantToWatch();

    final continueWatching =
        await _database.getContinueWatching();

    if (!mounted) return;

    setState(() {
      _isFavorite = favorite;

      _isWantToWatch = watchlist.any(
        (movie) =>
            movie.id == widget.movie.id,
      );

      _isContinueWatching =
          continueWatching.any(
        (movie) =>
            movie.id == widget.movie.id,
      );

      _loading = false;
    });
  }

  Future<void> _loadDetails() async {
    try {
      final details =
          await _tmdbService.getMovieDetails(
        widget.movie.id,
      );

      if (!mounted) return;

      setState(() {
        _details = details;
        _detailsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _detailsLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _database.removeFavorite(
        widget.movie.id,
      );
    } else {
      await _database.addFavorite(
        widget.movie,
      );
    }

    if (!mounted) return;

    setState(() {
      _isFavorite = !_isFavorite;
    });

    _message(
      _isFavorite
          ? 'Added to Favorites'
          : 'Removed from Favorites',
    );
  }

  Future<void> _toggleWatchlist() async {
    if (_isWantToWatch) {
      await _database.removeWantToWatch(
        widget.movie.id,
      );
    } else {
      await _database.addWantToWatch(
        widget.movie,
      );
    }

    if (!mounted) return;

    setState(() {
      _isWantToWatch =
          !_isWantToWatch;
    });

    _message(
      _isWantToWatch
          ? 'Added to My List'
          : 'Removed from My List',
    );
  }

  Future<void> _toggleContinueWatching() async {
    if (_isContinueWatching) {
      await _database
          .removeContinueWatching(
        widget.movie.id,
      );
    } else {
      await _database
          .addContinueWatching(
        widget.movie,
      );
    }

    if (!mounted) return;

    setState(() {
      _isContinueWatching =
          !_isContinueWatching;
    });

    _message(
      _isContinueWatching
          ? 'Added to Continue Watching'
          : 'Removed from Continue Watching',
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
        backgroundColor:
            const Color(0xFF242424),
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor:
            Color(0xFF070707),
        body: Center(
          child:
              CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final movie = widget.movie;

    return Scaffold(
      backgroundColor:
          const Color(0xFF070707),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 410,
            pinned: true,
            backgroundColor:
                const Color(0xFF070707),
            leading: _circleButton(
              Icons.arrow_back_ios_new_rounded,
              () => Navigator.pop(context),
            ),
            actions: [
              _circleButton(
                _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                _toggleFavorite,
                iconColor: _isFavorite
                    ? Colors.redAccent
                    : Colors.white,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace:
                FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  movie.backdropUrl.isNotEmpty
                      ? Image.network(
                          movie.backdropUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) {
                            return _backdrop();
                          },
                        )
                      : _backdrop(),

                  const DecoratedBox(
                    decoration:
                        BoxDecoration(
                      gradient:
                          LinearGradient(
                        begin:
                            Alignment.topCenter,
                        end:
                            Alignment.bottomCenter,
                        colors: [
                          Color(0x66000000),
                          Colors.transparent,
                          Color(0xFF070707),
                        ],
                        stops: [
                          0,
                          0.45,
                          1,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                22,
                0,
                22,
                45,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _poster(),

                      const SizedBox(width: 17),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 25,
                                fontWeight:
                                    FontWeight.w900,
                                height: 1.12,
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color:
                                      Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  movie.rating
                                      .toStringAsFixed(
                                    1,
                                  ),
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            _genres(),

                            const SizedBox(
                              height: 10,
                            ),

                            Text(
                              movie.year,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          _toggleContinueWatching,
                      icon: Icon(
                        _isContinueWatching
                            ? Icons.check_rounded
                            : Icons
                                .play_arrow_rounded,
                      ),
                      label: Text(
                        _isContinueWatching
                            ? 'In Continue Watching'
                            : 'Start Watching',
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.white,
                        foregroundColor:
                            Colors.black,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            9,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: _isFavorite
                              ? Icons
                                  .favorite_rounded
                              : Icons
                                  .favorite_border_rounded,
                          label: 'Favorite',
                          active:
                              _isFavorite,
                          onTap:
                              _toggleFavorite,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _ActionButton(
                          icon: _isWantToWatch
                              ? Icons
                                  .bookmark_rounded
                              : Icons
                                  .bookmark_border_rounded,
                          label: 'My List',
                          active:
                              _isWantToWatch,
                          onTap:
                              _toggleWatchlist,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'About the movie',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    movie.overview.isNotEmpty
                        ? movie.overview
                        : 'No description available.',
                    style:
                        const TextStyle(
                      color:
                          Color(0x99FFFFFF),
                      fontSize: 14,
                      height: 1.65,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _detailsSection(),

                  const SizedBox(height: 32),

                  _castSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsSection() {
    if (_detailsLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child:
              CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final details = _details;

    if (details == null) {
      return _detailsPanel(
        widget.movie,
      );
    }

    final runtime =
        details['runtime'];

    final language =
        details['original_language'];

    final releaseDate =
        details['release_date'];

    final status =
        details['status'];

    final genres =
        (details['genres'] as List?)
            ?.map(
              (e) => e['name'].toString(),
            )
            .join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0x12FFFFFF),
        ),
      ),
      child: Column(
        children: [
          _detailRow(
            Icons.calendar_today_rounded,
            'Release Date',
            releaseDate?.toString() ??
                'Unavailable',
          ),

          _divider(),

          _detailRow(
            Icons.access_time_rounded,
            'Runtime',
            runtime != null
                ? '$runtime minutes'
                : 'Unavailable',
          ),

          _divider(),

          _detailRow(
            Icons.language_rounded,
            'Original Language',
            language?.toString()
                    .toUpperCase() ??
                'Unavailable',
          ),

          _divider(),

          _detailRow(
            Icons.movie_filter_rounded,
            'Status',
            status?.toString() ??
                'Unavailable',
          ),

          if (genres != null &&
              genres.isNotEmpty) ...[
            _divider(),
            _detailRow(
              Icons.category_rounded,
              'Genres',
              genres,
            ),
          ],
        ],
      ),
    );
  }

  Widget _castSection() {
    if (_detailsLoading) {
      return const SizedBox.shrink();
    }

    final credits =
        _details?['credits'];

    if (credits == null) {
      return const SizedBox.shrink();
    }

    final List cast =
        credits['cast'] ?? [];

    if (cast.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleCast =
        cast.take(15).toList();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Cast',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 15),

        SizedBox(
          height: 205,
          child: ListView.builder(
            scrollDirection:
                Axis.horizontal,
            itemCount:
                visibleCast.length,
            itemBuilder:
                (context, index) {
              final actor =
                  visibleCast[index];

              final name =
                  actor['name']
                          ?.toString() ??
                      'Unknown';

              final character =
                  actor['character']
                          ?.toString() ??
                      '';

              final profilePath =
                  actor['profile_path'];

              return Container(
                width: 120,
                margin:
                    const EdgeInsets.only(
                  right: 13,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                      child: SizedBox(
                        width: 120,
                        height: 145,
                        child:
                            profilePath != null
                                ? Image.network(
                                    'https://image.tmdb.org/t/p/w185$profilePath',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) {
                                      return _personPlaceholder();
                                    },
                                  )
                                : _personPlaceholder(),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    if (character.isNotEmpty)
                      Text(
                        character,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          color:
                              Color(0xFF888888),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _genres() {
    final genres =
        (_details?['genres'] as List?)
            ?.take(3)
            .map(
              (e) => e['name'].toString(),
            )
            .toList();

    if (genres == null ||
        genres.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: genres.map((genre) {
        return Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color:
                const Color(0xFF202020),
            borderRadius:
                BorderRadius.circular(6),
          ),
          child: Text(
            genre,
            style:
                const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _detailsPanel(Movie movie) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _detailRow(
            Icons.calendar_today_rounded,
            'Release Date',
            movie.releaseDate.isEmpty
                ? 'Unavailable'
                : movie.releaseDate,
          ),

          _divider(),

          _detailRow(
            Icons.star_rounded,
            'TMDB Rating',
            '${movie.rating.toStringAsFixed(1)} / 10',
          ),

          _divider(),

          _detailRow(
            Icons.movie_creation_outlined,
            'Movie ID',
            movie.id.toString(),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      color: Color(0x12FFFFFF),
      height: 25,
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0x99FFFFFF),
          size: 21,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style:
                const TextStyle(
              color:
                  Color(0x88FFFFFF),
              fontSize: 12,
            ),
          ),
        ),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _poster() {
    final movie = widget.movie;

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(10),
      child: movie.posterUrl.isNotEmpty
          ? Image.network(
              movie.posterUrl,
              width: 105,
              height: 155,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) {
                return _posterPlaceholder();
              },
            )
          : _posterPlaceholder(),
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      width: 105,
      height: 155,
      color: const Color(0xFF181818),
      child: const Icon(
        Icons.movie_outlined,
        color: Color(0x55FFFFFF),
        size: 42,
      ),
    );
  }

  Widget _personPlaceholder() {
    return Container(
      color: const Color(0xFF181818),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: Color(0x55FFFFFF),
          size: 45,
        ),
      ),
    );
  }

  Widget _backdrop() {
    return Container(
      color: const Color(0xFF151515),
    );
  }

  Widget _circleButton(
    IconData icon,
    VoidCallback onTap, {
    Color iconColor = Colors.white,
  }) {
    return Padding(
      padding:
          const EdgeInsets.all(7),
      child: Container(
        width: 40,
        height: 40,
        decoration:
            BoxDecoration(
          color: Colors.black
              .withOpacity(0.60),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          icon: Icon(
            icon,
            color: iconColor,
            size: 19,
          ),
        ),
      ),
    );
  }
}

class _ActionButton
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return OutlinedButton(
      onPressed: onTap,
      style:
          OutlinedButton.styleFrom(
        backgroundColor:
            const Color(0xFF111111),
        foregroundColor:
            Colors.white,
        side: BorderSide(
          color: active
              ? const Color(0x55FFFFFF)
              : const Color(0x22FFFFFF),
        ),
        padding:
            const EdgeInsets.symmetric(
          vertical: 14,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(9),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: active
                ? Colors.redAccent
                : const Color(0x99FFFFFF),
            size: 19,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}