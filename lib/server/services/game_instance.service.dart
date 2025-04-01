import 'package:uuid/uuid.dart';
import '../data/game_instance.repository.dart';
import '../models/game_instance.dart';
import '../models/game.dart';
import '../models/guess.dart';
import 'picture.service.dart';

class GameInstanceService {
  final GameInstanceRepository _repository;
  final PictureService _pictureService;

  GameInstanceService(this._repository, this._pictureService);

  Future<GameInstance> startGame(
    String gameId,
    String playerId,
    GameMode mode,
  ) async {
    try {
      return await _repository.startGameInstance(gameId, playerId, mode);
    } catch (e) {
      throw GameInstanceServiceException('Failed to start game: $e');
    }
  }

  /// Submits a guess for a game instance
  /// TODO: Incomplete, need response time tracking and subject to change
  /// `instanceId`: The id of the game instance to submit a guess for
  /// `pictureId`: The id of the picture to submit a guess for
  /// `latitude`: The latitude of the guess
  /// `longitude`: The longitude of the guess
  Future<void> submitGuess(
    String instanceId,
    String pictureId,
    double latitude,
    double longitude,
    double distanceMeters
  ) async {
    try {
      final picture = await _pictureService.getPicture(pictureId);
      // final distanceMeters =
      //     (latitude - picture.latitude) +
      //     (longitude -
      //         picture.longitude); // TODO: Use LatLong2 for distance calculation

      final guess = Guess(
        id: const Uuid().v4(),
        instanceId: instanceId,
        pictureId: pictureId,
        guessedLatitude: latitude,
        guessedLongitude: longitude,
        distanceMeters: distanceMeters,
        score: _calculateScore(distanceMeters),
        responseTime: null, // TODO: Add response time tracking
        createdAt: DateTime.now().toUtc(),
      );

      await _repository.submitGuess(guess);
    } catch (e) {
      throw GameInstanceServiceException('Failed to submit guess: $e');
    }
  }

  Future<void> completeGame(String instanceId, String playerId) async {
    try {
      final instance = await _repository.getPlayerGameHistory(playerId);
      if (instance.isEmpty) {
        throw GameInstanceServiceException('Game instance not found');
      }

      final gameInstance = instance.first;
      if (gameInstance.completed) {
        throw GameInstanceServiceException('Game already completed');
      }

      final totalScore = gameInstance.guesses.fold<int>(
        0,
        (sum, guess) => sum + (guess.score ?? 0),
      );

      final averageDistance =
          gameInstance.guesses.fold<double>(
            0,
            (sum, guess) => sum + (guess.distanceMeters ?? 0),
          ) /
          gameInstance.guesses.length;

      await _repository.completeGameInstance(
        instanceId,
        totalScore: totalScore,
        averageDistance: averageDistance,
      );
    } catch (e) {
      throw GameInstanceServiceException('Failed to complete game: $e');
    }
  }

  Future<List<GameInstance>> getPlayerGameHistory(String playerId) async {
    try {
      return await _repository.getPlayerGameHistory(playerId);
    } catch (e) {
      throw GameInstanceServiceException(
        'Failed to get player game history: $e',
      );
    }
  }

  Future<List<GameInstance>> getDailyLeaderboard(String gameId) async {
    try {
      return await _repository.getDailyLeaderboard(gameId);
    } catch (e) {
      throw GameInstanceServiceException('Failed to get daily leaderboard: $e');
    }
  }

  // Helper method to calculate score based on distance
  int _calculateScore(double distanceMeters) {
    // TODO: Implement proper scoring algorithm
    // For now, use a simple inverse relationship with distance
    const maxScore = 5000;
    const minScore = 0;
    const maxDistance = 20000.0; // 20km

    if (distanceMeters >= maxDistance) return minScore;
    return (maxScore * (1 - distanceMeters / maxDistance)).round();
  }
}

class GameInstanceServiceException implements Exception {
  final String message;
  GameInstanceServiceException(this.message);

  @override
  String toString() => message;
}
