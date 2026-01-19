import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/task_service.dart';
import '../../models/task_model.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskService = context.watch<TaskService>();
    final format = NumberFormat('#,##0');

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks & Rewards'),
          bottom: const TabBar(
            indicatorColor: Color(0xFF06B6D4),
            labelColor: Color(0xFF06B6D4),
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Special'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTaskList(context, taskService.dailyTasks, taskService, format),
            _buildTaskList(context, taskService.weeklyTasks, taskService, format),
            _buildTaskList(context, taskService.specialTasks, taskService, format),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    List<TaskModel> tasks,
    TaskService taskService,
    NumberFormat format,
  ) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks available',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isCompleted = taskService.isTaskCompleted(task.id);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1F3A).withValues(alpha: 0.6),
                const Color(0xFF1A1F3A).withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFF06B6D4).withValues(alpha: 0.5)
                  : const Color(0xFF8B5CF6).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isCompleted
                      ? [const Color(0xFF06B6D4), const Color(0xFF0891B2)]
                      : [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : _getTaskIcon(task.type),
                color: Colors.white,
              ),
            ),
            title: Text(
              task.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  task.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: const Color(0xFFFFD700),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${format.format(task.rewardAmount)} VOID',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: isCompleted
                ? const Icon(
                    Icons.check_circle,
                    color: Color(0xFF06B6D4),
                    size: 32,
                  )
                : ElevatedButton(
                    onPressed: () async {
                      final success =
                          await taskService.completeTask(task.id);
                      if (context.mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Earned ${format.format(task.rewardAmount)} VOID!',
                            ),
                            backgroundColor: const Color(0xFF06B6D4),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Start'),
                  ),
          ),
        );
      },
    );
  }

  IconData _getTaskIcon(TaskType type) {
    switch (type) {
      case TaskType.dailyCheckIn:
        return Icons.event_available;
      case TaskType.socialShare:
        return Icons.share;
      case TaskType.referral:
        return Icons.people;
      case TaskType.watchAd:
        return Icons.play_circle;
      case TaskType.inAppActivity:
        return Icons.star;
      default:
        return Icons.task;
    }
  }
}
