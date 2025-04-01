import 'guess.dart';

class GameInstance {
  final String id;
  final String gameId;
  final String playerId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? totalScore;
  final double? averageDistance;
  final bool completed;
  final List<Guess> guesses;

  GameInstance({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.startTime,
    this.endTime,
    this.totalScore,
    this.averageDistance,
    this.completed = false,
    this.guesses = const [],
  });

  factory GameInstance.fromJson(Map<String, dynamic> json) {
    return GameInstance(
      id: json['instance_id'],
      gameId: json['game_id'],
      playerId: json['player_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      totalScore: json['total_score'],
      averageDistance: json['average_distance'],
      completed: json['completed'] ?? false,
      guesses: (json['guesses'] as List?)
        ?.where((g) => g['guess_id'] != null && g['guess_id'].isNotEmpty) 
        .map((g) => Guess.fromJson(g))
        .toList() ?? []
    );
  }

  Map<String, dynamic> toJson() => {
    'instance_id': id,
    'game_id': gameId,
    'player_id': playerId,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime?.toIso8601String(),
    'total_score': totalScore,
    'average_distance': averageDistance,
    'completed': completed,
  };
}
