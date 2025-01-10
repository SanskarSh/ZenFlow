import 'package:todo/src/core/common/domain_imports.dart';

class TaskEntity {
  final String id;
  final String title;
  final String? description;
  final DateTime scheduledAt;
  final Priority priority;
  final bool isRoutine;
  final List<WeekDay> assignedWeekDays;
  bool isCompleted;
  final List<SubTaskEntity> subTasks;

  TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.scheduledAt,
    required this.priority,
    required this.isRoutine,
    required this.assignedWeekDays,
    this.isCompleted = false,
    this.subTasks = const [],
  });
}
