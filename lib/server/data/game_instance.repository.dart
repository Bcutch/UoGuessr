import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_instance.dart';
import '../models/guess.dart';
import '../models/game.dart';

class GameInstanceRepository {
  final SupabaseClient _supabase;
  static const String _gameInstancesTable = 'game_instances';
  static const String _guessesTable = 'guesses';

  GameInstanceRepository(this._supabase);

  /// Starts a game instance
  ///
  /// `gameId`: The id of the game to start
  /// `playerId`: The id of the player to start the game for
  /// `mode`: The mode of the game to start
  Future<GameInstance> startGameInstance(
    String gameId,
    String playerId,
    GameMode mode,
  ) async {
    final response =
        await _supabase
            .from(_gameInstancesTable)
            .insert({
              'game_id': gameId,
              'player_id': playerId,
              'start_time': DateTime.now().toUtc().toIso8601String(),
            })
            .select()
            .single();

    return GameInstance.fromJson(response);
  }

  /// Submits a guess for a game instance
  ///
  /// `guess`: The guess to submit
  Future<void> submitGuess(Guess guess) async {
    await _supabase.from(_guessesTable).insert(guess.toJson());
  }

  Future<void> completeGameInstance(
    String instanceId, {
    required int totalScore,
    required double averageDistance,
  }) async {
    await _supabase
        .from(_gameInstancesTable)
        .update({
          'end_time': DateTime.now().toUtc().toIso8601String(),
          'total_score': totalScore,
          'average_distance': averageDistance,
          'completed': true,
        })
        .eq('instance_id', instanceId);
  }

  Future<List<GameInstance>> getPlayerGameHistory(String playerId) async {
    final response =
        await _supabase.rpc('get_player_game_history', params: {'playerid': playerId})
            as List<dynamic>;
    final instances =
        response
            .where((row) => row != null)
            .map((row) => GameInstance.fromJson(row as Map<String, dynamic>))
            .toList();

    return instances;
  }

  Future<List<GameInstance>> getDailyLeaderboard(String gameId) async {
    final response = await _supabase
        .from(_gameInstancesTable)
        .select('*, players(*)')
        .eq('game_id', gameId)
        .eq('completed', true)
        .order('total_score', ascending: false)
        .limit(100);

    return response.map((row) => GameInstance.fromJson(row)).toList();
  }
}
