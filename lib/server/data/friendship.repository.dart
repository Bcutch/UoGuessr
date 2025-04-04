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
    .select('''
      player_id_1,
      player_id_2,
      player1:players!player_id_1(*),
      player2:players!player_id_2(*)
    ''')
    .or('player_id_1.eq.$playerId,player_id_2.eq.$playerId')
    .eq('status', FriendRequestStatus.accepted.toJson());

    final friendships = response as List<dynamic>;
    final friends = friendships.map((friendship) {
      if (friendship['player_id_1'] == playerId) {
        return Player.fromJson(friendship['player2']);
      } else {
        return Player.fromJson(friendship['player1']); // Return the other player's data
      }
    }).toList();

    final uniqueFriends = List<Player>.empty(growable: true);
    final playerIds = <String>{};

    for (final player in friends) {
      if (!playerIds.contains(player.id)) {
        playerIds.add(player.id);
        uniqueFriends.add(player);
      }
    }
    return uniqueFriends;
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
    await _supabase
        .from(_friendshipsTable)
        .update({'status': FriendRequestStatus.accepted.toJson()})
        .eq('player_id_1', toPlayerId)
        .eq('player_id_2', fromPlayerId);
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
