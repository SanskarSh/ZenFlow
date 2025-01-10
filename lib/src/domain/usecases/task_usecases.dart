import 'package:todo/src/core/common/domain_imports.dart';
import 'package:drift/drift.dart' as drift_data_class;

class TaskUseCases {
  final TaskRepository _repository;

  TaskUseCases(this._repository);

  Stream<List<TaskWithSubTasks>> get tasks => _repository.tasks;
  Stream<List<TaskWithSubTasks>> get routineTasks => _repository.routineTasks;
  Stream<List<TaskWithSubTasks>> get completedTasks =>
      _repository.completedTasks;
  Stream<List<RemindersCompanion>> get reminders => _repository.reminders;

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
    if (isRoutine && (assignedWeekDays?.isEmpty ?? true)) {
      throw Exception('Routine tasks must have assigned days');
    }

    final taskId = const Uuid().v4();
    final task = TasksCompanion(
      id: drift_data_class.Value(taskId),
      title: drift_data_class.Value(title),
      description: drift_data_class.Value(description),
      dateAndTimeOfTaskScheduled: isRoutine
          ? const drift_data_class.Value.absent()
          : drift_data_class.Value(scheduledAt),
      priority: drift_data_class.Value(priority),
      isRoutine: drift_data_class.Value(isRoutine),
      timeOfRoutineScheduled: isRoutine
          ? drift_data_class.Value(scheduledAt.hour * 60 + scheduledAt.minute)
          : const drift_data_class.Value.absent(),
      assignedWeekDays: assignedWeekDays != null
          ? drift_data_class.Value(
              WeekDayConverter.encodeWeekDays(assignedWeekDays))
          : const drift_data_class.Value.absent(),
      isCarryForward: drift_data_class.Value(isCarryForward),
      createdAt: drift_data_class.Value(DateTime.now()),
    );

    await _repository.createTask(task);

    if (subTasks != null && subTasks.isNotEmpty) {
      for (var subTask in subTasks) {
        await _repository.createSubTask(
          subTask.copyWith(taskId: drift_data_class.Value(taskId)),
        );
      }
    }
  }

  Future<void> createReminder({
    required String title,
    String? description,
    required DateTime scheduledAt,
  }) async {
    final reminder = RemindersCompanion(
      title: drift_data_class.Value(title),
      description: drift_data_class.Value(description),
      scheduledAt: drift_data_class.Value(scheduledAt),
    );
    await _repository.createReminder(reminder);
  }

  Future<void> addSubTask(String taskId, SubTask subTask) async {
    SubTasksCompanion newSubTask = SubTasksCompanion(
      taskId: drift_data_class.Value(taskId),
      title: drift_data_class.Value(subTask.title),
      description: drift_data_class.Value(subTask.description),
      isCompleted: drift_data_class.Value(subTask.isCompleted),
    );
    await _repository.createSubTask(newSubTask);
  }

  Future<void> updateTask(TaskWithSubTasks task) async {
    await _repository.updateTask(task);
  }

  Future<void> deleteTask(String taskId) async {
    await _repository.deleteTask(taskId);
  }

  Future<void> deleteReminder(int reminderId) async {
    await _repository.deleteReminder(reminderId);
  }

  Future<void> deleteSubTask(String taskId, int subtaskId) async {
    await _repository.deleteSubTask(taskId, subtaskId);
  }

  Future<void> toggleTaskCompleted(String taskId, bool isCompleted) async {
    await _repository.toggleTaskCompleted(taskId, isCompleted);
  }

  Future<void> toggleSubtaskCompleted(
    String taskId,
    int subtaskId,
    bool isCompleted,
  ) async {
    await _repository.toggleSubtaskCompleted(taskId, subtaskId, isCompleted);
  }

  Future<void> runDailyMaintenance() async {
    await _repository.runDailyMaintenance();
  }
}
