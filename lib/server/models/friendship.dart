// Represents a friendship relationship between two players
class Friendship {
  final String id;
  final String fromPlayerId;
  final String toPlayerId;
  final FriendRequestStatus status;
  final DateTime createdAt;

  Friendship({
    required this.id,
    required this.fromPlayerId,
    required this.toPlayerId,
    required this.status,
    required this.createdAt,
  });

  // Create a Friendship instance from JSON data
  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json['friendship_id'],
      fromPlayerId: json['player_id_1'],
      toPlayerId: json['player_id_2'],
      status: FriendRequestStatus.fromJson(json['status']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convert Friendship instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'friendship_id': id,
      'player_id_1': fromPlayerId,
      'player_id_2': toPlayerId,
      'status': status.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper method to check if friendship is accepted
  bool get isAccepted => status == FriendRequestStatus.accepted;

  // Helper method to check if friendship is pending
  bool get isPending => status == FriendRequestStatus.pending;
}

// Enum to represent friendship status
enum FriendRequestStatus {
  accepted,
  pending;

  String toJson() => name;

  static FriendRequestStatus fromJson(String json) {
    return values.firstWhere((e) => e.name == json);
  }
}
