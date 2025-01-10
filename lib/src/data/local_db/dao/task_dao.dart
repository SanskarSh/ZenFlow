import 'package:drift/drift.dart';
import 'package:todo/src/data/local_db/database/app_db.dart';
import 'package:todo/src/data/local_db/table.dart';

part 'task_dao.g.dart';

@DriftAccessor(
    tables: [Tasks, SubTasks, Reminders, TaskStats],
    views: [TasksView, CalendarView])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db) {
    allTasks = getTasks(isRoutine: false);
    allRoutineTasks = getTasks(isRoutine: true);
    allReminders = getReminders();
    allCompletedTasks = getCompletedTasks();
  }

  // Get all tasks
  Stream<List<TaskWithSubTasks>> getTasks({required bool isRoutine}) {
    final query = select(tasks).join([
      leftOuterJoin(subTasks, subTasks.taskId.equalsExp(tasks.id)),
    ])
      ..where(tasks.isCompleted.not() & tasks.isRoutine.equals(isRoutine));

    return query.watch().map((rows) {
      final groupedData = <Task, List<SubTask>>{};

      for (final row in rows) {
        final task = row.readTable(tasks);
        final subtask = row.readTableOrNull(subTasks);

        groupedData.putIfAbsent(task, () => []);
        if (subtask != null) {
          groupedData[task]!.add(subtask);
        }
      }

      return groupedData.entries.map((entry) {
        return TaskWithSubTasks(
          task: entry.key,
          subTasks: entry.value,
        );
      }).toList();
    });
  }

  // Get all reminders
  Stream<List<RemindersCompanion>> getReminders() {
    final query = select(reminders);

    return query.watch().map((rows) {
      return rows.map((row) {
        return RemindersCompanion(
          id: Value(row.id),
          scheduledAt: Value(row.scheduledAt),
          title: Value(row.title),
          description: Value(row.description),
        );
      }).toList();
    });
  }

  // Get all tasks
  late final Stream<List<TaskWithSubTasks>> allTasks;

  // Get all routine tasks
  late final Stream<List<TaskWithSubTasks>> allRoutineTasks;

  // Get all reminders
  late final Stream<List<RemindersCompanion>> allReminders;

  // Get all completed tasks
  late final Stream<List<TaskWithSubTasks>> allCompletedTasks;

  // Get task by id
  Future<TaskWithSubTasks?> getTaskWithSubtasksById(String id) async {
    final query = select(tasks).join([
      leftOuterJoin(subTasks, subTasks.taskId.equalsExp(tasks.id)),
    ])
      ..where(tasks.id.equals(id));

    final rows = await query.get();
    if (rows.isEmpty) return null;

    final task = rows.first.readTable(tasks);
    final subtasksList = rows
        .map((row) => row.readTableOrNull(subTasks))
        .where((st) => st != null)
        .cast<SubTask>()
        .toList();

    return TaskWithSubTasks(
      task: task,
      subTasks: subtasksList,
    );
  }

  // Get all completed tasks & routine
  Stream<List<TaskWithSubTasks>> getCompletedTasks() {
    final query = select(tasks).join([
      leftOuterJoin(subTasks, subTasks.taskId.equalsExp(tasks.id)),
    ])
      ..where(tasks.isCompleted);

    return query.watch().map((rows) {
      final groupedData = <Task, List<SubTask>>{};

      for (final row in rows) {
        final task = row.readTable(tasks);
        final subtask = row.readTableOrNull(subTasks);

        groupedData.putIfAbsent(task, () => []);
        if (subtask != null) {
          groupedData[task]!.add(subtask);
        }
      }

      return groupedData.entries.map((entry) {
        return TaskWithSubTasks(
          task: entry.key,
          subTasks: entry.value,
        );
      }).toList();
    });
  }

  // Insert new task
  Future<String> insertTask(TasksCompanion task) async {
    await into(tasks).insert(task);
    return task.id.value;
  }

  // Insert new subtask
  Future<void> insertSubTask(SubTasksCompanion subTask) async {
    await into(subTasks).insert(subTask);
  }

  // Insert new reminder
  Future<void> insertReminder(RemindersCompanion reminder) async {
    await into(reminders).insert(reminder);
  }

  // Insert new subtask
  Future<void> insertSubtasks(List<SubTask> subtasks) async {
    await batch((batch) {
      batch.insertAll(subTasks, subtasks);
    });
  }

  // Update task
  Future<void> updateTask(TaskWithSubTasks task) {
    return transaction(() async {
      await update(tasks).replace(task.task);
      await (delete(subTasks)..where((t) => t.taskId.equals(task.task.id)))
          .go();

      if (task.subTasks.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(subTasks, task.subTasks);
        });
      }
    });
  }

  // Update routine
  Future<void> updateRoutine(Task routine) {
    return update(tasks).replace(routine);
  }

  // Delete task
  Future<void> deleteTask(String taskId) {
    return (delete(tasks)..where((tbl) => tbl.id.equals(taskId))).go();
  }

  // Delete routine
  Future<void> deleteRoutine(String routineId) {
    return (delete(tasks)..where((tbl) => tbl.id.equals(routineId))).go();
  }

  // Delete reminder
  Future<void> deleteReminder(int taskId) {
    return (delete(reminders)..where((tbl) => tbl.id.equals(taskId))).go();
  }

  // Delete subtask
  Future<void> deleteSubTask(String taskId, int subtaskId) {
    return (delete(subTasks)
          ..where(
              (tbl) => tbl.taskId.equals(taskId) & tbl.id.equals(subtaskId)))
        .go();
  }

  // Delete all subtasks
  Future<void> deleteAllSubTasks(String taskId) {
    return (delete(subTasks)..where((tbl) => tbl.taskId.equals(taskId))).go();
  }

  // Toggle task completed and delete subtasks
  Future<void> toggleTaskCompleted(String taskId, bool isCompleted) async {
    await transaction(() async {
      await (update(tasks)..where((t) => t.id.equals(taskId))).write(
        TasksCompanion(
          isCompleted: Value(isCompleted),
          editedAt: Value(DateTime.now()),
        ),
      );
      if (isCompleted) {
        await (update(subTasks)..where((t) => t.taskId.equals(taskId))).write(
          const SubTasksCompanion(isCompleted: Value(true)),
        );
      }
    });
  }

  // Toggle subtask completed
  Future<void> toggleSubtaskCompleted(
    String taskId,
    int subtaskId,
    bool isCompleted,
  ) async {
    await transaction(() async {
      await (update(subTasks)
            ..where((t) => t.id.equals(subtaskId) & t.taskId.equals(taskId)))
          .write(
        SubTasksCompanion(isCompleted: Value(isCompleted)),
      );

      final allSubtasks =
          await (select(subTasks)..where((t) => t.taskId.equals(taskId))).get();
      final allCompleted = allSubtasks.every((subtask) => subtask.isCompleted);

      await (update(tasks)..where((t) => t.id.equals(taskId))).write(
        TasksCompanion(
          isCompleted: Value(allCompleted),
          editedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  // Run daily maintenance
  Future<void> updateTaskStats(TaskStatistics stats) async {
    await into(taskStats).insertOnConflictUpdate(
      TaskStatsCompanion.insert(
        date: stats.date,
        completedTasks: Value(stats.completedTasks),
        totalTasks: Value(stats.totalTasks),
      ),
    );
  }
}

class TaskWithSubTasks {
  final Task task;
  final List<SubTask> subTasks;

  TaskWithSubTasks({required this.task, required this.subTasks});
}
