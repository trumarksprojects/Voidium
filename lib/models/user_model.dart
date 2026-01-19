class UserModel {
  final String id;
  final String username;
  final String email;
  final double voidiumBalance;
  final double miningRate; // VOID per hour
  final DateTime lastClaimTime;
  final int level;
  final int totalReferrals;
  final String? referredBy;
  final String? teamId;
  final DateTime joinedDate;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.voidiumBalance = 0.0,
    this.miningRate = 1.0,
    required this.lastClaimTime,
    this.level = 1,
    this.totalReferrals = 0,
    this.referredBy,
    this.teamId,
    required this.joinedDate,
    this.isAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'voidiumBalance': voidiumBalance,
      'miningRate': miningRate,
      'lastClaimTime': lastClaimTime.toIso8601String(),
      'level': level,
      'totalReferrals': totalReferrals,
      'referredBy': referredBy,
      'teamId': teamId,
      'joinedDate': joinedDate.toIso8601String(),
      'isAdmin': isAdmin,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      voidiumBalance: (map['voidiumBalance'] ?? 0.0).toDouble(),
      miningRate: (map['miningRate'] ?? 1.0).toDouble(),
      lastClaimTime: DateTime.parse(map['lastClaimTime']),
      level: map['level'] ?? 1,
      totalReferrals: map['totalReferrals'] ?? 0,
      referredBy: map['referredBy'],
      teamId: map['teamId'],
      joinedDate: DateTime.parse(map['joinedDate']),
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    double? voidiumBalance,
    double? miningRate,
    DateTime? lastClaimTime,
    int? level,
    int? totalReferrals,
    String? referredBy,
    String? teamId,
    DateTime? joinedDate,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      voidiumBalance: voidiumBalance ?? this.voidiumBalance,
      miningRate: miningRate ?? this.miningRate,
      lastClaimTime: lastClaimTime ?? this.lastClaimTime,
      level: level ?? this.level,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      referredBy: referredBy ?? this.referredBy,
      teamId: teamId ?? this.teamId,
      joinedDate: joinedDate ?? this.joinedDate,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
