# Movie App

Movie App is a Flutter application for browsing and searching for movies. Users can create an account, explore different movie categories, view movie details, and save movies to their personal lists.

The app uses **TMDB** to get movie information, **Firebase Authentication** for user accounts, and **SQLite** for storing saved movies locally.

## Features

- User registration and login with Firebase Authentication
- Browse movies from Popular, Now Playing, Top Rated, and Upcoming categories
- Search for movies with a short delay to reduce unnecessary API requests
- View movie details including rating, release date, runtime, overview, and cast
- Add and remove movies from Favorites, My List, and Continue Watching
- Store saved movies locally using SQLite
- Loading and error states with a Try Again option
- Pull-to-refresh on saved movie screens
- Dark user interface

## Technologies Used

- **Flutter** - UI framework
- **Dart** - Programming language
- **Firebase Core** - Firebase initialization
- **Firebase Authentication** - Registration, login, and logout
- **TMDB API** - Movie data
- **HTTP** - API requests
- **Provider** - State management
- **SQLite** - Local storage
- **flutter_dotenv** - Environment variables

## Project Structure

movie_app/
│
├── lib/
│ ├── main.dart
│ ├── firebase_options.dart
│ │
│ ├── models/
│ │ └── movie.dart
│ │
│ ├── controllers/
│ │ ├── auth_controller.dart
│ │ ├── movie_controller.dart
│ │ └── favorite_controller.dart
│ │
│ ├── providers/
│ │ └── movie_provider.dart
│ │
│ ├── services/
│ │ ├── api_service.dart
│ │ ├── auth_service.dart
│ │ ├── tmdb_service.dart
│ │ └── database_service.dart
│ │
│ ├── screens/
│ │ ├── splash_screen.dart
│ │ ├── login_screen.dart
│ │ ├── signup_screen.dart
│ │ ├── home_screen.dart
│ │ ├── movie_details_screen.dart
│ │ ├── favorites_screen.dart
│ │ ├── continue_watching_screen.dart
│ │ └── want_to_watch_screen.dart
│ │
│ └── widgets/
│ └── movie_card.dart
│
├── assets/
│ └── images/
│ ├── drawer_background.png
│ ├── home_banner_background.png
│ ├── login_background.jpeg
│ ├── movie_app_banner.png
│ └── sign_up_background.jpeg
│
├── android/
├── web/
│
├── .env.example
├── .gitignore
├── pubspec.yaml
└── README.md

### Folder Description

- `models` - Contains the movie data model
- `controllers` - Handles application logic and coordinates between providers and screens
- `providers` - Contains the state management logic
- `services` - Handles API requests, authentication, and database operations
- `screens` - Contains the application screens
- `widgets` - Contains reusable UI components
- `assets` - Contains the images used in the application

## Application Flow

The application starts with the Login screen for unauthenticated users. New users can open the Sign Up screen and create an account using their name, email, and password.

After a successful registration or login, the user is taken to the Home screen. From there, users can browse movies by category or search for a specific movie.

Selecting a movie opens the Movie Details screen. The user can view more information about the movie and add or remove it from Favorites, My List, or Continue Watching.

Saved movies are stored locally using SQLite.

The drawer in the Home screen provides access to Favorites, My List, Continue Watching, and the Sign Out option.

## Setup

### 1. Install Flutter

Make sure Flutter is installed and open the project in your preferred IDE.

### 2. Install Dependencies

flutter pub get

### 3. Configure TMDB API Key

Create a `.env` file in the project root:

TMDB_API_KEY=your_tmdb_api_key

### 4. Configure Firebase

Connect the project to Firebase and enable Email/Password Authentication.

### 5. Run the Application

flutter run

## Documentation

For detailed documentation about the project architecture, API integration, database schema, authentication flow, and state management, please refer to:

[DOCUMENTATION.md](https://./DOCUMENTATION.md)

---

## Conclusion

Movie App provides a simple way to browse movies, search for specific titles, view movie information, and save movies to personal lists.

The project demonstrates how Flutter can be integrated with Firebase Authentication, the TMDB API, Provider, controllers, and SQLite in one application.