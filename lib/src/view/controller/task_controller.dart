import 'package:get/get.dart';
import 'package:todo/src/data/local_db/dao/task_dao.dart';
import 'package:todo/src/data/local_db/database/app_db.dart';
import 'package:todo/src/domain/usecases/stats_usecases.dart';
import 'package:todo/src/domain/usecases/task_usecases.dart';
import 'package:todo/src/core/constant/enumerates.dart';

class TaskController extends GetxController {
  final TaskUseCases _taskUseCases;
  final StatsUseCases _statsUseCases;
  TaskController(this._taskUseCases, this._statsUseCases);

  final RxList<TaskWithSubTasks> tasks = <TaskWithSubTasks>[].obs;
  final RxList<TaskWithSubTasks> routineTasks = <TaskWithSubTasks>[].obs;
  final RxList<TaskWithSubTasks> completedTasks = <TaskWithSubTasks>[].obs;
  final RxList<RemindersCompanion> reminders = <RemindersCompanion>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenToTasks();
  }

  void _listenToTasks() {
    _taskUseCases.tasks.listen((event) => tasks.value = event);
    _taskUseCases.routineTasks.listen((event) => routineTasks.value = event);
    _taskUseCases.completedTasks
        .listen((event) => completedTasks.value = event);

    _taskUseCases.reminders.listen((event) => reminders.value = event);
  }

  Future<void> createTask({
    required String title,
    String? description,
    required DateTime scheduledAt,
    required Priority priority,
    bool isRoutine = false,
    List<WeekDay>? assignedWeekDays,
    bool isCarryForward = false,
    List<SubTasksCompanion>? subTasks,
  }) async {
    try {
      await _taskUseCases.createTask(
        title: title,
        description: description,
        scheduledAt: scheduledAt,
        priority: priority,
        isRoutine: isRoutine,
        assignedWeekDays: assignedWeekDays,
        isCarryForward: isCarryForward,
        subTasks: subTasks,
      );
    } catch (e) {
      throw 'Failed to create task: $e';
    }
  }

  Future<void> toggleTaskCompleted(String taskId, bool isCompleted) async {
    await _taskUseCases.toggleTaskCompleted(taskId, isCompleted);
  }

  Future<void> toggleSubTaskCompleted(
      String taskId, int subTaskId, bool isCompleted) async {
    await _taskUseCases.toggleSubtaskCompleted(taskId, subTaskId, isCompleted);
  }

  Future<void> updateTask(Task task) async {
    await _taskUseCases.updateTask(task);
  }

  Future<void> deleteTask(String taskId) async {
    await _taskUseCases.deleteTask(taskId);
  }

  Future<void> deleteSubTask(String taskId, int subTaskId) async {
    await _taskUseCases.deleteSubTask(taskId, subTaskId);
  }
}
