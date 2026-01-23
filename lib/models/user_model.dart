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
  final int dailyStreak;
  final DateTime? lastCheckIn;
  final bool kycEligible;
  final bool kycSubmitted;
  final bool kycApproved;

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
    this.dailyStreak = 0,
    this.lastCheckIn,
    this.kycEligible = false,
    this.kycSubmitted = false,
    this.kycApproved = false,
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
      'dailyStreak': dailyStreak,
      'lastCheckIn': lastCheckIn?.toIso8601String(),
      'kycEligible': kycEligible,
      'kycSubmitted': kycSubmitted,
      'kycApproved': kycApproved,
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
      dailyStreak: map['dailyStreak'] ?? 0,
      lastCheckIn:
          map['lastCheckIn'] != null ? DateTime.parse(map['lastCheckIn']) : null,
      kycEligible: map['kycEligible'] ?? false,
      kycSubmitted: map['kycSubmitted'] ?? false,
      kycApproved: map['kycApproved'] ?? false,
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
    int? dailyStreak,
    DateTime? lastCheckIn,
    bool? kycEligible,
    bool? kycSubmitted,
    bool? kycApproved,
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
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      kycEligible: kycEligible ?? this.kycEligible,
      kycSubmitted: kycSubmitted ?? this.kycSubmitted,
      kycApproved: kycApproved ?? this.kycApproved,
    );
  }
}
