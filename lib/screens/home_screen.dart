import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../services/database_service.dart';
import '../widgets/movie_card.dart';

import 'continue_watching_screen.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';
import 'movie_details_screen.dart';
import 'want_to_watch_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final DatabaseService _database =
      DatabaseService.instance;

  Timer? _searchTimer;

  Set<int> _favorites = {};
  Set<int> _watchlist = {};

  
  final ScrollController _popularController =
      ScrollController();

  final ScrollController _moreLikeThisController =
      ScrollController();

  final ScrollController _discoverController =
      ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadMovies();
      _loadLists();
    });
  }

  Future<void> _loadLists() async {
    try {
      final favorites =
          await _database.getFavorites();

      final watchlist =
          await _database.getWantToWatch();

      if (!mounted) return;

      setState(() {
        _favorites =
            favorites.map((movie) => movie.id).toSet();

        _watchlist =
            watchlist.map((movie) => movie.id).toSet();
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchTimer?.cancel();

    _searchController.dispose();

    _popularController.dispose();
    _moreLikeThisController.dispose();
    _discoverController.dispose();

    super.dispose();
  }

  void _search(String query) {
    setState(() {});

    _searchTimer?.cancel();

    _searchTimer = Timer(
      const Duration(milliseconds: 500),
      () {
        if (!mounted) return;

        context
            .read<MovieProvider>()
            .searchMovies(query);
      },
    );
  }

  void _clearSearch() {
    _searchController.clear();

    context.read<MovieProvider>().clearSearch();

    setState(() {});
  }

  void _openMovie(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MovieDetailsScreen(movie: movie),
      ),
    ).then((_) {
      _loadLists();
    });
  }

  Future<void> _toggleFavorite(Movie movie) async {
    final exists =
        _favorites.contains(movie.id);

    if (exists) {
      await _database.removeFavorite(movie.id);
    } else {
      await _database.addFavorite(movie);
    }

    if (!mounted) return;

    setState(() {
      if (exists) {
        _favorites.remove(movie.id);
      } else {
        _favorites.add(movie.id);
      }
    });
  }

  Future<void> _toggleWatchlist(Movie movie) async {
    final exists =
        _watchlist.contains(movie.id);

    if (exists) {
      await _database.removeWantToWatch(movie.id);
    } else {
      await _database.addWantToWatch(movie);
    }

    if (!mounted) return;

    setState(() {
      if (exists) {
        _watchlist.remove(movie.id);
      } else {
        _watchlist.add(movie.id);
      }
    });
  }

  void _open(Widget screen) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  Future<void> _logout() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (_) => false,
    );
  }

  void _moveMovieRow(
    ScrollController controller,
  ) {
    if (!controller.hasClients) return;

    final maxScroll =
        controller.position.maxScrollExtent;

    final currentScroll =
        controller.offset;

    const moveDistance = 500.0;

    if (currentScroll >= maxScroll - 10) {
     
      controller.animateTo(
        0,
        duration:
            const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      
      final nextPosition =
          currentScroll + moveDistance;

      controller.animateTo(
        nextPosition > maxScroll
            ? maxScroll
            : nextPosition,
        duration:
            const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      drawer: _buildDrawer(),
      body: Consumer<MovieProvider>(
        builder: (context, provider, _) {
          final searching =
              _searchController.text
                  .trim()
                  .isNotEmpty;

          if (provider.isLoading &&
              provider.movies.isEmpty &&
              provider.searchResults.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          if (provider.errorMessage != null &&
              provider.movies.isEmpty &&
              !searching) {
            return _buildError(
              provider.errorMessage!,
            );
          }

          if (searching) {
            return _buildSearchPage(provider);
          }

          if (provider.movies.isEmpty) {
            return _buildEmpty();
          }

          return CustomScrollView(
            physics:
                const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),

              SliverToBoxAdapter(
                child: _buildHero(),
              ),

              SliverToBoxAdapter(
                child: _buildFilterBar(provider),
              ),

              SliverToBoxAdapter(
                child: _buildSection(
                  title: _sectionTitle(provider),
                  movies: provider.movies,
                  controller: _popularController,
                ),
              ),

              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'More Like This',
                  movies:
                      _differentMovies(provider.movies),
                  controller:
                      _moreLikeThisController,
                ),
              ),

              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'Discover',
                  movies:
                      _reverseMovies(provider.movies),
                  controller: _discoverController,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 70),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context)
                      .openDrawer();
                },
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          const Text(
            'MOVIE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),

          const Text(
            'APP',
            style: TextStyle(
              color: Color(0xFF777777),
              fontSize: 21,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),

          const Spacer(),

          SizedBox(
            width: 280,
            height: 43,
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Search movies...',
                hintStyle: const TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFFAAAAAA),
                ),
                suffixIcon:
                    _searchController.text
                            .isNotEmpty
                        ? IconButton(
                            onPressed:
                                _clearSearch,
                            icon: const Icon(
                              Icons.close_rounded,
                              color:
                                  Color(0xFFAAAAAA),
                            ),
                          )
                        : null,
                filled: true,
                fillColor:
                    const Color(0xFF171717),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          IconButton(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFFBBBBBB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        24,
        15,
        24,
        10,
      ),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        image: const DecorationImage(
          image: AssetImage(
            'assets/images/home_banner_background.png',
          ),
          fit: BoxFit.cover,
        ),

        border: Border.all(
          color: const Color(0x18FFFFFF),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/movie_app_banner.png',
              width: 78,
              height: 78,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 18),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Movie App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Discover movies you will love.',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(
    MovieProvider provider,
  ) {
    const filters = [
      'Popular',
      'Now Playing',
      'Top Rated',
      'Upcoming',
    ];

    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        itemCount: filters.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];

          final selected =
              provider.selectedFilter ==
                  filter;

          return GestureDetector(
            onTap: () async {
              await provider.changeFilter(
                filter,
              );
            },
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 19,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white
                    : const Color(0xFF171717),
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: selected
                        ? Colors.black
                        : const Color(
                            0xFFAAAAAA,
                          ),
                    fontSize: 13,
                    fontWeight: selected
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _sectionTitle(
    MovieProvider provider,
  ) {
    switch (provider.selectedFilter) {
      case 'Now Playing':
        return 'Now Playing';
      case 'Top Rated':
        return 'Top Rated';
      case 'Upcoming':
        return 'Coming Soon';
      default:
        return 'Popular Movies';
    }
  }

  Widget _buildSection({
    required String title,
    required List<Movie> movies,
    required ScrollController controller,
  }) {
    if (movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 24,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const Spacer(),

                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _moveMovieRow(controller);
                    },
                    borderRadius:
                        BorderRadius.circular(10),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF191919),
                        borderRadius:
                            BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              const Color(0x20FFFFFF),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 295,
            child: Scrollbar(
              controller: controller,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 4,
              radius:
                  const Radius.circular(10),
              child: ListView.builder(
                controller: controller,
                scrollDirection:
                    Axis.horizontal,
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 3,
                ),
                itemCount:
                    movies.length > 20
                        ? 20
                        : movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      right: 15,
                      bottom: 8,
                    ),
                    child: SizedBox(
                      width: 165,
                      child: MovieCard(
                        movie: movie,
                        isFavorite:
                            _favorites.contains(
                          movie.id,
                        ),
                        isWantToWatch:
                            _watchlist.contains(
                          movie.id,
                        ),
                        onTap: () {
                          _openMovie(movie);
                        },
                        onFavorite: () {
                          _toggleFavorite(movie);
                        },
                        onWantToWatch: () {
                          _toggleWatchlist(movie);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Movie> _differentMovies(
    List<Movie> movies,
  ) {
    if (movies.length <= 1) {
      return movies;
    }

    final result =
        List<Movie>.from(movies);

    final half = result.length ~/ 2;

    return [
      ...result.sublist(half),
      ...result.sublist(0, half),
    ];
  }

  List<Movie> _reverseMovies(
    List<Movie> movies,
  ) {
    return List<Movie>.from(
      movies.reversed,
    );
  }

  Widget _buildSearchPage(
    MovieProvider provider,
  ) {
    final movies = provider.searchResults;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              20,
              24,
              18,
            ),
            child: const Text(
              'Search Results',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),

        if (provider.isLoading)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child:
                    CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          ),

        if (movies.isEmpty &&
            !provider.isLoading)
          const SliverFillRemaining(
            child: Center(
              child: Text(
                'No movies found',
                style: TextStyle(
                  color: Color(0xFF777777),
                ),
              ),
            ),
          ),

        if (movies.isNotEmpty)
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            sliver: SliverGrid(
              delegate:
                  SliverChildBuilderDelegate(
                (context, index) {
                  final movie =
                      movies[index];

                  return MovieCard(
                    movie: movie,
                    isFavorite:
                        _favorites.contains(
                      movie.id,
                    ),
                    isWantToWatch:
                        _watchlist.contains(
                      movie.id,
                    ),
                    onTap: () {
                      _openMovie(movie);
                    },
                    onFavorite: () {
                      _toggleFavorite(movie);
                    },
                    onWantToWatch: () {
                      _toggleWatchlist(movie);
                    },
                  );
                },
                childCount: movies.length,
              ),
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 190,
                mainAxisSpacing: 20,
                crossAxisSpacing: 15,
                childAspectRatio: 0.64,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0C0C0C),
      width: 305,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/drawer_background.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.fromLTRB(
                  25,
                  30,
                  25,
                  25,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/movie_app_banner.png',
                        width: 180,
                        height: 114,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),

              _drawerItem(
                icon: Icons.home_rounded,
                title: 'Home',
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              _drawerItem(
                icon: Icons.favorite_rounded,
                title: 'Favorites',
                iconColor: Colors.redAccent,
                onTap: () {
                  _open(
                    const FavoritesScreen(),
                  );
                },
              ),

              _drawerItem(
                icon:
                    Icons.play_circle_fill_rounded,
                title: 'Continue Watching',
                iconColor: Colors.greenAccent,
                onTap: () {
                  _open(
                    const ContinueWatchingScreen(),
                  );
                },
              ),

              _drawerItem(
                icon: Icons.bookmark_rounded,
                title: 'My List',
                iconColor: Colors.amber,
                onTap: () {
                  _open(
                    const WantToWatchScreen(),
                  );
                },
              ),

              const Spacer(),

              const Divider(
                color: Color(0x18FFFFFF),
                indent: 20,
                endIndent: 20,
              ),

              _drawerItem(
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                iconColor:
                    const Color(0xFF888888),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 25,
      ),
      leading: Icon(
        icon,
        color: iconColor,
        size: 23,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFF777777),
              size: 60,
            ),
            const SizedBox(height: 18),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () {
                context
                    .read<MovieProvider>()
                    .loadMovies();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'No movies found',
        style: TextStyle(
          color: Color(0xFF777777),
          fontSize: 16,
        ),
      ),
    );
  }
}
