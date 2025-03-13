import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_picture.dart';
import '../models/picture.dart';

class GamePictureRepository {
  final SupabaseClient _supabase;
  static const String _gamePicturesTable = 'game_pictures';

  GamePictureRepository(this._supabase);

  /// Gets all pictures for a game with their sequence numbers
  ///
  /// `gameId`: The id of the game to get pictures for
  Future<List<GamePicture>> getGamePictures(String gameId) async {
    final response = await _supabase
        .from(_gamePicturesTable)
        .select()
        .eq('game_id', gameId)
        .order('sequence_number');

    return response.map((row) => GamePicture.fromJson(row)).toList();
  }

  /// Gets all pictures for a game with their full picture data in
  /// ascending sequence (first picture is first, last picture is last)
  ///
  /// `gameId`: The id of the game to get pictures for
  Future<List<Picture>> getPicturesForGame(String gameId) async {
    final response = await _supabase
        .from(_gamePicturesTable)
        .select('pictures(*)')
        .eq('game_id', gameId)
        .order('sequence_number');

    return response.map((row) => Picture.fromJson(row['pictures'])).toList();
  }

  /// Creates game pictures entries for a game
  Future<void> createGamePictures(
    String gameId,
    List<String> pictureIds,
  ) async {
    final gamePictures =
        pictureIds
            .asMap()
            .entries
            .map(
              (entry) =>
                  GamePicture(
                    gameId: gameId,
                    pictureId: entry.value,
                    sequenceNumber: entry.key + 1,
                  ).toJson(),
            )
            .toList();

    await _supabase.from(_gamePicturesTable).insert(gamePictures);
  }

  /// Deletes all game pictures for a game
  /// TODO: Incomplete, need to delete the pictures from the storage AND pictures table
  ///
  /// `gameId`: The id of the game to delete pictures for
  Future<void> deleteGamePictures(String gameId) async {
    await _supabase.from(_gamePicturesTable).delete().eq('game_id', gameId);
  }
}
