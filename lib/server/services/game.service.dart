import 'package:uuid/uuid.dart';
import '../data/game.repository.dart';
import '../models/game.dart';
import '../models/picture.dart';
import 'picture.service.dart';
import 'game_instance.service.dart';
import 'game_picture.service.dart';

class GameService {
  final GameRepository _gameRepository;
  final PictureService _pictureService;
  final GameInstanceService _gameInstanceService;
  final GamePictureService _gamePictureService;

  GameService(
    this._gameRepository,
    this._pictureService,
    this._gameInstanceService,
    this._gamePictureService,
  );

  Future<Game> getGame(String id) async {
    try {
      return await _gameRepository.getGame(id);
    } catch (e) {
      throw GameServiceException('Failed to get game: $e');
    }
  }

  /// Gets the daily game
  ///
  ///
  Future<({Game game, List<Picture> pictures})> getDailyGame() async {
    try {
      final game = await _gameRepository.getDailyGame();
      final pictures = await _gamePictureService.getPicturesForGame(game.id);
      return (game: game, pictures: pictures);
    } catch (e) {
      throw GameServiceException('Failed to get daily game: $e');
    }
  }

  /// Creates a new daily game instance, as the game is created daily by the server
  ///
  /// `validFrom` and `validUntil` are the dates the game is valid for
  ///
  /// The game will be available for players to join between `validFrom` and `validUntil`
  ///
  ///
  Future<({Game game, List<Picture> pictures})> createDailyGame(
    String playerId,
  ) async {
    try {
      final (game: game, pictures: pictures) = await getDailyGame();

      if (pictures.length < 5) {
        throw GameServiceException(
          'Not enough pictures available for daily game',
        );
      }

      // Start the game instance
      await _gameInstanceService.startGame(game.id, playerId, GameMode.daily);

      return (game: game, pictures: pictures);
    } catch (e) {
      throw GameServiceException('Failed to create daily game: $e');
    }
  }

  /// Creates a new unlimited game
  Future<({Game game, List<Picture> pictures})> createUnlimitedGame(
    String playerId,
  ) async {
    try {
      // Get 10 random pictures for unlimited mode
      final pictures = await _pictureService.getRandomPictures(10);
      if (pictures.length < 10) {
        throw GameServiceException(
          'Not enough pictures available for unlimited game',
        );
      }

      final game = Game(
        id: const Uuid().v4(),
        mode: GameMode.unlimited,
        createdAt: DateTime.now().toUtc(),
      );

      // Create the game first
      final createdGame = await _gameRepository.createGame(game);

      // Then create the game pictures
      await _gamePictureService.createGamePictures(
        createdGame.id,
        pictures.map((p) => p.id).toList(),
      );

      // Start the game instance
      await _gameInstanceService.startGame(
        createdGame.id,
        playerId,
        GameMode.unlimited,
      );

      return (game: createdGame, pictures: pictures);
    } catch (e) {
      throw GameServiceException('Failed to create unlimited game: $e');
    }
  }
}

class GameServiceException implements Exception {
  final String message;
  GameServiceException(this.message);

  @override
  String toString() => message;
}
