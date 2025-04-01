import 'package:uoguesser/server/data/player.repository.dart';
import 'package:uoguesser/server/models/player.dart';

class PlayerService {
  final PlayerRepository _repository;

  PlayerService(this._repository);

  Future<Player> getPlayerProfileById(String id) async {
    try {
      return await _repository.getPlayer(id);
    } catch (e) {
      throw PlayerServiceException('Failed to get player profile: $e');
    }
  }

  Future<Player> getPlayerByUsername(String username) async {
    try {
      print("Getting player by username!");
      return await _repository.getPlayerByUsername(username);
    } catch (e) {
      print("EXCEPTION");
      print(e);
      throw PlayerServiceException('Failed to get player by username: $e');
    }
  }

  Future<void> createPlayer(Player player) async {
    try {
      await _repository.createPlayer(player);
    } catch (e) {
      throw PlayerServiceException('Failed to create player: $e');
    }
  }

  Future<void> updatePlayer(Player player) async {
    try {
      await _repository.updatePlayer(player);
    } catch (e) {
      throw PlayerServiceException('Failed to update player: $e');
    }
  }

  Future<void> updateLastLogin(String playerId) async {
    try {
      await _repository.updateLastLogin(playerId);
    } catch (e) {
      throw PlayerServiceException('Failed to update last login: $e');
    }
  }
}

class PlayerServiceException implements Exception {
  final String message;
  PlayerServiceException(this.message);

  @override
  String toString() => message;
}
