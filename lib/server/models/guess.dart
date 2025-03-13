class Guess {
  final String id;
  final String instanceId;
  final String pictureId;
  final double guessedLatitude;
  final double guessedLongitude;
  final double? distanceMeters;
  final int? score;
  final int? responseTime;
  final DateTime createdAt;

  Guess({
    required this.id,
    required this.instanceId,
    required this.pictureId,
    required this.guessedLatitude,
    required this.guessedLongitude,
    this.distanceMeters,
    this.score,
    this.responseTime,
    required this.createdAt,
  });

  factory Guess.fromJson(Map<String, dynamic> json) {
    // Extract latitude and longitude from PostGIS point
    final String locationStr = json['guessed_location'];
    final RegExp coordRegex = RegExp(r'POINT\(([-\d.]+) ([-\d.]+)\)');
    final Match? match = coordRegex.firstMatch(locationStr);

    if (match == null) {
      throw FormatException('Invalid location format: $locationStr');
    }

    return Guess(
      id: json['guess_id'],
      instanceId: json['instance_id'],
      pictureId: json['picture_id'],
      guessedLatitude: double.parse(match.group(2)!),
      guessedLongitude: double.parse(match.group(1)!),
      distanceMeters: json['distance_meters'],
      score: json['score'],
      responseTime: json['response_time'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'guess_id': id,
    'instance_id': instanceId,
    'picture_id': pictureId,
    'guessed_location': 'POINT($guessedLongitude $guessedLatitude)',
    'distance_meters': distanceMeters,
    'score': score,
    'response_time': responseTime,
    'created_at': createdAt.toIso8601String(),
  };
}
