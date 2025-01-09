import 'package:todo/src/data/local_db/dao/task_dao.dart';
import 'package:todo/src/data/local_db/database/app_db.dart';
import 'package:todo/src/data/mappers/task_mapper.dart';
import 'package:todo/src/domain/repositories/base_repository.dart';

import '../../domain/entities/task.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDao _todoDao;
  final AppDatabase _db;

  TaskRepositoryImpl(this._todoDao, this._db);

  @override
  Stream<List<TaskWithSubTasks>> get tasks => _todoDao.allTasks;

  @override
  Stream<List<TaskWithSubTasks>> get routineTasks => _todoDao.allRoutineTasks;

  @override
  Stream<List<RemindersCompanion>> get reminders => _todoDao.allReminders;

  Stream<List<TaskEntity>> watchTasks() {
    return _todoDao.allTasks.map(
      (tasks) => tasks.map((task) => task.toEntity()).toList(),
    );
  }

  @override
  Future<TaskWithSubTasks?> getTaskById(String id) async {
    return _todoDao.getTaskWithSubtasksById(id);
  }

  @override
  Stream<List<TaskWithSubTasks>> get completedTasks =>
      _todoDao.allCompletedTasks;

  @override
  Future<String> createTask(TasksCompanion task) async {
    return await _todoDao.insertTask(task);
  }

  @override
  Future<void> createSubTask(SubTasksCompanion subTask) async {
    await _todoDao.insertSubTask(subTask);
  }

  @override
  Future<void> updateTask(Task task) async {
    await _todoDao.updateTask(task);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _todoDao.deleteTask(taskId);
  }

  @override
  Future<void> deleteSubTask(String taskId, int subtaskId) async {
    await _todoDao.deleteSubTask(taskId, subtaskId);
  }

  @override
  Future<void> toggleTaskCompleted(String taskId, bool isCompleted) async {
    await _todoDao.toggleTaskCompleted(taskId, isCompleted);
  }

  @override
  Future<void> toggleSubtaskCompleted(
    String taskId,
    int subtaskId,
    bool isCompleted,
  ) async {
    await _todoDao.toggleSubtaskCompleted(taskId, subtaskId, isCompleted);
  }

  @override
  Future<void> runDailyMaintenance() async {
    await _db.runDailyMaintenance();
    await _updateTaskStats(DateTime.now());
  }

  Future<void> _updateTaskStats(DateTime date) async {
    final stats = await _db.getTaskStats(date);
    await _todoDao.updateTaskStats(stats);
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
