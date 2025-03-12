import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import 'package:uoguesser/server/services/player.service.dart';
import 'package:uoguesser/server/services/picture.service.dart';
import 'package:uoguesser/server/models/player.dart';
import 'package:uoguesser/server/models/picture.dart';

class PlayerProvider extends ChangeNotifier {
  static const String _playerIdKey = 'player_id';
  final _playerService = GetIt.instance<PlayerService>();
  final _pictureService = GetIt.instance<PictureService>();
  final _prefs = SharedPreferences.getInstance();

  Player? _currentPlayer;
  List<Picture> _pictures = [];
  bool _isLoading = false;

  Player? get currentPlayer => _currentPlayer;
  List<Picture> get pictures => _pictures;
  bool get isLoading => _isLoading;

  // Initialize player state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await _prefs;
      final storedPlayerId = prefs.getString(_playerIdKey);

      if (storedPlayerId != null) {
        // Attempt to load existing player
        try {
          _currentPlayer = await _playerService.getPlayerProfileById(
            storedPlayerId,
          );
          await _loadPlayerPictures();
        } catch (e) {
          // If the player is not found on the server, create a new one on the server
          await _createNewPlayer(storedPlayerId);
        }
      } else {
        // If there is no stored player ID, create a new one
        await _createNewPlayer(null);
      }
    } catch (e) {
      debugPrint('Error initializing player: $e');
      rethrow; // Rethrow to let UI handle the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createNewPlayer(String? id) async {
    final playerId = id ?? Uuid().v4();
    final newPlayer = Player(
      id: playerId,
      name: 'Player$playerId', // Generate random username
      biography: null,
      createdAt: DateTime.now().toUtc(),
    );

    await _playerService.createPlayer(newPlayer);
    _currentPlayer = newPlayer;

    // Store player ID locally
    final prefs = await _prefs;
    await prefs.setString(_playerIdKey, newPlayer.id);
  }

  Future<void> _loadPlayerPictures() async {
    if (_currentPlayer == null) return;

    try {
      _pictures = await _pictureService.getPicturesByPlayer(_currentPlayer!.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading pictures: $e');
    }
  }

  // Method to update player profile
  Future<void> updateProfile({required String name, String? biography}) async {
    if (_currentPlayer == null) return;

    try {
      final updatedPlayer = Player(
        id: _currentPlayer!.id,
        name: name,
        biography: biography,
        createdAt: _currentPlayer!.createdAt,
        lastLogin: _currentPlayer!.lastLogin,
      );

      await _playerService.updatePlayer(updatedPlayer);
      _currentPlayer = updatedPlayer;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  // Method to refresh pictures
  Future<void> refreshPictures() async {
    await _loadPlayerPictures();
  }

  // Method to add a new picture
  void addPicture(Picture picture) {
    _pictures = [..._pictures, picture];
    notifyListeners();
  }
}
