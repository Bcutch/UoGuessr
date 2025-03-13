import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game.dart';

class GameRepository {
  final SupabaseClient _supabase;
  static const String _gamesTable = 'games';

  GameRepository(this._supabase);

  Future<Game> getGame(String id) async {
    final response =
        await _supabase.from(_gamesTable).select().eq('game_id', id).single();

    return Game.fromJson(response);
  }

  Future<Game> getDailyGame() async {
    final now = DateTime.now().toUtc();
    final gameResponse =
        await _supabase
            .from(_gamesTable)
            .select()
            .eq('mode', 'daily')
            .lte('valid_from', now.toIso8601String())
            .gt('valid_until', now.toIso8601String())
            .single();

    return Game.fromJson(gameResponse);
  }

  Future<Game> createGame(Game game) async {
    final gameResponse =
        await _supabase
            .from(_gamesTable)
            .insert(game.toJson())
            .select()
            .single();

    return Game.fromJson(gameResponse);
  }
}
