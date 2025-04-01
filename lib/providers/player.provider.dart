import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import 'package:uoguesser/server/services/player.service.dart';
import 'package:uoguesser/server/services/picture.service.dart';
import 'package:uoguesser/server/services/friendship.service.dart';
import 'package:uoguesser/server/models/player.dart';
import 'package:uoguesser/server/models/picture.dart';

class PlayerProvider extends ChangeNotifier {
  static const String _playerIdKey = 'player_id';
  final _playerService = GetIt.instance<PlayerService>();
  final _pictureService = GetIt.instance<PictureService>();
  final _friendshipService = GetIt.instance<FriendshipService>();
  final _prefs = SharedPreferences.getInstance();

  Player? _currentPlayer;
  List<Picture> _pictures = [];
  bool _isLoading = false;

  Player? get currentPlayer => _currentPlayer;
  List<Picture> get pictures => _pictures;
  bool get isLoading => _isLoading;

  PlayerService get playerService => _playerService;
  PictureService get pictureService => _pictureService;
  FriendshipService get friendshipService => _friendshipService;
  Future<Player?>? get playerFuture => _playerFuture;
  Future<Player?>? _playerFuture;

  // Initialize player state
  Future<void> initialize() async {
    print("Initizlizing player provider");
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await _prefs;
      final storedPlayerId = prefs.getString(_playerIdKey);

      if (storedPlayerId != null) {
        try {
          _currentPlayer = await _playerService.getPlayerProfileById(storedPlayerId);
          _playerFuture = Future.value(_currentPlayer);
          await _loadPlayerPictures();
        } catch (e) {}
      }
    } catch (e) {
      debugPrint('Error initializing player: \$e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createNewPlayer(String username, String password, {String? id}) async {
    final playerId = id ?? Uuid().v4();
    final newPlayer = Player(
      id: playerId,
      name: username,
      password: password,
      biography: null,
      createdAt: DateTime.now().toUtc(),
    );

    await _playerService.createPlayer(newPlayer);
    _currentPlayer = newPlayer;

    final prefs = await _prefs;
    await prefs.setString(_playerIdKey, newPlayer.id);
  }

  Future<void> _loadPlayerPictures() async {
    if (_currentPlayer == null) return;

    try {
      _pictures = await _pictureService.getPicturesByPlayer(_currentPlayer!.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading pictures: \$e');
    }
  }

  Future<void> updateProfile({required String name, String? biography}) async {
    if (_currentPlayer == null) return;

    try {
      final updatedPlayer = Player(
        id: _currentPlayer!.id,
        name: name,
        password: _currentPlayer!.password,
        biography: biography,
        createdAt: _currentPlayer!.createdAt,
        lastLogin: _currentPlayer!.lastLogin,
        highScore: _currentPlayer!.highScore,
      );

      await _playerService.updatePlayer(updatedPlayer);
      _currentPlayer = updatedPlayer;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: \$e');
      rethrow;
    }
  }

  Future<void> refreshPictures() async {
    await _loadPlayerPictures();
  }

  void addPicture(Picture picture) {
    _pictures = [..._pictures, picture];
    notifyListeners();
  }

  Future<void> logout() async {
    _currentPlayer = null;
    _pictures = [];
    final prefs = await _prefs;
    await prefs.remove(_playerIdKey);
    notifyListeners();
  }

  Future<void> setCurrentPlayer(Player player) async {
    final prefs = await _prefs;
    await prefs.setString(_playerIdKey, player.id);
    _currentPlayer = player;
    await _loadPlayerPictures();
    notifyListeners();
  }

  Future<void> loginOrRegister(String username, String password) async {
    print("Logging in!");
    print(username);
    print(password);
    try {
      final player = await _playerService.getPlayerByUsername(username);
      print("Get player here");
      print(player.password);
      if (player.password == password) {
        await setCurrentPlayer(player);
      } else {
        throw Exception('Incorrect password');
      }
    } catch (_) {
      await _createNewPlayer(username, password);
    }
  }
}
