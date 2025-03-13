import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uoguesser/server/models/player.dart';
import 'package:uoguesser/server/models/friendship.dart';

class FriendshipRepository {
  final SupabaseClient _supabase;
  static const String _friendshipsTable = 'friendships';

  FriendshipRepository(this._supabase);

  /// Get all friendships for a player (accepted and pending)
  Future<List<Friendship>> getFriendships(String playerId) async {
    final response = await _supabase
        .from(_friendshipsTable)
        .select()
        .or('player_id_1.eq.$playerId,player_id_2.eq.$playerId')
        .or(
          'status.eq.${FriendRequestStatus.accepted.toJson()},status.eq.${FriendRequestStatus.pending.toJson()}',
        );
    return response.map((row) => Friendship.fromJson(row)).toList();
  }

  /// Get the current players friends (accepted)
  Future<List<Player>> getFriendProfiles(String playerId) async {
    final response = await _supabase
        .from(_friendshipsTable)
        .select('players!player_id_2(*)')
        .eq('player_id_1', playerId)
        .eq('status', FriendRequestStatus.accepted.toJson());

    return response.map((row) => Player.fromJson(row['players'])).toList();
  }

  /// Send a friend request
  Future<void> sendFriendRequest(String fromPlayerId, String toPlayerId) async {
    await _supabase.from(_friendshipsTable).insert({
      'player_id_1': fromPlayerId,
      'player_id_2': toPlayerId,
      'status': FriendRequestStatus.pending.toJson(),
    });
  }

  /// Accept a friend request
  Future<void> acceptFriendRequest(
    String fromPlayerId,
    String toPlayerId,
  ) async {
    await _supabase
        .from(_friendshipsTable)
        .update({'status': FriendRequestStatus.accepted.toJson()})
        .eq('player_id_1', fromPlayerId)
        .eq('player_id_2', toPlayerId);
  }

  /// Reject a friend request
  Future<void> rejectFriendRequest(
    String fromPlayerId,
    String toPlayerId,
  ) async {
    await _supabase
        .from(_friendshipsTable)
        .delete()
        .eq('player_id_1', fromPlayerId)
        .eq('player_id_2', toPlayerId);
  }
}
