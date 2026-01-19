import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/team_model.dart';
import 'user_service.dart';

class LeaderboardService extends ChangeNotifier {
  final UserService _userService;
  List<LeaderboardEntry> _globalLeaderboard = [];
  List<TeamModel> _teamLeaderboard = [];

  LeaderboardService(this._userService);

  List<LeaderboardEntry> get globalLeaderboard => _globalLeaderboard;
  List<TeamModel> get teamLeaderboard => _teamLeaderboard;

  Future<void> init() async {
    await _loadLeaderboards();
    _initializeMockData();
  }

  void _initializeMockData() {
    if (_globalLeaderboard.isEmpty) {
      // Add current user if exists
      final user = _userService.currentUser;
      if (user != null) {
        _globalLeaderboard.add(LeaderboardEntry(
          userId: user.id,
          username: user.username,
          voidiumBalance: user.voidiumBalance,
          rank: 1,
          teamId: user.teamId,
        ));
      }

      // Add mock top miners
      _globalLeaderboard.addAll([
        LeaderboardEntry(
          userId: 'mock_1',
          username: 'VoidMaster',
          voidiumBalance: 125487.50,
          rank: 1,
        ),
        LeaderboardEntry(
          userId: 'mock_2',
          username: 'CryptoNinja',
          voidiumBalance: 98234.25,
          rank: 2,
        ),
        LeaderboardEntry(
          userId: 'mock_3',
          username: 'MiningPro',
          voidiumBalance: 87456.80,
          rank: 3,
        ),
        LeaderboardEntry(
          userId: 'mock_4',
          username: 'TokenHunter',
          voidiumBalance: 76543.15,
          rank: 4,
        ),
        LeaderboardEntry(
          userId: 'mock_5',
          username: 'VoidCollector',
          voidiumBalance: 65234.90,
          rank: 5,
        ),
      ]);

      _saveGlobalLeaderboard();
    }

    if (_teamLeaderboard.isEmpty) {
      _teamLeaderboard.addAll([
        TeamModel(
          id: 'team_1',
          name: 'Void Warriors',
          description: 'Elite mining team',
          leaderId: 'mock_1',
          memberIds: ['mock_1', 'mock_2', 'mock_3'],
          totalVoidiumMined: 311178.55,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        TeamModel(
          id: 'team_2',
          name: 'Token Titans',
          description: 'Top tier miners',
          leaderId: 'mock_4',
          memberIds: ['mock_4', 'mock_5'],
          totalVoidiumMined: 141778.05,
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
        ),
      ]);

      _saveTeamLeaderboard();
    }
  }

  Future<void> updateUserRank(String userId, double newBalance) async {
    // Find and update user entry
    final index = _globalLeaderboard.indexWhere((e) => e.userId == userId);
    if (index != -1) {
      final entry = _globalLeaderboard[index];
      _globalLeaderboard[index] = LeaderboardEntry(
        userId: entry.userId,
        username: entry.username,
        voidiumBalance: newBalance,
        rank: entry.rank,
        teamId: entry.teamId,
        teamName: entry.teamName,
      );
    }

    // Sort and update ranks
    _globalLeaderboard.sort((a, b) => b.voidiumBalance.compareTo(a.voidiumBalance));
    for (int i = 0; i < _globalLeaderboard.length; i++) {
      final entry = _globalLeaderboard[i];
      _globalLeaderboard[i] = LeaderboardEntry(
        userId: entry.userId,
        username: entry.username,
        voidiumBalance: entry.voidiumBalance,
        rank: i + 1,
        teamId: entry.teamId,
        teamName: entry.teamName,
      );
    }

    await _saveGlobalLeaderboard();
    notifyListeners();
  }

  int? getUserRank(String userId) {
    final entry = _globalLeaderboard.firstWhere(
      (e) => e.userId == userId,
      orElse: () => LeaderboardEntry(
        userId: '',
        username: '',
        voidiumBalance: 0,
        rank: 0,
      ),
    );
    return entry.rank > 0 ? entry.rank : null;
  }

  List<LeaderboardEntry> getTopMiners({int limit = 10}) {
    return _globalLeaderboard.take(limit).toList();
  }

  Future<void> _loadLeaderboards() async {
    final prefs = await SharedPreferences.getInstance();
    
    final globalJson = prefs.getString('global_leaderboard');
    if (globalJson != null) {
      final list = json.decode(globalJson) as List;
      _globalLeaderboard = list.map((e) => LeaderboardEntry.fromMap(e)).toList();
    }

    final teamJson = prefs.getString('team_leaderboard');
    if (teamJson != null) {
      final list = json.decode(teamJson) as List;
      _teamLeaderboard = list.map((e) => TeamModel.fromMap(e)).toList();
    }
  }

  Future<void> _saveGlobalLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_globalLeaderboard.map((e) => e.toMap()).toList());
    await prefs.setString('global_leaderboard', json);
  }

  Future<void> _saveTeamLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_teamLeaderboard.map((e) => e.toMap()).toList());
    await prefs.setString('team_leaderboard', json);
  }
}
