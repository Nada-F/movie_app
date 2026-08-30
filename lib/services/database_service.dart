import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/movie.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    try {
      if (_database != null) {
        return _database!;
      }
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      throw Exception('Database error: Failed to open database. $e');
    }
  }

  Future<Database> _initDatabase() async {
    try {
      if (kIsWeb) {
        databaseFactory = databaseFactoryFfiWeb;
      } else if (!kIsWeb) {
        databaseFactory = databaseFactoryFfi;
      }

      final databasePath = await getDatabasesPath();
      final path = join(databasePath, 'movie_app.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE favorites (
              id INTEGER PRIMARY KEY,
              title TEXT NOT NULL,
              overview TEXT,
              posterPath TEXT,
              backdropPath TEXT,
              rating REAL,
              releaseDate TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE continue_watching (
              id INTEGER PRIMARY KEY,
              title TEXT NOT NULL,
              overview TEXT,
              posterPath TEXT,
              backdropPath TEXT,
              rating REAL,
              releaseDate TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE want_to_watch (
              id INTEGER PRIMARY KEY,
              title TEXT NOT NULL,
              overview TEXT,
              posterPath TEXT,
              backdropPath TEXT,
              rating REAL,
              releaseDate TEXT
            )
          ''');
        },
      );
    } catch (e) {
      throw Exception('Database error: Failed to initialize database. $e');
    }
  }

  Map<String, dynamic> _movieToMap(Movie movie) {
    return {
      'id': movie.id,
      'title': movie.title,
      'overview': movie.overview,
      'posterPath': movie.posterPath,
      'backdropPath': movie.backdropPath,
      'rating': movie.rating,
      'releaseDate': movie.releaseDate,
    };
  }

  Movie _mapToMovie(Map<String, dynamic> map) {
    try {
      return Movie(
        id: map['id'] as int,
        title: map['title'] as String,
        overview: map['overview'] as String? ?? '',
        posterPath: map['posterPath'] as String? ?? '',
        backdropPath: map['backdropPath'] as String? ?? '',
        rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
        releaseDate: map['releaseDate'] as String? ?? '',
      );
    } catch (e) {
      throw Exception('Database error: Failed to convert data. $e');
    }
  }

  

  Future<void> addFavorite(Movie movie) async {
    try {
      final db = await database;
      await db.insert(
        'favorites',
        _movieToMap(movie),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Database error: Failed to add favorite. $e');
    }
  }

  Future<void> removeFavorite(int movieId) async {
    try {
      final db = await database;
      await db.delete(
        'favorites',
        where: 'id = ?',
        whereArgs: [movieId],
      );
    } catch (e) {
      throw Exception('Database error: Failed to remove favorite. $e');
    }
  }

  Future<bool> isFavorite(int movieId) async {
    try {
      final db = await database;
      final result = await db.query(
        'favorites',
        where: 'id = ?',
        whereArgs: [movieId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<Movie>> getFavorites() async {
    try {
      final db = await database;
      final result = await db.query(
        'favorites',
        orderBy: 'id DESC',
      );
      return result.map(_mapToMovie).toList();
    } catch (e) {
      throw Exception('Database error: Failed to get favorites. $e');
    }
  }

   

  Future<void> addContinueWatching(Movie movie) async {
    try {
      final db = await database;
      await db.insert(
        'continue_watching',
        _movieToMap(movie),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Database error: Failed to add to continue watching. $e');
    }
  }

  Future<void> removeContinueWatching(int movieId) async {
    try {
      final db = await database;
      await db.delete(
        'continue_watching',
        where: 'id = ?',
        whereArgs: [movieId],
      );
    } catch (e) {
      throw Exception('Database error: Failed to remove from continue watching. $e');
    }
  }

  Future<List<Movie>> getContinueWatching() async {
    try {
      final db = await database;
      final result = await db.query(
        'continue_watching',
        orderBy: 'id DESC',
      );
      return result.map(_mapToMovie).toList();
    } catch (e) {
      throw Exception('Database error: Failed to get continue watching. $e');
    }
  }

  
  Future<void> addWantToWatch(Movie movie) async {
    try {
      final db = await database;
      await db.insert(
        'want_to_watch',
        _movieToMap(movie),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Database error: Failed to add to want to watch. $e');
    }
  }

  Future<void> removeWantToWatch(int movieId) async {
    try {
      final db = await database;
      await db.delete(
        'want_to_watch',
        where: 'id = ?',
        whereArgs: [movieId],
      );
    } catch (e) {
      throw Exception('Database error: Failed to remove from want to watch. $e');
    }
  }

  Future<List<Movie>> getWantToWatch() async {
    try {
      final db = await database;
      final result = await db.query(
        'want_to_watch',
        orderBy: 'id DESC',
      );
      return result.map(_mapToMovie).toList();
    } catch (e) {
      throw Exception('Database error: Failed to get want to watch. $e');
    }
  }
}