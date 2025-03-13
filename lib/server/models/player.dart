class Player {
  final String id;
  final String name;
  final String? biography;
  final DateTime createdAt;
  final DateTime? lastLogin;

  Player({
    required this.id,
    required this.name,
    this.biography,
    required this.createdAt,
    this.lastLogin,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['player_id'],
      name: json['name'],
      biography: json['biography'],
      createdAt: DateTime.parse(json['created_at']),
      lastLogin:
          json['last_login'] != null
              ? DateTime.parse(json['last_login'])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'player_id': id,
    'name': name,
    'biography': biography,
    'created_at': createdAt.toIso8601String(),
    'last_login': lastLogin?.toIso8601String(),
  };
}
