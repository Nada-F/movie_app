# Movie App

Movie App is a Flutter application for browsing and searching for movies. Users can create an account, explore different movie categories, view movie details, and save movies to their personal lists.

The app uses TMDB to get movie information, Firebase Authentication for user accounts, and SQLite for storing saved movies locally.

## Features

* User registration and login with Firebase Authentication.
* Browse movies from Popular, Now Playing, Top Rated, and Upcoming categories.
* Search for movies with a short delay to reduce unnecessary API requests.
* View movie details including rating, release date, runtime, overview, and cast.
* Add and remove movies from Favorites, My List, and Continue Watching.
* Store saved movies locally using SQLite.
* Loading and error states with a Try Again option.
* Pull-to-refresh on saved movie screens.
* Dark user interface.

## Technologies Used

The project was developed using Flutter and Dart.

Main packages and technologies used:

* **Flutter** - UI framework.
* **Dart** - Programming language.
* **Firebase Core** - Firebase initialization.
* **Firebase Authentication** - Registration, login, and logout.
* **TMDB API** - Movie data.
* **HTTP** - API requests.
* **Provider** - State management.
* **SQLite** - Local storage.
* **flutter_dotenv** - Environment variables.

## Project Structure

```text
movie_app/
│
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   │
│   ├── models/
│   │   └── movie.dart
│   │
│   ├── providers/
│   │   └── movie_provider.dart
│   │
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── tmdb_service.dart
│   │   └── database_service.dart
│   │
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── home_screen.dart
│   │   ├── movie_details_screen.dart
│   │   ├── favorites_screen.dart
│   │   ├── continue_watching_screen.dart
│   │   └── want_to_watch_screen.dart
│   │
│   └── widgets/
│       └── movie_card.dart
│
├── assets/
│   └── images/
│       ├── drawer_background.png
│       ├── home_banner_background.png
│       ├── login_background.jpeg
│       ├── movie_app_banner.png
│       └── sign_up_background.jpeg
│
├── .env
├── pubspec.yaml
└── README.md
```

* `models` - Contains the movie data model.
* `providers` - Contains the state management logic.
* `services` - Handles authentication, API requests, and database operations.
* `screens` - Contains the application screens.
* `widgets` - Contains reusable UI components.
* `assets` - Contains the images used in the application.

## Application Flow

The application starts with the Login screen. New users can open the Sign Up screen and create an account using their name, email, and password.

After a successful registration or login, the user is taken to the Home screen. From there, users can browse movies by category or search for a specific movie.

Selecting a movie opens the Movie Details screen. The user can view more information about the movie and add or remove it from Favorites, My List, or Continue Watching.

Saved movies are stored locally using SQLite. The drawer in the Home screen provides access to Favorites, My List, Continue Watching, and the Sign Out option.

## Authentication

Firebase Authentication is used to manage user accounts. Users can create a new account, log in, and log out.

During registration, the user's name is saved as the Firebase display name.

The authentication logic is handled by `AuthService`, keeping Firebase-related code separate from the UI screens.

The application also handles common authentication errors such as invalid email, weak password, and an already registered email.

## Movie Data

Movie data is loaded from the TMDB API.

The Home screen provides four main categories:

* Popular
* Now Playing
* Top Rated
* Upcoming

For the main movie categories, the application requests three pages from TMDB and removes duplicate movies using their IDs.

The search feature waits briefly after the user stops typing before sending the request. This helps reduce unnecessary API calls while the user is typing.

The Movie Details screen displays additional information such as the movie rating, release date, runtime, overview, and cast.

## State Management

The project uses Provider for movie-related state management.

`MovieProvider` handles:

* Movie loading
* Category selection
* Search results
* Loading states
* Error messages

It communicates with `TMDBService` and updates the UI when the movie data changes.

## Local Storage

SQLite is used to store movies saved by the user.

The application uses three tables:

* `favorites`
* `continue_watching`
* `want_to_watch`

Each table stores information about the saved movie, including:

* Movie ID
* Title
* Overview
* Poster path
* Backdrop path
* Rating
* Release date

`DatabaseService` handles database operations such as adding, removing, checking, and loading saved movies.

## UI and Navigation

The application uses a dark theme with Material 3.

The Home screen contains movie cards and horizontal movie sections. Saved movie screens and search results use grid layouts.

The application also includes loading indicators, error messages, and empty states where needed.

The main navigation starts from the Login screen. Users can either create a new account through Sign Up or log in with an existing account.

After authentication, the user can access the Home screen, open movie details, and manage Favorites, My List, and Continue Watching.

The Home screen drawer provides quick access to the main sections and the Sign Out option.

## Setup

### 1. Install Flutter

Make sure Flutter is installed and open the project in your preferred IDE, such as Android Studio or Visual Studio Code.

### 2. Install Dependencies

Run:

```bash
flutter pub get
```

### 3. Add the TMDB API Key

Create a `.env` file in the project root and add your TMDB API key:

```env
TMDB_API_KEY=your_tmdb_api_key
```

The application reads the API key from the environment variable instead of placing it directly in the source code.

### 4. Configure Firebase

Connect the project to Firebase and make sure Email/Password authentication is enabled in the Firebase Authentication settings.

The Firebase configuration is provided through `firebase_options.dart`.

### 5. Run the Application

Run:

```bash
flutter run
```

## Project Goal

The goal of this project is to build a complete movie application using Flutter while practicing different parts of application development.

The project combines:

* User authentication
* API integration
* State management
* Local database storage
* Movie browsing and search
* Flutter UI development

## Conclusion

Movie App provides a simple way to browse movies, search for specific titles, view movie information, and save movies to personal lists.

The project also demonstrates how Flutter can be integrated with Firebase Authentication, the TMDB API, Provider, and SQLite in one application.
