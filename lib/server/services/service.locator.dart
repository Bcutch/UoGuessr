import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Local imports for data repositories
import '../data/player.repository.dart';
import '../data/picture.repository.dart';
import '../data/game.repository.dart';
import '../data/friendship.repository.dart';
import '../data/game_instance.repository.dart';
import '../data/game_picture.repository.dart';

// Local imports for services
import 'player.service.dart';
import 'picture.service.dart';
import 'game.service.dart';
import 'friendship.service.dart';
import 'game_instance.service.dart';
import 'game_picture.service.dart';

final getIt = GetIt.instance;

Future<void> setupServices() async {
  await dotenv.load();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  final supabase = Supabase.instance.client;

  // Register repositories
  getIt.registerLazySingleton(() => PlayerRepository(supabase));
  getIt.registerLazySingleton(() => PictureRepository(supabase));
  getIt.registerLazySingleton(() => GameRepository(supabase));
  getIt.registerLazySingleton(() => FriendshipRepository(supabase));
  getIt.registerLazySingleton(() => GameInstanceRepository(supabase));
  getIt.registerLazySingleton(() => GamePictureRepository(supabase));

  // Register services
  getIt.registerLazySingleton(() => PlayerService(getIt<PlayerRepository>()));
  getIt.registerLazySingleton(() => PictureService(getIt<PictureRepository>()));
  getIt.registerLazySingleton(
    () => GamePictureService(getIt<GamePictureRepository>()),
  );
  getIt.registerLazySingleton(
    () => GameInstanceService(
      getIt<GameInstanceRepository>(),
      getIt<PictureService>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GameService(
      getIt<GameRepository>(),
      getIt<PictureService>(),
      getIt<GameInstanceService>(),
      getIt<GamePictureService>(),
    ),
  );
  getIt.registerLazySingleton(
    () => FriendshipService(getIt<FriendshipRepository>()),
  );
}
