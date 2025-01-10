import 'package:todo/src/core/config/app_config.dart';
import 'package:todo/src/data/local_db/table.dart';
import 'package:todo/src/core/common/data_imports.dart';

part 'app_db.g.dart';

@DriftDatabase(
    tables: [Tasks, SubTasks, Reminders, TaskStats],
    views: [TasksView, CalendarView])
class AppDatabase extends _$AppDatabase {
  final _config = AppConfig();
  AppDatabase(QueryExecutor e) : super(_openConnection(e));

  @override
  int get schemaVersion => _config.databaseVersion;

  static QueryExecutor _openConnection(QueryExecutor e) {
    return e;
  }

  Future<TaskStatistics> getTaskStats(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = select(tasks)
        .join([leftOuterJoin(subTasks, subTasks.taskId.equalsExp(tasks.id))])
      ..where(tasks.dateAndTimeOfTaskScheduled
          .isBetween(Variable(startOfDay), Variable(endOfDay)));

    final results = await query.get();

    int totalTasks = 0;
    int completedTasks = 0;
    Set<String> uniqueTaskIds = {};

    for (final row in results) {
      final task = row.readTable(tasks);
      if (!uniqueTaskIds.contains(task.id)) {
        uniqueTaskIds.add(task.id);
        totalTasks++;
        if (task.isCompleted) {
          completedTasks++;
        }
      }
    }

    return TaskStatistics(
      date: startOfDay,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
    );
  }

  // Get tasks statistics for a date range
  Future<List<TaskStatistics>> getTaskStatsRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    List<TaskStatistics> stats = [];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      stats.add(await getTaskStats(currentDate));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return stats;
  }

  // Cleanup completed tasks
  Future<void> cleanupCompletedTasks() async {
    await (delete(tasks)
          ..where((t) =>
              t.isCarryForward.equals(false) & t.isCompleted.equals(true)))
        .go();
  }

  // Update expired reminders
  Future<void> updateExpiredReminders() async {
    final now = DateTime.now();

    await (update(reminders)
          ..where((t) => t.scheduledAt.isSmallerThan(Variable(now))))
        .write(const RemindersCompanion(isExpired: Value(true)));
  }

  // Run daily maintenance
  Future<void> runDailyMaintenance() async {
    await cleanupCompletedTasks();
    await updateExpiredReminders();
  }

  // Stream of task statistics for real-time updates
  Stream<TaskStatistics> watchTaskStats(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = select(tasks)
        .join([leftOuterJoin(subTasks, subTasks.taskId.equalsExp(tasks.id))])
      ..where(tasks.dateAndTimeOfTaskScheduled
          .isBetween(Variable(startOfDay), Variable(endOfDay)));

    return query.watch().map((results) {
      int totalTasks = 0;
      int completedTasks = 0;
      Set<String> uniqueTaskIds = {};

      for (final row in results) {
        final task = row.readTable(tasks);
        if (!uniqueTaskIds.contains(task.id)) {
          uniqueTaskIds.add(task.id);
          totalTasks++;
          if (task.isCompleted) {
            completedTasks++;
          }
        }
      }

      return TaskStatistics(
        date: startOfDay,
        totalTasks: totalTasks,
        completedTasks: completedTasks,
      );
    });
  }
}

class TaskStatistics {
  final DateTime date;
  final int totalTasks;
  final int completedTasks;

  TaskStatistics({
    required this.date,
    required this.totalTasks,
    required this.completedTasks,
  });

  double get completionRate => totalTasks > 0 ? completedTasks / totalTasks : 0;
}
