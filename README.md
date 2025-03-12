# UoGuesser

A location-based guessing game where users try to identify where pictures were taken on a map. Players can upload their own pictures, which become part of the game's content. The game includes multiple modes and features both online and offline functionality.

## Features

- Daily challenges with 5 random pictures
- Unlimited mode for continuous play
- Picture upload with location data
- Google Maps integration
- Global and friends leaderboards
- User profiles with biography and picture gallery
- Offline play capability
- Score synchronization

## Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter](https://flutter.dev/docs/get-started/install) (latest stable version)
- [Dart](https://dart.dev/get-dart) (latest stable version)
- [Git](https://git-scm.com/downloads)
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (for local Supabase)
- [Node.js](https://nodejs.org/) (LTS version)

## Getting Started

### 1. Clone the Repository

```bash
git clone https://gitlab.socs.uoguelph.ca/w25-4030-section-01/group_17/uoguesser.git
cd uoguesser
```

### 2. Set Up Environment Variables

Create a `.env` file in the project root:

```bash
touch .env
```

Add the following variables to your `.env` file (get these values from the team lead):
```env
SUPABASE_URL=your_production_supabase_url
SUPABASE_ANON_KEY=your_production_supabase_anon_key
```

> **Important**: We are currently working directly with the production database. The local Supabase setup described below is optional and only needed if you want to experiment with database changes without affecting the production environment.

### 3. Install Flutter Dependencies

```bash
flutter pub get
```

### 4. Local Supabase Development (Optional)

> **Note**: This section is for developers who need to test database changes locally. For regular development, you can skip this section as we are working with the production database.

If you need to test database changes without affecting the production environment, you can set up a local Supabase instance:

1. Start Docker Desktop

2. Initialize Supabase project:
```bash
supabase init
```

3. Start local Supabase:
```bash
supabase start
```

This will create a local Supabase instance with the following credentials:

```
API URL: http://127.0.0.1:54321
     GraphQL URL: http://127.0.0.1:54321/graphql/v1
  S3 Storage URL: http://127.0.0.1:54321/storage/v1/s3
          DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
      Studio URL: http://127.0.0.1:54323
    Inbucket URL: http://127.0.0.1:54324
      JWT secret: <secret>
        anon key: <key>
service_role key: <key>
   S3 Access Key: <key>
   S3 Secret Key: <key>
       S3 Region: local
```

4. To use the local instance instead of production, update your `.env` file with the local credentials provided by `supabase start`.

### 5. Run the Application

```bash
flutter run
```

## Development Workflow

### Database Changes

> **Important**: We are currently working with the production database. Please coordinate with everyone before making any database changes.

### Database Migrations

All database migrations are stored in `supabase/migrations/`. To manage migrations:

1. Create a new migration:
```bash
supabase migration new your_migration_name
```

2. Apply migrations:
```bash
supabase migration up
```

3. Revert last migration:
```bash
supabase migration down
```

4. Reset database:
```bash
supabase db reset
```

### Working with Supabase

1. Start local Supabase:
```bash
supabase start
```

2. Stop local Supabase:
```bash
supabase stop
```

3. View logs:
```bash
supabase logs
```

### Code Structure

```
lib/
├── main.dart               # Application entry point
├── providers/             # State management
│   ├── player.provider.dart   # Player state management
│   └── ...
├── server/               # Backend integration
│   ├── services/         # Business logic layer
│   │   ├── player.service.dart
│   │   ├── game.service.dart
│   │   └── ...
│   ├── models/          # Data models
│   │   ├── player.dart
│   │   ├── game.dart
│   │   └── ...
│   └── data/           # Data access layer
│       ├── player.repository.dart
│       ├── game.repository.dart
│       └── ...
├── screens/            # UI screens
```

### State Management with Providers

The application uses the Provider pattern for state management. Each major feature has its own provider that manages its state and business logic. For example, the `PlayerProvider`:

```dart
class PlayerProvider extends ChangeNotifier {
  final _playerService = GetIt.instance<PlayerService>();
  
  Player? _currentPlayer;
  List<Picture> _pictures = [];
  
  // Expose state
  Player? get currentPlayer => _currentPlayer;
  List<Picture> get pictures => _pictures;
  
  // Methods to modify state
  Future<void> updateProfile({required String name, String? biography}) async {
    // Update player profile
    // Notify listeners of changes
  }
}
```

## Architecture Overview

### Server Layer Organization

The server-side code follows a clean architecture pattern with three main layers:

#### 1. Models Layer (`/server/models/`)
- Pure Dart classes representing database entities
- Handles JSON serialization/deserialization
- No business logic or data access
- Example: `Player`, `Game`, `Picture` models

```dart
// Example model structure (player.dart)
class Player {
  final String id;
  final String username;
  
  Player.fromJson(Map<String, dynamic> json) {
    // Conversion from JSON to Dart object
  }
  
  Map<String, dynamic> toJson() {
    // Conversion from Dart object to JSON
  }
}
```

#### 2. Data Layer (`/server/data/`)
- Repository classes for direct Supabase interaction
- Handles raw database queries and mutations
- No business logic
- One repository per entity type
- Example: `PlayerRepository`, `GameRepository`, `PictureRepository`

```dart
// Example repository structure (player.repository.dart)
class PlayerRepository {
  final SupabaseClient _supabase;
  
  Future<Player> getPlayer(String id) async {
    // Raw database query
    final response = await _supabase
        .from('players')
        .select()
        .eq('player_id', id)
        .single();
    
    return Player.fromJson(response);
  }
}
```

#### 3. Services Layer (`/server/services/`)
- Business logic implementation
- Orchestrates data operations
- Error handling and validation
- One service per major feature
- Example: `PlayerService`, `GameService`, `PictureService`

```dart
// Example service structure (player.service.dart)
class PlayerService {
  final PlayerRepository _repository;
  
  Future<Player> getPlayerProfile(String id) async {
    try {
      // Business logic, validation, error handling
      return await _repository.getPlayer(id);
    } catch (e) {
      throw PlayerServiceException('Failed to get player profile: $e');
    }
  }
}
```

### Dependency Injection

The application uses the `get_it` package for service location and dependency injection:

1. Service Registration (`service_locator.dart`):
   - Registers all repositories and services as singletons
   - Manages dependencies between services
   - Initializes Supabase client

```dart
// Example service registration
final getIt = GetIt.instance;

setupServices() {
  // Register repositories
  getIt.registerLazySingleton(() => PlayerRepository(supabase));
  
  // Register services with their dependencies
  getIt.registerLazySingleton(() => PlayerService(getIt<PlayerRepository>()));
}
```

2. Service Usage in App:
   - Services are accessed through `getIt`
   - No need to manually manage dependencies
   - Consistent singleton instances throughout the app

```dart
// Example service usage in widgets
final playerService = getIt<PlayerService>();
```

## Troubleshooting

### Common Issues

1. **Supabase Connection Issues**
   - Ensure Docker is running
   - Check if Supabase is started (`supabase status`)
   - Verify environment variables are correct

2. **Flutter Build Issues**
   - Run `flutter clean`
   - Delete `pubspec.lock` and run `flutter pub get`
   - Ensure all dependencies are compatible

3. **Database Migration Issues**
   - Reset the database (`supabase db reset`)
   - Check migration file syntax
   - Verify migration order

## Acknowledgments

- University of Guelph
- CIS*4030 Course Team
- All contributors to this project
