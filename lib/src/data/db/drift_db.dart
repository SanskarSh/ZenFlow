import 'package:drift/drift.dart';
import 'package:todo/src/data/db/table.dart';
import 'package:todo/src/core/constant/enumerates.dart';


part 'drift_db.g.dart';

@DriftDatabase(tables: [Tasks, SubTasks], views: [TasksView])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(_openConnection(e));
  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection(QueryExecutor e) {
    return e;
  }
}
