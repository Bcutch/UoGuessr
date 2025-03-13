import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:uoguesser/server/data/picture.repository.dart';
import 'package:uoguesser/server/models/picture.dart';

class PictureService {
  final PictureRepository _repository;
  final _uuid = const Uuid();

  PictureService(this._repository);

  /// Gets a singular picture by its id
  ///
  /// Most of the time you will use `getPicturesByPlayer` for getting pictures for a player
  /// Or `getPicturesForGame` for getting pictures for a game
  /// Rarely, if at all you will use this
  ///
  Future<Picture> getPicture(String id) async {
    try {
      return await _repository.getPicture(id);
    } catch (e) {
      throw PictureServiceException('Failed to get picture: $e');
    }
  }

  /// Gets all pictures for a player
  ///
  /// `playerId`: The id of the player to get pictures for
  Future<List<Picture>> getPicturesByPlayer(String playerId) async {
    try {
      return await _repository.getPicturesByPlayer(playerId);
    } catch (e) {
      throw PictureServiceException(
        'Failed to get pictures by player for player $playerId: $e',
      );
    }
  }

  /// Uploads a picture to the server
  ///
  /// `file`: The image to upload
  ///
  /// `playerId`: The id of the player the picture belongs to
  ///
  /// `latitude`: The latitude of the picture
  ///
  /// `longitude`: The longitude of the picture
  ///
  /// `title`: The title of the picture
  Future<Picture> uploadPicture({
    required File
    file, // TODO: Use XFile for flutter when Camera is implemented
    required String playerId,
    required double latitude,
    required double longitude,
    String? title,
  }) async {
    try {
      final fileId = _uuid.v4();
      final fileName = '$fileId.${file.path.split('.').last}';
      final storageUrl = await _repository.uploadPictureFile(file, fileName);

      final picture = Picture(
        id: fileId,
        playerId: playerId,
        storageUrl: storageUrl,
        latitude: latitude,
        longitude: longitude,
        title: title,
        createdAt: DateTime.now().toUtc(),
      );

      await _repository.createPicture(picture);
      return picture;
    } catch (e) {
      throw PictureServiceException('Failed to upload picture: $e');
    }
  }

  /// Deletes a picture from the server
  ///
  /// `id`: The id of the picture to delete
  Future<void> deletePicture(String id) async {
    try {
      await _repository.deletePicture(id);
    } catch (e) {
      throw PictureServiceException('Failed to delete picture: $e');
    }
  }

  /// Gets a random number of pictures
  ///
  /// This is usually used prior to inserting into the game_pictures table
  ///
  /// `count`: The number of pictures to get
  Future<List<Picture>> getRandomPictures(int count) async {
    try {
      return await _repository.getRandomPictures(count);
    } catch (e) {
      throw PictureServiceException('Failed to get random pictures: $e');
    }
  }
}

class PictureServiceException implements Exception {
  final String message;
  PictureServiceException(this.message);

  @override
  String toString() => message;
}
