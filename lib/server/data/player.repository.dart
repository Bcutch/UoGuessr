import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/player.dart';

class PlayerRepository {
  final SupabaseClient _supabase;
  static const String _table = 'players';

  PlayerRepository(this._supabase);

  Future<Player> getPlayer(String id) async {
    final response =
        await _supabase.from(_table).select().eq('player_id', id).single();

    return Player.fromJson(response);
  }

  Future<Player> getPlayerByUsername(String username) async {
    final response =
        await _supabase.from(_table).select().eq('name', username).single();
    print("response!");
    print(response);
    return Player.fromJson(response);
  }

  Future<void> createPlayer(Player player) async {
    await _supabase.from(_table).insert(player.toJson());
  }

  Future<void> updatePlayer(Player player) async {
    await _supabase
        .from(_table)
        .update(player.toJson())
        .eq('player_id', player.id);
  }

  Future<void> updateLastLogin(String playerId) async {
    await _supabase
        .from(_table)
        .update({'last_login': DateTime.now().toIso8601String()})
        .eq('player_id', playerId);
  }
}
