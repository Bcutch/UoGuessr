class Player {
  final String id;
  final String name;
  final String password;
  final String? biography;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final double? highScore;

  Player({
    required this.id,
    required this.name,
    required this.password,
    this.biography,
    required this.createdAt,
    this.lastLogin,
    this.highScore,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['player_id'],
      name: json['name'],
      password: json['password'],
      biography: json['biography'],
      createdAt: DateTime.parse(json['created_at']),
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      highScore: json['high_score'] != null ? (json['high_score'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'player_id': id,
        'name': name,
        'password': password,
        'biography': biography,
        'created_at': createdAt.toIso8601String(),
        'last_login': lastLogin?.toIso8601String(),
        'high_score': highScore,
      };
}
