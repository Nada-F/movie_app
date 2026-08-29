import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/movie_controller.dart';
import 'controllers/favorite_controller.dart';
import 'providers/movie_provider.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        
        
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(
          create: (context) {
            final controller = MovieController();
            final provider = context.read<MovieProvider>();
            controller.init(provider);
            return controller;
          },
        ),
        ChangeNotifierProvider(create: (_) => FavoriteController()),
      ],
      child: const MovieApp(),
    ),
  );
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070707),
        fontFamily: 'Arial',
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF070707),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}