import 'package:todo/src/core/constant/enumerates.dart';

class TasksModel {
  // Task fields
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? editedAt;
  final Priority priority;
  final bool isCarryForward;

  // Common fields
  final String id;
  final String title;
  final String? description;
  final DateTime scheduledAt;
  final List<SubTasksModel> subTasks = [];

  // Routine fields
  final bool isRoutine;
  final WeekDay assignedWeekDay;

  TasksModel(
    this.isCarryForward, {
    required this.isCompleted,
    required this.createdAt,
    required this.editedAt,
    required this.priority,
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.isRoutine,
    required this.assignedWeekDay,
  });
}

class SubTasksModel {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;

  SubTasksModel({
    required this.id,
    required this.taskId,
    required this.title,
    required this.isCompleted,
  });
}
