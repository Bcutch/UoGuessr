import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/picture.dart';
import 'dart:io';

class PictureRepository {
  final SupabaseClient _supabase;
  static const String _table = 'pictures';
  PictureRepository(this._supabase);

  /// Gets a singular picture by its id
  ///
  /// This is the only way to get a picture by its id
  /// Most of the time you will use `getPicturesByPlayer` for getting pictures for a player
  /// Or `getPicturesForGame` for getting pictures for a game
  /// Rarely, if at all you will use this
  ///
  Future<Picture> getPicture(String id) async {
    final response =
        await _supabase.rpc('get_picture', params: {'pictureid': id});

    final picture = Picture.fromJson(response.first as Map<String, dynamic>);

    return picture;
  }

  Future<List<Picture>> getPicturesByPlayer(String playerId) async {
    final response = await _supabase.rpc(
      'get_pictures_by_player',
      params: {'playerid': playerId},
    );

    // Handle case where response is null or empty
    if (response == null || response is! List) {
      return [];
    }

    // Filter out any null entries and convert to List<Picture>
    return response
        .where((row) => row != null)
        .map((row) => Picture.fromJson(row))
        .toList();
  }

  Future<String> createPicture(Picture picture) async {
    final response =
        await _supabase.from(_table).insert(picture.toJson()).select().single();

    return response['picture_id'];
  }

  Future<String> uploadPictureFile(File file, String fileName) async {
    await _supabase.storage.from(_table).upload(fileName, file);
    return _supabase.storage.from(_table).getPublicUrl(fileName);
  }

  /// Deletes a picture from the server
  ///
  /// NOTE: This can be easily extended to batch delete pictures by populating a list of file names
  ///
  Future<void> deletePicture(String id) async {
    final picture = await getPicture(id);
    final fileName = picture.storageUrl.split('/').last;

    // Delete from storage first
    await _supabase.storage.from(_table).remove([fileName]);

    // Then delete from database
    await _supabase.from(_table).delete().eq('picture_id', id);
  }

  /// Gets a random number of pictures
  ///
  /// This is usually used prior to inserting into the game_pictures table
  ///
  Future<List<Picture>> getRandomPictures(int count) async {
    final response = await _supabase
        .from(_table)
        .select()
        .limit(count)
        .order('random()');

    return response.map((row) => Picture.fromJson(row)).toList();
  }
}
