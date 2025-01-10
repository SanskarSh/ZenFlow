import 'package:drift/drift.dart';
import 'package:todo/src/core/constant/enumerates.dart';

class Tasks extends Table {
  // Common fields
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  // DateTimeColumn get scheduledAt => dateTime().check(scheduledAt.isBiggerThan(
  // Constant(DateTime.now().subtract(const Duration(days: 1)))))();

  // Task fields
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get editedAt => dateTime().nullable()();
  IntColumn get priority => intEnum<Priority>()();
  DateTimeColumn get dateAndTimeOfTaskScheduled => dateTime().nullable()();
  BoolColumn get isCarryForward =>
      boolean().withDefault(const Constant(false))();

  // Routine fields
  BoolColumn get isRoutine => boolean().withDefault(const Constant(false))();
  // For routine tasks - stores only time as minutes since midnight (0-1439)
  IntColumn get timeOfRoutineScheduled => integer().nullable()();
  TextColumn get assignedWeekDays => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SubTasks extends Table {
  IntColumn get id => integer().autoIncrement().nullable()();
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

class Reminders extends Table {
  IntColumn get id => integer().autoIncrement().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  BoolColumn get isExpired => boolean().withDefault(const Constant(false))();
}

abstract class TasksView extends View {
  Tasks get tasks;
  SubTasks get subTasks;

  @override
  Query as() => select([
        tasks.id,
        tasks.title,
        tasks.description,
        tasks.isCompleted,
        tasks.createdAt,
        tasks.editedAt,
        tasks.priority,
        tasks.dateAndTimeOfTaskScheduled,
        tasks.isCarryForward,
        tasks.isRoutine,
        tasks.assignedWeekDays,

        // SubTasks
        subTasks.id,
        subTasks.title,
        subTasks.description,
        subTasks.isCompleted,
      ]).from(tasks).join([
        leftOuterJoin(subTasks, subTasks.taskId.equalsExp(tasks.id)),
      ]);
}

class TaskStats extends Table {
  DateTimeColumn get date => dateTime()();
  IntColumn get completedTasks => integer().withDefault(const Constant(0))();
  IntColumn get totalTasks => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {date};
}

abstract class CalendarView extends View {
  Tasks get tasks;
  TaskStats get taskStats;

  @override
  Query as() => select([
        taskStats.date,
        taskStats.completedTasks,
        taskStats.totalTasks,
      ]).from(taskStats);
}
