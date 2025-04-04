import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uoguesser/server/services/player.service.dart';
import '../server/models/game.dart';
import '../server/models/player.dart';
import '../server/models/game_instance.dart';
import '../server/services/game.service.dart';
import '../server/services/game_instance.service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _isLoading = true;
  String error = "";
  Game? _game;
  GameInstance? _gameInstance;
  List<Map<String, dynamic>> _leaderboard = [];

  final _gameService = GetIt.instance<GameService>();
  final _gameInstanceService = GetIt.instance<GameInstanceService>();
  final _playerService = GetIt.instance<PlayerService>();

  @override
  void initState() {
    super.initState();
    _getDailyLeaders();
  }

  Future<void> _getDailyLeaders() async {
    try {
      setState(() {
        _isLoading = true;
        error = "";
      });

      final result = await _gameService.getDailyGame();
      setState(() {
        _game = result.game;
        _isLoading = false;
      });
      final lb = await _gameInstanceService.getDailyLeaderboard(_game!.id);
      List<Map<String, dynamic>> leaderboard = [];
      for (var game in lb) {
        Player player = await _playerService.getPlayerProfileById(
          game.playerId,
        );
        String playerName = player.name;
        leaderboard.add({'name': playerName, 'score': game.totalScore});
      }
      for (int i = 0; i < leaderboard.length; i++) {
        leaderboard[i]['rank'] = i + 1;
      }
      setState(() {
        _leaderboard = leaderboard;
      });
    } catch (e) {
      setState(() {
        error = "Could not get daily game: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
        backgroundColor: Color.fromARGB(255, 194, 4, 48),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _leaderboard.isEmpty
              ? Center(child: Text('No leaderboard data available'))
              : Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () { // TODO: change to global leaderboards
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Color.fromARGB(255, 255, 199, 42),
                            ),
                            child: Text('Global'),
                          ),
                          ElevatedButton(
                            onPressed: () { // TODO: change to friends leaderboards
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Color.fromARGB(255, 255, 199, 42),
                            ),
                            child: Text('Friends'),
                          ),
                        ],
                      ),
                    ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Table(
                        border: TableBorder.all(color: Colors.black, width: 1),
                        columnWidths: const <int, TableColumnWidth>{
                          0: FixedColumnWidth(64),
                          1: FlexColumnWidth(),
                          2: FixedColumnWidth(64),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 194, 4, 48),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Rank',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Score',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          for (var player in _leaderboard)
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(player['rank'].toString()),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(player['name']),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(player['score'].toString()),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
