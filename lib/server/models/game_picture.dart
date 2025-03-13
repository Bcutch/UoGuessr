class GamePicture {
  final String gameId;
  final String pictureId;
  final int sequenceNumber;

  GamePicture({
    required this.gameId,
    required this.pictureId,
    required this.sequenceNumber,
  });

  factory GamePicture.fromJson(Map<String, dynamic> json) {
    return GamePicture(
      gameId: json['game_id'],
      pictureId: json['picture_id'],
      sequenceNumber: json['sequence_number'],
    );
  }

  Map<String, dynamic> toJson() => {
    'game_id': gameId,
    'picture_id': pictureId,
    'sequence_number': sequenceNumber,
  };
}
