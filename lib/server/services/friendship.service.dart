import 'package:uoguesser/server/data/friendship.repository.dart';
import 'package:uoguesser/server/models/player.dart';
import 'package:uoguesser/server/models/friendship.dart';

class FriendshipService {
  final FriendshipRepository _repository;

  FriendshipService(this._repository);

  /// Get all friendships for a player
  Future<List<Friendship>> getFriendships(String playerId) async {
    try {
      return await _repository.getFriendships(playerId);
    } catch (e) {
      throw FriendshipServiceException('Failed to get friendships: $e');
    }
  }

  /// Get the current players friends
  Future<List<Player>> getFriendProfiles(String playerId) async {
    try {
      return await _repository.getFriendProfiles(playerId);
    } catch (e) {
      throw FriendshipServiceException('Failed to get friend profiles: $e');
    }
  }

  /// Send a friend request
  Future<void> sendFriendRequest(String fromPlayerId, String toPlayerId) async {
    try {
      if (fromPlayerId == toPlayerId) {
        throw FriendshipServiceException(
          'Cannot send friend request to yourself',
        );
      }
      await _repository.sendFriendRequest(fromPlayerId, toPlayerId);
    } catch (e) {
      throw FriendshipServiceException('Failed to send friend request: $e');
    }
  }

  /// Accept a friend request
  Future<void> acceptFriendRequest(
    String fromPlayerId,
    String toPlayerId,
  ) async {
    try {
      await _repository.acceptFriendRequest(fromPlayerId, toPlayerId);
    } catch (e) {
      throw FriendshipServiceException('Failed to accept friend request: $e');
    }
  }

  Future<void> rejectFriendRequest(
    String fromPlayerId,
    String toPlayerId,
  ) async {
    try {
      await _repository.rejectFriendRequest(fromPlayerId, toPlayerId);
    } catch (e) {
      throw FriendshipServiceException('Failed to reject friend request: $e');
    }
  }
}

class FriendshipServiceException implements Exception {
  final String message;
  FriendshipServiceException(this.message);

  @override
  String toString() => message;
}
