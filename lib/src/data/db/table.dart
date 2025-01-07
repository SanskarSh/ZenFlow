import 'package:drift/drift.dart';
import 'package:todo/src/core/constant/enumerates.dart';

class Tasks extends Table {
  // Task fields
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get editedAt => dateTime().nullable()();
  IntColumn get priority => intEnum<Priority>()();
  BoolColumn get isCarryForward =>
      boolean().withDefault(const Constant(false))();

  // Common fields
  TextColumn get id => text().unique()();
  // TextColumn get id => text().clientDefault(() => uuid.v4()).unique()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  // DateTimeColumn get scheduledAt => dateTime().check(scheduledAt.isBiggerThan(
  // Constant(DateTime.now().subtract(const Duration(days: 1)))))();

  // Routine fields
  BoolColumn get isRoutine => boolean().withDefault(const Constant(false))();
  // IntColumn get assignedWeekDay => intEnum<WeekDay>().nullable()();
  TextColumn get assignedWeekDays => text().nullable()();
}

class SubTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

abstract class TasksView extends View {
  Tasks get tasks;
  SubTasks get subTasks;

  @override
  Query as() => select([tasks.title, subTasks.title]).from(tasks).join([
        innerJoin(subTasks, subTasks.taskId.equalsExp(tasks.id)),
      ]);
}
