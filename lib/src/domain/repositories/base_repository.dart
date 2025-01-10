import 'package:todo/src/core/common/domain_imports.dart';

abstract class TaskRepository {
  Stream<List<TaskWithSubTasks>> get tasks;
  Stream<List<TaskWithSubTasks>> get routineTasks;
  Stream<List<TaskWithSubTasks>> get completedTasks;
  Stream<List<RemindersCompanion>> get reminders;

  Future<TaskWithSubTasks?> getTaskById(String id);

  Future<String> createTask(TasksCompanion task);
  Future<void> createSubTask(SubTasksCompanion subTask);
  Future<void> createReminder(RemindersCompanion reminder);

  Future<void> updateTask(TaskWithSubTasks task);

  Future<void> deleteReminder(int reminderId);
  Future<void> deleteTask(String taskId);
  Future<void> deleteSubTask(String taskId, int subtaskId);

  Future<void> toggleTaskCompleted(String taskId, bool isCompleted);
  Future<void> toggleSubtaskCompleted(
      String taskId, int subtaskId, bool isCompleted);

  Future<void> runDailyMaintenance();
  Future<TaskStatistics> getTaskStats(DateTime date);

  Future<List<TaskStatistics>> getTaskStatsRange(
      DateTime startDate, DateTime endDate);
  Stream<TaskStatistics> watchTaskStats(DateTime date);
}
