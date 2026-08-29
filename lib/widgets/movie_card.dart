import 'package:flutter/material.dart';

import '../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;

  final VoidCallback? onFavorite;
  final VoidCallback? onWantToWatch;
  final VoidCallback? onDelete;

  final bool isFavorite;
  final bool isWantToWatch;

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.onFavorite,
    this.onWantToWatch,
    this.onDelete,
    this.isFavorite = false,
    this.isWantToWatch = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildPoster(),

              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Color(0xDD000000),
                    ],
                    stops: [
                      0.30,
                      0.55,
                      1,
                    ],
                  ),
                ),
              ),

              // Rating
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        movie.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Favorite + My List
              if (onFavorite != null || onWantToWatch != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    children: [
                      if (onFavorite != null)
                        _cardIconButton(
                          icon: isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          iconColor: isFavorite
                              ? Colors.redAccent
                              : Colors.white,
                          onTap: onFavorite!,
                        ),

                      if (onFavorite != null &&
                          onWantToWatch != null)
                        const SizedBox(height: 7),

                      if (onWantToWatch != null)
                        _cardIconButton(
                          icon: isWantToWatch
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          iconColor: isWantToWatch
                              ? Colors.amber
                              : Colors.white,
                          onTap: onWantToWatch!,
                        ),
                    ],
                  ),
                ),

              // Delete button
              if (onDelete != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: _cardIconButton(
                    icon: Icons.delete_outline_rounded,
                    iconColor: Colors.white,
                    onTap: onDelete!,
                  ),
                ),

              // Movie information
              Positioned(
                left: 10,
                right: 48,
                bottom: 11,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      movie.year,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Play button
              Positioned(
                right: 9,
                bottom: 10,
                child: Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.94),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardIconButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withOpacity(0.72),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            color: iconColor,
            size: 19,
          ),
        ),
      ),
    );
  }

  Widget _buildPoster() {
    if (movie.posterUrl.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      movie.posterUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _placeholder();
      },
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF181818),
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          color: Colors.white30,
          size: 48,
        ),
      ),
    );
  }
}