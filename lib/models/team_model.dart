class TeamModel {
  final String id;
  final String name;
  final String description;
  final String leaderId;
  final List<String> memberIds;
  final double totalVoidiumMined;
  final DateTime createdAt;
  final String? imageUrl;

  TeamModel({
    required this.id,
    required this.name,
    required this.description,
    required this.leaderId,
    required this.memberIds,
    this.totalVoidiumMined = 0.0,
    required this.createdAt,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'leaderId': leaderId,
      'memberIds': memberIds,
      'totalVoidiumMined': totalVoidiumMined,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory TeamModel.fromMap(Map<String, dynamic> map) {
    return TeamModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      leaderId: map['leaderId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      totalVoidiumMined: (map['totalVoidiumMined'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      imageUrl: map['imageUrl'],
    );
  }
}

class LeaderboardEntry {
  final String userId;
  final String username;
  final double voidiumBalance;
  final int rank;
  final String? teamId;
  final String? teamName;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.voidiumBalance,
    required this.rank,
    this.teamId,
    this.teamName,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'voidiumBalance': voidiumBalance,
      'rank': rank,
      'teamId': teamId,
      'teamName': teamName,
    };
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      voidiumBalance: (map['voidiumBalance'] ?? 0.0).toDouble(),
      rank: map['rank'] ?? 0,
      teamId: map['teamId'],
      teamName: map['teamName'],
    );
  }
}
