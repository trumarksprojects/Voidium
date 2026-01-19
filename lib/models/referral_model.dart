class ReferralModel {
  final String id;
  final String referrerId;
  final String referredUserId;
  final DateTime referralDate;
  final double bonusEarned;
  final bool isActive;

  ReferralModel({
    required this.id,
    required this.referrerId,
    required this.referredUserId,
    required this.referralDate,
    this.bonusEarned = 100.0, // Default referral bonus
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'referrerId': referrerId,
      'referredUserId': referredUserId,
      'referralDate': referralDate.toIso8601String(),
      'bonusEarned': bonusEarned,
      'isActive': isActive,
    };
  }

  factory ReferralModel.fromMap(Map<String, dynamic> map) {
    return ReferralModel(
      id: map['id'] ?? '',
      referrerId: map['referrerId'] ?? '',
      referredUserId: map['referredUserId'] ?? '',
      referralDate: DateTime.parse(map['referralDate']),
      bonusEarned: (map['bonusEarned'] ?? 100.0).toDouble(),
      isActive: map['isActive'] ?? true,
    );
  }
}

class MiningSession {
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final double voidiumMined;
  final double miningRate;

  MiningSession({
    required this.userId,
    required this.startTime,
    this.endTime,
    this.voidiumMined = 0.0,
    required this.miningRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'voidiumMined': voidiumMined,
      'miningRate': miningRate,
    };
  }

  factory MiningSession.fromMap(Map<String, dynamic> map) {
    return MiningSession(
      userId: map['userId'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      voidiumMined: (map['voidiumMined'] ?? 0.0).toDouble(),
      miningRate: (map['miningRate'] ?? 1.0).toDouble(),
    );
  }
}
