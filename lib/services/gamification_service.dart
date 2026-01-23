import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/gamification_models.dart';
import 'user_service.dart';

class GamificationService extends ChangeNotifier {
  final UserService _userService;
  
  List<Achievement> _achievements = [];
  List<MiningBoost> _activeBoosts = [];
  GlobalStats _globalStats = GlobalStats(
    totalVoidiumMined: 1250000.0,
    totalUsers: 5432,
    activeMiners: 1234,
    averageMiningRate: 1.5,
  );

  GamificationService(this._userService);

  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();
  List<MiningBoost> get activeBoosts =>
      _activeBoosts.where((b) => b.isActive).toList();
  GlobalStats get globalStats => _globalStats;

  double get currentBoostMultiplier {
    double multiplier = 1.0;
    for (var boost in activeBoosts) {
      multiplier *= boost.multiplier;
    }
    return multiplier;
  }

  Future<void> init() async {
    await _loadAchievements();
    await _loadBoosts();
    await _loadGlobalStats();
    _initializeDefaultAchievements();
  }

  void _initializeDefaultAchievements() {
    if (_achievements.isEmpty) {
      _achievements = [
        // Balance Milestones
        Achievement(
          id: 'milestone_1k',
          title: 'First Thousand',
          description: 'Reach 1,000 VOID',
          type: AchievementType.balanceMilestone,
          target: 1000.0,
          reward: 100.0,
          icon: '🥉',
        ),
        Achievement(
          id: 'milestone_10k',
          title: 'Ten Thousand Club',
          description: 'Reach 10,000 VOID',
          type: AchievementType.balanceMilestone,
          target: 10000.0,
          reward: 500.0,
          icon: '🥈',
        ),
        Achievement(
          id: 'milestone_100k',
          title: 'Crypto Whale',
          description: 'Reach 100,000 VOID',
          type: AchievementType.balanceMilestone,
          target: 100000.0,
          reward: 2000.0,
          icon: '🥇',
        ),

        // Referral Achievements
        Achievement(
          id: 'referral_10',
          title: 'Team Builder',
          description: 'Refer 10 friends',
          type: AchievementType.referralCount,
          target: 10.0,
          reward: 300.0,
          icon: '👥',
        ),
        Achievement(
          id: 'referral_100',
          title: 'Influencer',
          description: 'Refer 100 friends',
          type: AchievementType.referralCount,
          target: 100.0,
          reward: 5000.0,
          icon: '🌟',
        ),

        // Streak Achievements
        Achievement(
          id: 'streak_7',
          title: 'Week Warrior',
          description: '7 day login streak',
          type: AchievementType.streakCount,
          target: 7.0,
          reward: 200.0,
          icon: '🔥',
        ),
        Achievement(
          id: 'streak_30',
          title: 'Monthly Master',
          description: '30 day login streak',
          type: AchievementType.streakCount,
          target: 30.0,
          reward: 1000.0,
          icon: '💎',
        ),
      ];
      _saveAchievements();
    }
  }

  Future<void> checkDailyStreak() async {
    final user = _userService.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final lastCheckIn = user.lastCheckIn;

    if (lastCheckIn == null) {
      // First check-in
      await _userService.updateUser(user.copyWith(
        dailyStreak: 1,
        lastCheckIn: now,
      ));
      notifyListeners();
      return;
    }

    final daysSince = now.difference(lastCheckIn).inDays;

    if (daysSince == 0) {
      // Already checked in today
      return;
    } else if (daysSince == 1) {
      // Consecutive day
      final newStreak = user.dailyStreak + 1;
      await _userService.updateUser(user.copyWith(
        dailyStreak: newStreak,
        lastCheckIn: now,
      ));
      await _checkStreakAchievements(newStreak);
    } else {
      // Streak broken
      await _userService.updateUser(user.copyWith(
        dailyStreak: 1,
        lastCheckIn: now,
      ));
    }

    notifyListeners();
  }

  Future<void> _checkStreakAchievements(int streak) async {
    for (var achievement in _achievements) {
      if (achievement.type == AchievementType.streakCount &&
          !achievement.isUnlocked &&
          streak >= achievement.target) {
        await _unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> checkAchievements() async {
    final user = _userService.currentUser;
    if (user == null) return;

    // Check balance milestones
    for (var achievement in _achievements) {
      if (achievement.isUnlocked) continue;

      switch (achievement.type) {
        case AchievementType.balanceMilestone:
          if (user.voidiumBalance >= achievement.target) {
            await _unlockAchievement(achievement.id);
          }
          break;
        case AchievementType.referralCount:
          if (user.totalReferrals >= achievement.target) {
            await _unlockAchievement(achievement.id);
          }
          break;
        case AchievementType.streakCount:
          if (user.dailyStreak >= achievement.target) {
            await _unlockAchievement(achievement.id);
          }
          break;
        default:
          break;
      }
    }
  }

  Future<void> _unlockAchievement(String id) async {
    final index = _achievements.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final achievement = _achievements[index];
    _achievements[index] = Achievement(
      id: achievement.id,
      title: achievement.title,
      description: achievement.description,
      type: achievement.type,
      target: achievement.target,
      reward: achievement.reward,
      icon: achievement.icon,
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );

    // Award reward
    final user = _userService.currentUser;
    if (user != null) {
      await _userService.updateBalance(user.voidiumBalance + achievement.reward);
    }

    await _saveAchievements();
    notifyListeners();
  }

  Future<void> activateBoost(double multiplier, int durationHours, String source) async {
    final boost = MiningBoost(
      id: 'boost_${DateTime.now().millisecondsSinceEpoch}',
      multiplier: multiplier,
      startTime: DateTime.now(),
      durationHours: durationHours,
      source: source,
    );

    _activeBoosts.add(boost);
    await _saveBoosts();

    // Update mining rate
    final user = _userService.currentUser;
    if (user != null) {
      await _userService.updateMiningRate(user.miningRate * multiplier);
    }

    notifyListeners();
  }

  Future<void> _loadAchievements() async {
    final user = _userService.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('achievements_${user.id}');
    if (json != null) {
      final list = jsonDecode(json) as List;
      _achievements = list.map((e) => Achievement.fromMap(e)).toList();
    }
  }

  Future<void> _saveAchievements() async {
    final user = _userService.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_achievements.map((e) => e.toMap()).toList());
    await prefs.setString('achievements_${user.id}', json);
  }

  Future<void> _loadBoosts() async {
    final user = _userService.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('boosts_${user.id}');
    if (json != null) {
      final list = jsonDecode(json) as List;
      _activeBoosts = list.map((e) => MiningBoost.fromMap(e)).toList();
    }
  }

  Future<void> _saveBoosts() async {
    final user = _userService.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_activeBoosts.map((e) => e.toMap()).toList());
    await prefs.setString('boosts_${user.id}', json);
  }

  Future<void> _loadGlobalStats() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('global_stats');
    if (json != null) {
      _globalStats = GlobalStats.fromMap(jsonDecode(json));
    }
  }

  Future<void> updateGlobalStats(GlobalStats stats) async {
    _globalStats = stats;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('global_stats', jsonEncode(stats.toMap()));
    notifyListeners();
  }
}
