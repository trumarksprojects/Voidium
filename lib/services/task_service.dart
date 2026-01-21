import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task_model.dart';
import 'user_service.dart';

class TaskService extends ChangeNotifier {
  final UserService _userService;
  List<TaskModel> _tasks = [];
  Map<String, UserTaskProgress> _userProgress = {};

  TaskService(this._userService);

  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get dailyTasks =>
      _tasks.where((t) => t.category == TaskCategory.daily && t.isActive).toList();
  List<TaskModel> get weeklyTasks =>
      _tasks.where((t) => t.category == TaskCategory.weekly && t.isActive).toList();
  List<TaskModel> get specialTasks =>
      _tasks.where((t) => t.category == TaskCategory.special && t.isActive).toList();

  Future<void> init() async {
    await _loadTasks();
    await _loadUserProgress();
    _initializeDefaultTasks();
  }

  void _initializeDefaultTasks() {
    if (_tasks.isEmpty) {
      _tasks = [
        // Daily Tasks
        TaskModel(
          id: 'daily_checkin',
          title: 'Daily Check-in',
          description: 'Open the app and claim your daily reward',
          category: TaskCategory.daily,
          type: TaskType.dailyCheckIn,
          rewardAmount: 50.0,
          maxCompletions: 1,
        ),
        TaskModel(
          id: 'daily_mining_claim',
          title: 'Claim Mining Rewards',
          description: 'Claim your mined Voidium tokens',
          category: TaskCategory.daily,
          type: TaskType.inAppActivity,
          rewardAmount: 25.0,
          maxCompletions: 3,
        ),
        
        // Weekly Tasks
        TaskModel(
          id: 'weekly_social_share',
          title: 'Share on Social Media',
          description: 'Share Voidium Miner on your social media',
          category: TaskCategory.weekly,
          type: TaskType.socialShare,
          rewardAmount: 200.0,
          actionUrl: 'https://twitter.com/share?text=Join%20me%20on%20Voidium%20Miner',
        ),
        TaskModel(
          id: 'weekly_invite_friends',
          title: 'Invite 3 Friends',
          description: 'Invite 3 friends to join Voidium Miner',
          category: TaskCategory.weekly,
          type: TaskType.referral,
          rewardAmount: 300.0,
          completionsRequired: 3,
        ),
        TaskModel(
          id: 'weekly_watch_ads',
          title: 'Watch 10 Ads',
          description: 'Watch 10 reward ads to boost your earnings',
          category: TaskCategory.weekly,
          type: TaskType.watchAd,
          rewardAmount: 150.0,
          maxCompletions: 10,
        ),
        
        // Rewarded Ad Tasks (with 1-hour cooldown)
        TaskModel(
          id: 'rewarded_ad_1',
          title: '⭐ Watch Rewarded Ad',
          description: 'Watch an ad and earn 100 VOID (Available every hour)',
          category: TaskCategory.daily,
          type: TaskType.watchAd,
          rewardAmount: 100.0,
          maxCompletions: 999, // Can be repeated
        ),
        TaskModel(
          id: 'rewarded_ad_2',
          title: '💎 Watch Premium Ad',
          description: 'Watch a premium ad and earn 150 VOID (Available every hour)',
          category: TaskCategory.daily,
          type: TaskType.watchAd,
          rewardAmount: 150.0,
          maxCompletions: 999, // Can be repeated
        ),
        
        // Special Tasks
        TaskModel(
          id: 'special_reach_1000',
          title: 'Reach 1,000 VOID',
          description: 'Accumulate 1,000 Voidium tokens',
          category: TaskCategory.special,
          type: TaskType.inAppActivity,
          rewardAmount: 500.0,
        ),
        TaskModel(
          id: 'special_join_team',
          title: 'Join a Team',
          description: 'Join or create a mining team',
          category: TaskCategory.special,
          type: TaskType.inAppActivity,
          rewardAmount: 250.0,
        ),
      ];
      _saveTasks();
    }
  }

  UserTaskProgress? getTaskProgress(String taskId) {
    return _userProgress[taskId];
  }

  bool isTaskCompleted(String taskId) {
    final progress = _userProgress[taskId];
    if (progress == null) return false;
    
    final task = _tasks.firstWhere((t) => t.id == taskId);
    
    // Check if task is repeatable daily/weekly
    if (task.category == TaskCategory.daily) {
      // Reset daily tasks
      if (progress.lastCompletedAt != null) {
        final lastCompleted = progress.lastCompletedAt!;
        final now = DateTime.now();
        if (!_isSameDay(lastCompleted, now)) {
          return false;
        }
      }
    }
    
    return progress.isCompleted || 
           progress.completionCount >= task.maxCompletions;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Future<bool> completeTask(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    final user = _userService.currentUser;
    
    if (user == null) return false;
    if (isTaskCompleted(taskId)) return false;

    // Get or create progress
    var progress = _userProgress[taskId] ?? UserTaskProgress(
      userId: user.id,
      taskId: taskId,
    );

    // Update progress
    progress = UserTaskProgress(
      userId: progress.userId,
      taskId: progress.taskId,
      completionCount: progress.completionCount + 1,
      lastCompletedAt: DateTime.now(),
      isCompleted: progress.completionCount + 1 >= task.completionsRequired,
    );

    _userProgress[taskId] = progress;
    await _saveUserProgress();

    // Award reward
    final newBalance = user.voidiumBalance + task.rewardAmount;
    await _userService.updateBalance(newBalance);

    notifyListeners();
    return true;
  }

  Future<void> addCustomTask(TaskModel task) async {
    if (!_userService.isAdmin) return;
    
    _tasks.add(task);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> removeTask(String taskId) async {
    if (!_userService.isAdmin) return;
    
    _tasks.removeWhere((t) => t.id == taskId);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final tasksList = json.decode(tasksJson) as List;
      _tasks = tasksList.map((t) => TaskModel.fromMap(t)).toList();
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = json.encode(_tasks.map((t) => t.toMap()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  Future<void> _loadUserProgress() async {
    final user = _userService.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString('user_progress_${user.id}');
    if (progressJson != null) {
      final progressMap = json.decode(progressJson) as Map<String, dynamic>;
      _userProgress = progressMap.map((key, value) =>
          MapEntry(key, UserTaskProgress.fromMap(value)));
    }
  }

  Future<void> _saveUserProgress() async {
    final user = _userService.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final progressJson = json.encode(
      _userProgress.map((key, value) => MapEntry(key, value.toMap())),
    );
    await prefs.setString('user_progress_${user.id}', progressJson);
  }
}
