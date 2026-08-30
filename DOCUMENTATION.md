## Project Overview

Movie App is a Flutter application for browsing and searching movies. Users can create accounts, explore different movie categories, view movie details, and save movies to personal lists.

The application uses:

- **TMDB API** for movie data
- **Firebase Authentication** for user accounts
- **SQFLite** for local storage
- **Provider** for state management

---

## Architecture

The project follows the **MVC pattern** with Provider for state management.

### Main Components

- **Models** → Represent application data, such as Movie.
- **Controllers** → Handle business logic and coordinate between the UI, providers, and services.
- **Providers** → Manage application state and notify the UI when data changes.
- **Services** → Handle external communication such as API requests, Firebase Authentication, and database operations.
- **Screens** → Represent the application's user interface pages.
- **Widgets** → Provide reusable UI components.

### Data Flow

User interacts with Screen
↓
Screen calls Controller
↓
Controller calls Service
↓
Service fetches or stores data
↓
Controller updates Provider
↓
Provider notifies the UI
↓
Screen rebuilds

---

## Project Structure
```

lib/
├── main.dart
├── firebase_options.dart
│
├── models/
│   └── movie.dart
│
├── controllers/
│   ├── auth_controller.dart
│   ├── movie_controller.dart
│   └── favorite_controller.dart
│
├── providers/
│   └── movie_provider.dart
│
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── tmdb_service.dart
│   └── database_service.dart
│
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── movie_details_screen.dart
│   ├── favorites_screen.dart
│   ├── continue_watching_screen.dart
│   ├── want_to_watch_screen.dart
│   └── profile_screen.dart
│
└── widgets/
    └── movie_card.dart
```

---

## API Integration

### TMDB API

The application fetches movie data from The Movie Database (TMDB) API.

### Endpoints Used

| Endpoint | Purpose |
|----------|---------|
| `/movie/popular` | Retrieve popular movies |
| `/movie/now_playing` | Retrieve currently playing movies |
| `/movie/top_rated` | Retrieve top-rated movies |
| `/movie/upcoming` | Retrieve upcoming movies |
| `/search/movie` | Search for movies |
| `/movie/{id}` | Retrieve movie details with cast |

### Implementation

- **ApiService** handles all API requests, builds URLs, adds API keys, and processes responses.
- **TMDBService** uses ApiService to fetch specific movie data, requesting three pages per category and removing duplicates.
- Error handling is centralized in ApiService.

### Error Handling

- Missing API key → Exception
- Failed requests → Error message with status code
- Empty results → Empty list
- No internet connection → User-friendly message with Try Again option

---

## Database

### SQFLite

Local storage is handled using SQFLite.

### Tables

All tables share the same structure:

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PRIMARY KEY | Movie ID from TMDB |
| title | TEXT NOT NULL | Movie title |
| overview | TEXT | Movie overview |
| posterPath | TEXT | Poster image path |
| backdropPath | TEXT | Backdrop image path |
| rating | REAL | Movie rating |
| releaseDate | TEXT | Release date |

### Tables Used

- **favorites** → Saved favorite movies
- **continue_watching** → Movies the user is currently watching
- **want_to_watch** → Movies the user wants to watch later

### Operations

DatabaseService handles all database operations using Singleton pattern. CRUD operations are implemented for each table, and inserting a movie with an existing ID automatically replaces it.

---

## Authentication

### Firebase Authentication

User accounts are managed using Firebase Authentication.

### Features

**Sign Up**  
Users can create an account using email and password. The user's name is saved as the Firebase display name.

**Login**  
Users can sign in with their email and password.

**Logout**  
Users can sign out from the drawer.

### Error Handling

Common authentication errors are caught and displayed with user-friendly messages:

- Invalid email format
- Weak password
- Email already registered
- Invalid credentials
- Network issues
- Too many attempts

### Implementation

- **AuthService** communicates directly with Firebase Authentication.
- **AuthController** manages authentication state, loading state, and error messages.
- Screens call AuthController methods and handle success/failure states accordingly.

---

## State Management

### Provider

Provider is used for reactive state management.

### Controllers

| Controller | Responsibility |
|------------|----------------|
| AuthController | Authentication logic, loading state, error messages |
| MovieController | Movie operations, wraps MovieProvider, notifies UI |
| FavoriteController | Saved movies, favorites, watchlist, continue watching |

### Provider

| Provider | Responsibility |
|----------|----------------|
| MovieProvider | Movie data, category selection, search, loading state, errors |

### Usage

- Screens use `context.watch<T>()` to read state.
- Screens use `context.read<T>()` to call controller methods.
- `Consumer<T>` is used to rebuild only specific parts of the UI.

---

## Screens

| Screen | Description |
|--------|-------------|
| Splash Screen | Displays app logo and checks authentication status |
| Login Screen | User login with email and password |
| Sign Up Screen | New user registration |
| Home Screen | Browse movies by category, search functionality |
| Movie Details Screen | Movie information, cast, and list management |
| Favorites Screen | Display saved favorite movies |
| Continue Watching Screen | Display movies the user is currently watching |
| My List Screen | Display movies the user wants to watch later |
| Profile Screen | Display user information and saved movie statistics |

---

## Features

- User registration and login with Firebase Authentication
- Browse movies from Popular, Now Playing, Top Rated, and Upcoming categories
- Search for movies
- View movie details including rating, release date, runtime, overview, and cast
- Add and remove movies from Favorites
- Add and remove movies from Continue Watching
- Add and remove movies from My List
- View profile with user information and movie statistics
- Save movies locally using SQFLite
- Loading indicators and error states
- No internet connection handling
- Pull-to-refresh on saved movie screens
- Dark theme UI

---

## Setup Instructions

### 1. Install Dependencies

flutter pub get

### 2. Configure TMDB API Key

Create a `.env` file in the project root:

TMDB_API_KEY=your_api_key_here

### 3. Configure Firebase

Connect the project to Firebase and enable Email/Password Authentication.

### 4. Run the Application

flutter run

---

## Conclusion

Movie App demonstrates a complete Flutter application integrating API calls, authentication, state management, local storage, and a clean MVC architecture. The app provides a practical implementation of the concepts learned throughout the Flutter internship.