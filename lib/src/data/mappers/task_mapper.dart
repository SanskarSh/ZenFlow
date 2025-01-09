import 'package:todo/src/core/utils/date_utils.dart';
import 'package:todo/src/data/local_db/dao/task_dao.dart';
import 'package:todo/src/data/local_db/database/app_db.dart';
import 'package:todo/src/domain/entities/subtask.dart';
import 'package:todo/src/domain/entities/task.dart';
import 'package:drift/drift.dart' as drift_data_class;

extension TaskMapper on TaskWithSubTasks {
  TaskEntity toEntity() {
    return TaskEntity(
      id: task.id,
      title: task.title,
      description: task.description,
      scheduledAt: task.dateAndTimeOfTaskScheduled ?? DateTime.now(),
      priority: task.priority,
      isRoutine: task.isRoutine,
      assignedWeekDays: task.assignedWeekDays != null
          ? WeekDayConverter.decodeWeekDays(task.assignedWeekDays) ?? []
          : [],
      isCompleted: task.isCompleted,
      subTasks: subTasks.map((st) => st.toEntity()).toList(),
    );
  }
}

extension SubTaskMapper on SubTask {
  SubTaskEntity toEntity() {
    return SubTaskEntity(
      id: id ?? 0,
      taskId: taskId,
      title: title,
      description: description,
      isCompleted: isCompleted,
    );
  }
}

extension TaskEntityMapper on TaskEntity {
  TasksCompanion toCompanion() {
    return TasksCompanion(
      id: drift_data_class.Value(id),
      title: drift_data_class.Value(title),
      description: drift_data_class.Value(description),
      dateAndTimeOfTaskScheduled: drift_data_class.Value(scheduledAt),
      priority: drift_data_class.Value(priority),
      isRoutine: drift_data_class.Value(isRoutine),
      assignedWeekDays: drift_data_class.Value(
        WeekDayConverter.encodeWeekDays(assignedWeekDays),
      ),
      isCompleted: drift_data_class.Value(isCompleted),
    );
  }
}
