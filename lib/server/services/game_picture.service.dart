import '../data/game_picture.repository.dart';
import '../models/game_picture.dart';
import '../models/picture.dart';

class GamePictureService {
  final GamePictureRepository _repository;

  GamePictureService(this._repository);

  /// Gets the game pictures for a game
  ///
  /// `gameId`: The id of the game to get pictures for
  Future<List<GamePicture>> getGamePictures(String gameId) async {
    try {
      return await _repository.getGamePictures(gameId);
    } catch (e) {
      throw GamePictureServiceException('Failed to get game pictures: $e');
    }
  }

  /// Gets the pictures for a game
  ///
  /// `gameId`: The id of the game to get pictures for
  Future<List<Picture>> getPicturesForGame(String gameId) async {
    try {
      return await _repository.getPicturesForGame(gameId);
    } catch (e) {
      throw GamePictureServiceException('Failed to get pictures for game: $e');
    }
  }

  /// Creates the game pictures for a game
  ///
  /// `gameId`: The id of the game to create pictures for
  /// `pictureIds`: The ids of the pictures to create
  Future<void> createGamePictures(
    String gameId,
    List<String> pictureIds,
  ) async {
    try {
      await _repository.createGamePictures(gameId, pictureIds);
    } catch (e) {
      throw GamePictureServiceException('Failed to create game pictures: $e');
    }
  }

  /// Deletes all game pictures for a game
  /// TODO: Incomplete, need to delete the pictures from the storage AND pictures table
  ///
  /// `gameId`: The id of the game to delete pictures for
  Future<void> deleteGamePictures(String gameId) async {
    try {
      await _repository.deleteGamePictures(gameId);
    } catch (e) {
      throw GamePictureServiceException('Failed to delete game pictures: $e');
    }
  }
}

class GamePictureServiceException implements Exception {
  final String message;
  GamePictureServiceException(this.message);

  @override
  String toString() => message;
}
