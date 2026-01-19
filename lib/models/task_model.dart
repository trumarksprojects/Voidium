enum TaskCategory { daily, weekly, special }

enum TaskType {
  dailyCheckIn,
  socialShare,
  referral,
  watchAd,
  inAppActivity,
  custom
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskType type;
  final double rewardAmount;
  final bool isActive;
  final DateTime? expiryDate;
  final String? actionUrl; // For social shares or external links
  final int maxCompletions; // -1 for unlimited
  final int completionsRequired; // For tasks like "Refer 5 friends"

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.rewardAmount,
    this.isActive = true,
    this.expiryDate,
    this.actionUrl,
    this.maxCompletions = 1,
    this.completionsRequired = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'type': type.name,
      'rewardAmount': rewardAmount,
      'isActive': isActive,
      'expiryDate': expiryDate?.toIso8601String(),
      'actionUrl': actionUrl,
      'maxCompletions': maxCompletions,
      'completionsRequired': completionsRequired,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TaskCategory.daily,
      ),
      type: TaskType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TaskType.custom,
      ),
      rewardAmount: (map['rewardAmount'] ?? 0.0).toDouble(),
      isActive: map['isActive'] ?? true,
      expiryDate:
          map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      actionUrl: map['actionUrl'],
      maxCompletions: map['maxCompletions'] ?? 1,
      completionsRequired: map['completionsRequired'] ?? 1,
    );
  }
}

class UserTaskProgress {
  final String userId;
  final String taskId;
  final int completionCount;
  final DateTime? lastCompletedAt;
  final bool isCompleted;

  UserTaskProgress({
    required this.userId,
    required this.taskId,
    this.completionCount = 0,
    this.lastCompletedAt,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'taskId': taskId,
      'completionCount': completionCount,
      'lastCompletedAt': lastCompletedAt?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory UserTaskProgress.fromMap(Map<String, dynamic> map) {
    return UserTaskProgress(
      userId: map['userId'] ?? '',
      taskId: map['taskId'] ?? '',
      completionCount: map['completionCount'] ?? 0,
      lastCompletedAt: map['lastCompletedAt'] != null
          ? DateTime.parse(map['lastCompletedAt'])
          : null,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
