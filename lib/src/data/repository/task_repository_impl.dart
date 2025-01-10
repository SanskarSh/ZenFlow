import 'package:todo/src/core/common/data_imports.dart';
import 'package:todo/src/data/mappers/task_mapper.dart';
import 'package:todo/src/domain/repositories/base_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDao _taskDao;
  final AppDatabase _db;

  TaskRepositoryImpl(this._taskDao, this._db);

  @override
  Stream<List<TaskWithSubTasks>> get tasks => _taskDao.allTasks;

  @override
  Stream<List<TaskWithSubTasks>> get routineTasks => _taskDao.allRoutineTasks;

  @override
  Stream<List<RemindersCompanion>> get reminders => _taskDao.allReminders;

  Stream<List<TaskEntity>> watchTasks() {
    return _taskDao.allTasks.map(
      (tasks) => tasks.map((task) => task.toEntity()).toList(),
    );
  }

  @override
  Future<TaskWithSubTasks?> getTaskById(String id) async {
    return _taskDao.getTaskWithSubtasksById(id);
  }

  @override
  Stream<List<TaskWithSubTasks>> get completedTasks =>
      _taskDao.allCompletedTasks;

  @override
  Future<String> createTask(TasksCompanion task) async {
    return await _taskDao.insertTask(task);
  }

  @override
  Future<void> createSubTask(SubTasksCompanion subTask) async {
    await _taskDao.insertSubTask(subTask);
  }

  @override
  Future<void> createReminder(RemindersCompanion reminder) async {
    await _taskDao.insertReminder(reminder);
  }

  @override
  Future<void> updateTask(TaskWithSubTasks task) async {
    await _taskDao.updateTask(task);

    // Delete existing subtasks
    await _taskDao.deleteAllSubTasks(task.task.id);

    // Insert new/updated subtasks
    if (task.subTasks.isNotEmpty) {
      await _taskDao.insertSubtasks(task.subTasks);
    }
  }

  @override
  Future<void> deleteReminder(int taskId) async {
    await _taskDao.deleteReminder(taskId);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _taskDao.deleteTask(taskId);
  }

  @override
  Future<void> deleteSubTask(String taskId, int subtaskId) async {
    await _taskDao.deleteSubTask(taskId, subtaskId);
  }

  @override
  Future<void> toggleTaskCompleted(String taskId, bool isCompleted) async {
    await _taskDao.toggleTaskCompleted(taskId, isCompleted);
  }

  @override
  Future<void> toggleSubtaskCompleted(
    String taskId,
    int subtaskId,
    bool isCompleted,
  ) async {
    await _taskDao.toggleSubtaskCompleted(taskId, subtaskId, isCompleted);
  }

  @override
  Future<void> runDailyMaintenance() async {
    await _db.runDailyMaintenance();
    await _updateTaskStats(DateTime.now());
  }

  Future<void> _updateTaskStats(DateTime date) async {
    final stats = await _db.getTaskStats(date);
    await _taskDao.updateTaskStats(stats);
  }

  @override
  Future<TaskStatistics> getTaskStats(DateTime date) => _db.getTaskStats(date);

  @override
  Future<List<TaskStatistics>> getTaskStatsRange(
    DateTime startDate,
    DateTime endDate,
  ) =>
      _db.getTaskStatsRange(startDate, endDate);

  @override
  Stream<TaskStatistics> watchTaskStats(DateTime date) =>
      _db.watchTaskStats(date);
}
