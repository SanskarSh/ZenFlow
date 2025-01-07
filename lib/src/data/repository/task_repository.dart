import 'package:todo/src/data/db/dao/dao.dart';
import 'package:todo/src/data/db/drift_db.dart';

class TaskRepository {
  final TodoDao _todoDao;

  TaskRepository(this._todoDao);

  Stream<List<TaskWithSubTasks>> get tasks => _todoDao.allTasks;
  Stream<List<TaskWithSubTasks>> get routineTasks => _todoDao.routineTasks;
  Stream<List<TaskWithSubTasks>> get completedTasks => _todoDao.completedTasks;

  Future<String> createTask(TasksCompanion task) async =>
      await _todoDao.insertTask(task);

  Future<void> createSubTask(SubTasksCompanion subTask) async =>
      await _todoDao.insertSubTask(subTask);

  Future<void> updateTask(Task task) async => await _todoDao.updateTask(task);

  Future<void> deleteTask(String taskId) async =>
      await _todoDao.deleteTask(taskId);

  Future<void> deleteSubTask(String taskId, int subtaskId) async =>
      await _todoDao.deleteSubTask(taskId, subtaskId);

  Future<void> toggleTaskCompleted(String taskId, bool isCompleted) async {
    await _todoDao.toggleTaskCompleted(taskId, isCompleted);
  }

  Future<void> toggleSubtaskCompleted(
    String taskId,
    int subtaskId,
    bool isCompleted,
  ) async =>
      await _todoDao.toggleSubtaskCompleted(taskId, subtaskId, isCompleted);
}
