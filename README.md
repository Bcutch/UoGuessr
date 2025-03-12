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
├── server/
│   ├── services/     # Business logic layer
│   ├── models/       # Data models
│   └── data/        # Data access layer
└── main.dart        # Entry point
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
