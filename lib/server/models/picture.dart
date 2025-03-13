class Picture {
  final String id;
  final String? playerId;
  final String storageUrl;
  final double latitude;
  final double longitude;
  final String? title;
  final DateTime createdAt;

  Picture({
    required this.id,
    this.playerId,
    required this.storageUrl,
    required this.latitude,
    required this.longitude,
    this.title,
    required this.createdAt,
  });

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      id: json['picture_id'],
      playerId: json['player_id'],
      storageUrl: json['storage_url'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'picture_id': id,
    'player_id': playerId,
    'storage_url': storageUrl,
    'location': 'POINT($longitude $latitude)',
    'title': title,
    'created_at': createdAt.toIso8601String(),
  };
}
