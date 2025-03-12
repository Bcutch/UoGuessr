enum GameMode { daily, unlimited, findIt }

class Game {
  final String id;
  final GameMode mode;
  final DateTime createdAt;
  final DateTime? validFrom;
  final DateTime? validUntil;

  Game({
    required this.id,
    required this.mode,
    required this.createdAt,
    this.validFrom,
    this.validUntil,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['game_id'],
      mode: GameMode.values.firstWhere(
        (e) => e.toString().split('.').last == json['mode'],
        orElse: () => GameMode.unlimited,
      ),
      createdAt: DateTime.parse(json['created_at']),
      validFrom:
          json['valid_from'] != null
              ? DateTime.parse(json['valid_from'])
              : null,
      validUntil:
          json['valid_until'] != null
              ? DateTime.parse(json['valid_until'])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'game_id': id,
    'mode': mode.toString().split('.').last,
    'created_at': createdAt.toIso8601String(),
    'valid_from': validFrom?.toIso8601String(),
    'valid_until': validUntil?.toIso8601String(),
  };
}
