import 'package:drift/drift.dart';
import 'package:todo/src/data/db/table.dart';
import 'package:todo/src/data/db/drift_db.dart';

part 'dao.g.dart';

@DriftAccessor(tables: [Tasks, SubTasks])
class TodoDao extends DatabaseAccessor<AppDatabase> with _$TodoDaoMixin {
  TodoDao(super.db) {
    allTasks = getTasks(isRoutine: false);
    routineTasks = getTasks(isRoutine: true);
    completedTasks = getCompletedTasks();
  }

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

  // Get all tasks
  late final Stream<List<TaskWithSubTasks>> allTasks;

  // Get all routine tasks
  late final Stream<List<TaskWithSubTasks>> routineTasks;

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

  late final Stream<List<TaskWithSubTasks>> completedTasks;

  // Insert new task
  Future<String> insertTask(TasksCompanion task) async {
    await into(tasks).insert(task);
    return task.id.value;
  }

  Future<void> insertSubTask(SubTasksCompanion subTask) async {
    await into(subTasks).insert(subTask);
  }

  // Insert new subtask
  Future<void> insertSubtasks(List<SubTasksCompanion> subtasks) async {
    await batch((batch) {
      batch.insertAll(subTasks, subtasks);
    });
  }

  // Update task
  Future<void> updateTask(Task task) {
    return update(tasks).replace(task);
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

  // Delete subtask
  Future<void> deleteSubTask(String taskId, int subtaskId) {
    return (delete(subTasks)
          ..where(
              (tbl) => tbl.taskId.equals(taskId) & tbl.id.equals(subtaskId)))
        .go();
  }

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
}

class TaskWithSubTasks {
  final Task task;
  final List<SubTask> subTasks;

  TaskWithSubTasks({required this.task, required this.subTasks});
}
