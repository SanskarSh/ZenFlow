import 'package:get/get.dart';
import 'package:todo/src/core/utils/weekday_converter.dart';
import 'package:uuid/uuid.dart';
import 'package:todo/src/data/db/dao/dao.dart';
import 'package:todo/src/data/db/drift_db.dart';
import 'package:drift/drift.dart' as drift_data_class;
import 'package:todo/src/core/constant/enumerates.dart';
import 'package:todo/src/data/repository/task_repository.dart';

class TaskController extends GetxController {
  final TaskRepository _repository;

  TaskController(this._repository);

  final RxList<TaskWithSubTasks> tasks = <TaskWithSubTasks>[].obs;
  final RxList<TaskWithSubTasks> routineTasks = <TaskWithSubTasks>[].obs;
  final RxList<TaskWithSubTasks> completedTasks = <TaskWithSubTasks>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenToTasks();
  }

  void _listenToTasks() {
    _repository.tasks.listen((event) => tasks.value = event);
    _repository.routineTasks.listen((event) => routineTasks.value = event);
    _repository.completedTasks.listen((event) => completedTasks.value = event);
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
    final taskId = const Uuid().v4();
    TasksCompanion task = TasksCompanion(
      id: drift_data_class.Value(taskId),
      title: drift_data_class.Value(title),
      description: description != null
          ? drift_data_class.Value(description)
          : const drift_data_class.Value.absent(),
      scheduledAt: drift_data_class.Value(scheduledAt),
      priority: drift_data_class.Value(priority),
      isRoutine: drift_data_class.Value(isRoutine),
      assignedWeekDays: assignedWeekDays != null
          ? drift_data_class.Value(
              WeekDayConverter.encodeWeekDays(assignedWeekDays))
          : const drift_data_class.Value.absent(),
      isCarryForward: drift_data_class.Value(isCarryForward),
      createdAt: drift_data_class.Value(DateTime.now()),
      isCompleted: const drift_data_class.Value(false),
    );

    try {
      await _repository.createTask(task);

      if (subTasks != null && subTasks.isNotEmpty) {
        for (var subTask in subTasks) {
          await _repository.createSubTask(
            subTask.copyWith(taskId: drift_data_class.Value(taskId)),
          );
        }
      }
    } catch (e) {
      throw 'Failed to create task: $e';
    }
  }

  Future<void> toggleTaskCompleted(String taskId, bool isCompleted) async {
    await _repository.toggleTaskCompleted(taskId, isCompleted);
  }

  Future<void> toggleSubTaskCompleted(
      String taskId, int subTaskId, bool isCompleted) async {
    await _repository.toggleSubtaskCompleted(taskId, subTaskId, isCompleted);
  }

  Future<void> updateTask(Task task) async {
    await _repository.updateTask(task);
  }

  Future<void> deleteTask(String taskId) async {
    await _repository.deleteTask(taskId);
  }

  Future<void> deleteSubTask(String taskId, int subTaskId) async {
    await _repository.deleteSubTask(taskId, subTaskId);
  }
}
