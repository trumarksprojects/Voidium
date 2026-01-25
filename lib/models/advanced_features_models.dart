import 'dart:math' as math;
import 'package:flutter/material.dart';

// Energy System for Mini Games
class EnergySystem {
  final int maxEnergy;
  final int currentEnergy;
  final DateTime lastRegenTime;
  final int regenRateMinutes; // Energy regeneration rate

  EnergySystem({
    this.maxEnergy = 100,
    this.currentEnergy = 100,
    required this.lastRegenTime,
    this.regenRateMinutes = 5, // 1 energy every 5 minutes
  });

  int get availableEnergy {
    final now = DateTime.now();
    final minutesPassed = now.difference(lastRegenTime).inMinutes;
    final regenerated = (minutesPassed / regenRateMinutes).floor();
    return math.min(maxEnergy, currentEnergy + regenerated);
  }

  Duration get timeToNextRegen {
    final minutesPassed = DateTime.now().difference(lastRegenTime).inMinutes;
    final minutesUntilNext = regenRateMinutes - (minutesPassed % regenRateMinutes);
    return Duration(minutes: minutesUntilNext);
  }

  Map<String, dynamic> toMap() {
    return {
      'maxEnergy': maxEnergy,
      'currentEnergy': currentEnergy,
      'lastRegenTime': lastRegenTime.toIso8601String(),
      'regenRateMinutes': regenRateMinutes,
    };
  }

  factory EnergySystem.fromMap(Map<String, dynamic> map) {
    return EnergySystem(
      maxEnergy: map['maxEnergy'] ?? 100,
      currentEnergy: map['currentEnergy'] ?? 100,
      lastRegenTime: DateTime.parse(map['lastRegenTime']),
      regenRateMinutes: map['regenRateMinutes'] ?? 5,
    );
  }
}

// Battle Pass System
enum BattlePassTier { free, premium }

// Simplified BattlePass for service
class BattlePass {
  final String id;
  final String seasonName;
  int currentTier;
  int xp;
  bool isPremium;
  final DateTime startDate;
  final DateTime endDate;

  BattlePass({
    required this.id,
    required this.seasonName,
    this.currentTier = 0,
    this.xp = 0,
    this.isPremium = false,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seasonName': seasonName,
      'currentTier': currentTier,
      'xp': xp,
      'isPremium': isPremium,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory BattlePass.fromJson(Map<String, dynamic> json) {
    return BattlePass(
      id: json['id'] ?? '',
      seasonName: json['seasonName'] ?? '',
      currentTier: json['currentTier'] ?? 0,
      xp: json['xp'] ?? 0,
      isPremium: json['isPremium'] ?? false,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}

// Battle Pass Tier Rewards
class BattlePassTier {
  final int tier;
  final int xpRequired;
  final BattlePassReward freeReward;
  final BattlePassReward premiumReward;

  BattlePassTier({
    required this.tier,
    required this.xpRequired,
    required this.freeReward,
    required this.premiumReward,
  });

  Map<String, dynamic> toJson() {
    return {
      'tier': tier,
      'xpRequired': xpRequired,
      'freeReward': freeReward.toJson(),
      'premiumReward': premiumReward.toJson(),
    };
  }

  factory BattlePassTier.fromJson(Map<String, dynamic> json) {
    return BattlePassTier(
      tier: json['tier'] ?? 1,
      xpRequired: json['xpRequired'] ?? 1000,
      freeReward: BattlePassReward.fromJson(json['freeReward']),
      premiumReward: BattlePassReward.fromJson(json['premiumReward']),
    );
  }
}

// Battle Pass Reward (simplified for service)
class BattlePassReward {
  final String type;
  final double amount;
  final String name;

  BattlePassReward({
    required this.type,
    required this.amount,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'name': name,
    };
  }

  factory BattlePassReward.fromJson(Map<String, dynamic> json) {
    return BattlePassReward(
      type: json['type'] ?? 'VOID',
      amount: (json['amount'] ?? 0.0).toDouble(),
      name: json['name'] ?? '',
    );
  }
}

class OldBattlePassSeason {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final List<BattlePassReward> rewards;
  final int currentLevel;
  final int maxLevel;

  BattlePassSeason({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.rewards,
    this.currentLevel = 1,
    this.maxLevel = 50,
  });

  bool get isActive => DateTime.now().isBefore(endDate) && DateTime.now().isAfter(startDate);
  Duration get timeRemaining => endDate.difference(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'rewards': rewards.map((r) => r.toMap()).toList(),
      'currentLevel': currentLevel,
      'maxLevel': maxLevel,
    };
  }

  factory BattlePassSeason.fromMap(Map<String, dynamic> map) {
    return BattlePassSeason(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      rewards: (map['rewards'] as List).map((r) => BattlePassReward.fromMap(r)).toList(),
      currentLevel: map['currentLevel'] ?? 1,
      maxLevel: map['maxLevel'] ?? 50,
    );
  }
}

// Loot Box System
enum LootBoxRarity { common, rare, epic, legendary }

class LootBox {
  final String id;
  final String name;
  final LootBoxRarity rarity;
  final double priceUSD;
  final List<LootBoxReward> possibleRewards;

  LootBox({
    required this.id,
    required this.name,
    required this.rarity,
    required this.priceUSD,
    required this.possibleRewards,
  });

  Color get rarityColor {
    switch (rarity) {
      case LootBoxRarity.common:
        return const Color(0xFF9CA3AF);
      case LootBoxRarity.rare:
        return const Color(0xFF3B82F6);
      case LootBoxRarity.epic:
        return const Color(0xFF8B5CF6);
      case LootBoxRarity.legendary:
        return const Color(0xFFFFD700);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rarity': rarity.name,
      'priceUSD': priceUSD,
      'possibleRewards': possibleRewards.map((r) => r.toMap()).toList(),
    };
  }

  factory LootBox.fromMap(Map<String, dynamic> map) {
    return LootBox(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      rarity: LootBoxRarity.values.firstWhere((e) => e.name == map['rarity']),
      priceUSD: (map['priceUSD'] ?? 0.0).toDouble(),
      possibleRewards: (map['possibleRewards'] as List)
          .map((r) => LootBoxReward.fromMap(r))
          .toList(),
    );
  }
}

class LootBoxReward {
  final String rewardType;
  final double amount;
  final double dropChance; // 0.0 to 1.0

  LootBoxReward({
    required this.rewardType,
    required this.amount,
    required this.dropChance,
  });

  Map<String, dynamic> toMap() {
    return {
      'rewardType': rewardType,
      'amount': amount,
      'dropChance': dropChance,
    };
  }

  factory LootBoxReward.fromMap(Map<String, dynamic> map) {
    return LootBoxReward(
      rewardType: map['rewardType'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      dropChance: (map['dropChance'] ?? 0.0).toDouble(),
    );
  }
}

// In-App Purchase Packages
class InAppPurchase {
  final String id;
  final String name;
  final String description;
  final double priceUSD;
  final String priceType; // 'USD' or 'USDT'
  final Duration? duration; // null for permanent or instant
  final List<String> benefits;

  InAppPurchase({
    required this.id,
    required this.name,
    required this.description,
    required this.priceUSD,
    required this.priceType,
    this.duration,
    required this.benefits,
  });

  bool get isPermanent => duration == null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'priceUSD': priceUSD,
      'priceType': priceType,
      'duration': duration?.inHours,
      'benefits': benefits,
    };
  }

  factory InAppPurchase.fromJson(Map<String, dynamic> json) {
    return InAppPurchase(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priceUSD: (json['priceUSD'] ?? 0.0).toDouble(),
      priceType: json['priceType'] ?? 'USD',
      duration: json['duration'] != null ? Duration(hours: json['duration']) : null,
      benefits: List<String>.from(json['benefits'] ?? []),
    );
  }
}

// Purchase History
class PurchaseHistory {
  final String id;
  final String purchaseId;
  final String purchaseName;
  final double priceUSD;
  final String priceType;
  final DateTime purchaseDate;
  final String status; // 'completed', 'pending', 'failed'

  PurchaseHistory({
    required this.id,
    required this.purchaseId,
    required this.purchaseName,
    required this.priceUSD,
    required this.priceType,
    required this.purchaseDate,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchaseId': purchaseId,
      'purchaseName': purchaseName,
      'priceUSD': priceUSD,
      'priceType': priceType,
      'purchaseDate': purchaseDate.toIso8601String(),
      'status': status,
    };
  }

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) {
    return PurchaseHistory(
      id: json['id'] ?? '',
      purchaseId: json['purchaseId'] ?? '',
      purchaseName: json['purchaseName'] ?? '',
      priceUSD: (json['priceUSD'] ?? 0.0).toDouble(),
      priceType: json['priceType'] ?? 'USD',
      purchaseDate: DateTime.parse(json['purchaseDate']),
      status: json['status'] ?? 'pending',
    );
  }
}

class PurchasePackage {
  final String id;
  final String name;
  final String description;
  final double priceUSD;
  final String packageType; // 'ad_free', 'double_rewards', 'accelerator'
  final int? durationHours; // null for permanent
  final Map<String, dynamic> benefits;

  PurchasePackage({
    required this.id,
    required this.name,
    required this.description,
    required this.priceUSD,
    required this.packageType,
    this.durationHours,
    required this.benefits,
  });

  bool get isPermanent => durationHours == null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'priceUSD': priceUSD,
      'packageType': packageType,
      'durationHours': durationHours,
      'benefits': benefits,
    };
  }

  factory PurchasePackage.fromMap(Map<String, dynamic> map) {
    return PurchasePackage(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      priceUSD: (map['priceUSD'] ?? 0.0).toDouble(),
      packageType: map['packageType'] ?? '',
      durationHours: map['durationHours'],
      benefits: Map<String, dynamic>.from(map['benefits'] ?? {}),
    );
  }
}

// Guild System
class Guild {
  final String id;
  final String name;
  final String description;
  final String leaderId;
  final List<String> memberIds;
  final double sharedTreasury;
  final int level;
  final String? iconUrl;
  final DateTime createdAt;
  final Map<String, double> memberContributions;

  Guild({
    required this.id,
    required this.name,
    required this.description,
    required this.leaderId,
    required this.memberIds,
    this.sharedTreasury = 0.0,
    this.level = 1,
    this.iconUrl,
    required this.createdAt,
    required this.memberContributions,
  });

  int get memberCount => memberIds.length;
  int get maxMembers => level * 10; // 10 members per guild level

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'leaderId': leaderId,
      'memberIds': memberIds,
      'sharedTreasury': sharedTreasury,
      'level': level,
      'iconUrl': iconUrl,
      'createdAt': createdAt.toIso8601String(),
      'memberContributions': memberContributions,
    };
  }

  factory Guild.fromMap(Map<String, dynamic> map) {
    return Guild(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      leaderId: map['leaderId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      sharedTreasury: (map['sharedTreasury'] ?? 0.0).toDouble(),
      level: map['level'] ?? 1,
      iconUrl: map['iconUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      memberContributions: Map<String, double>.from(map['memberContributions'] ?? {}),
    );
  }
}

// Social Leaderboard Tiers
enum LeaderboardTier { bronze, silver, gold, diamond, legendary }

class TieredLeaderboardEntry {
  final String userId;
  final String username;
  final double voidiumBalance;
  final int rank;
  final LeaderboardTier tier;

  TieredLeaderboardEntry({
    required this.userId,
    required this.username,
    required this.voidiumBalance,
    required this.rank,
    required this.tier,
  });

  static LeaderboardTier getTierByRank(int rank) {
    if (rank <= 10) return LeaderboardTier.legendary;
    if (rank <= 50) return LeaderboardTier.diamond;
    if (rank <= 200) return LeaderboardTier.gold;
    if (rank <= 1000) return LeaderboardTier.silver;
    return LeaderboardTier.bronze;
  }

  Color get tierColor {
    switch (tier) {
      case LeaderboardTier.bronze:
        return const Color(0xFFCD7F32);
      case LeaderboardTier.silver:
        return const Color(0xFFC0C0C0);
      case LeaderboardTier.gold:
        return const Color(0xFFFFD700);
      case LeaderboardTier.diamond:
        return const Color(0xFFB9F2FF);
      case LeaderboardTier.legendary:
        return const Color(0xFFFF00FF);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'voidiumBalance': voidiumBalance,
      'rank': rank,
      'tier': tier.name,
    };
  }

  factory TieredLeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return TieredLeaderboardEntry(
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      voidiumBalance: (map['voidiumBalance'] ?? 0.0).toDouble(),
      rank: map['rank'] ?? 0,
      tier: LeaderboardTier.values.firstWhere((e) => e.name == map['tier']),
    );
  }
}

// Daily Login Calendar
class DailyLoginCalendar {
  final Map<int, DailyReward> rewards; // day -> reward
  final Set<int> claimedDays;
  final int currentDay;

  DailyLoginCalendar({
    required this.rewards,
    required this.claimedDays,
    this.currentDay = 1,
  });

  bool isDayClaimed(int day) => claimedDays.contains(day);
  bool isCurrentDay(int day) => day == currentDay;
  bool canClaim(int day) => day == currentDay && !isDayClaimed(day);

  Map<String, dynamic> toMap() {
    return {
      'rewards': rewards.map((k, v) => MapEntry(k.toString(), v.toMap())),
      'claimedDays': claimedDays.toList(),
      'currentDay': currentDay,
    };
  }

  factory DailyLoginCalendar.fromMap(Map<String, dynamic> map) {
    return DailyLoginCalendar(
      rewards: (map['rewards'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(int.parse(k), DailyReward.fromMap(v)),
      ),
      claimedDays: Set<int>.from(map['claimedDays'] ?? []),
      currentDay: map['currentDay'] ?? 1,
    );
  }
}

class DailyReward {
  final double voidAmount;
  final String? bonusType; // 'boost', 'energy', null
  final double? bonusAmount;

  DailyReward({
    required this.voidAmount,
    this.bonusType,
    this.bonusAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'voidAmount': voidAmount,
      'bonusType': bonusType,
      'bonusAmount': bonusAmount,
    };
  }

  factory DailyReward.fromMap(Map<String, dynamic> map) {
    return DailyReward(
      voidAmount: (map['voidAmount'] ?? 0.0).toDouble(),
      bonusType: map['bonusType'],
      bonusAmount: map['bonusAmount'] != null
          ? (map['bonusAmount'] as num).toDouble()
          : null,
    );
  }
}
