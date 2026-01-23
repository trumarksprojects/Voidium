class DailyStreak {
  final int currentStreak;
  final DateTime lastCheckIn;
  final int longestStreak;
  final double streakMultiplier;

  DailyStreak({
    this.currentStreak = 0,
    required this.lastCheckIn,
    this.longestStreak = 0,
    this.streakMultiplier = 1.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'lastCheckIn': lastCheckIn.toIso8601String(),
      'longestStreak': longestStreak,
      'streakMultiplier': streakMultiplier,
    };
  }

  factory DailyStreak.fromMap(Map<String, dynamic> map) {
    return DailyStreak(
      currentStreak: map['currentStreak'] ?? 0,
      lastCheckIn: DateTime.parse(map['lastCheckIn']),
      longestStreak: map['longestStreak'] ?? 0,
      streakMultiplier: (map['streakMultiplier'] ?? 1.0).toDouble(),
    );
  }

  // Calculate multiplier based on streak
  static double getMultiplier(int streak) {
    if (streak >= 30) return 3.0;
    if (streak >= 14) return 2.5;
    if (streak >= 7) return 2.0;
    if (streak >= 3) return 1.5;
    return 1.0;
  }
}

enum AchievementType {
  balanceMilestone,
  referralCount,
  streakCount,
  taskCompletion,
  gameScore,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final double target;
  final double reward;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.reward,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'target': target,
      'reward': reward,
      'icon': icon,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: AchievementType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AchievementType.balanceMilestone,
      ),
      target: (map['target'] ?? 0.0).toDouble(),
      reward: (map['reward'] ?? 0.0).toDouble(),
      icon: map['icon'] ?? '🏆',
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt:
          map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt']) : null,
    );
  }
}

class MiningBoost {
  final String id;
  final double multiplier;
  final DateTime startTime;
  final int durationHours;
  final String source; // 'purchase', 'task', 'achievement'

  MiningBoost({
    required this.id,
    required this.multiplier,
    required this.startTime,
    required this.durationHours,
    required this.source,
  });

  DateTime get endTime => startTime.add(Duration(hours: durationHours));
  bool get isActive => DateTime.now().isBefore(endTime);
  Duration get remaining => endTime.difference(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'multiplier': multiplier,
      'startTime': startTime.toIso8601String(),
      'durationHours': durationHours,
      'source': source,
    };
  }

  factory MiningBoost.fromMap(Map<String, dynamic> map) {
    return MiningBoost(
      id: map['id'] ?? '',
      multiplier: (map['multiplier'] ?? 1.0).toDouble(),
      startTime: DateTime.parse(map['startTime']),
      durationHours: map['durationHours'] ?? 24,
      source: map['source'] ?? 'purchase',
    );
  }
}

class KYCStatus {
  final bool isEligible;
  final bool isSubmitted;
  final bool isApproved;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final String? rejectionReason;

  KYCStatus({
    this.isEligible = false,
    this.isSubmitted = false,
    this.isApproved = false,
    this.submittedAt,
    this.approvedAt,
    this.rejectionReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'isEligible': isEligible,
      'isSubmitted': isSubmitted,
      'isApproved': isApproved,
      'submittedAt': submittedAt?.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  factory KYCStatus.fromMap(Map<String, dynamic> map) {
    return KYCStatus(
      isEligible: map['isEligible'] ?? false,
      isSubmitted: map['isSubmitted'] ?? false,
      isApproved: map['isApproved'] ?? false,
      submittedAt:
          map['submittedAt'] != null ? DateTime.parse(map['submittedAt']) : null,
      approvedAt:
          map['approvedAt'] != null ? DateTime.parse(map['approvedAt']) : null,
      rejectionReason: map['rejectionReason'],
    );
  }

  String get statusText {
    if (isApproved) return 'Verified';
    if (isSubmitted) return 'Pending Review';
    if (isEligible) return 'Eligible';
    return 'Not Eligible';
  }
}

class GlobalStats {
  final double totalVoidiumMined;
  final int totalUsers;
  final int activeMiners;
  final double averageMiningRate;

  GlobalStats({
    this.totalVoidiumMined = 0.0,
    this.totalUsers = 0,
    this.activeMiners = 0,
    this.averageMiningRate = 1.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalVoidiumMined': totalVoidiumMined,
      'totalUsers': totalUsers,
      'activeMiners': activeMiners,
      'averageMiningRate': averageMiningRate,
    };
  }

  factory GlobalStats.fromMap(Map<String, dynamic> map) {
    return GlobalStats(
      totalVoidiumMined: (map['totalVoidiumMined'] ?? 0.0).toDouble(),
      totalUsers: map['totalUsers'] ?? 0,
      activeMiners: map['activeMiners'] ?? 0,
      averageMiningRate: (map['averageMiningRate'] ?? 1.0).toDouble(),
    );
  }
}
