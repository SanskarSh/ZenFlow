import 'package:todo/src/data/local_db/database/app_db.dart';
import 'package:todo/src/domain/repositories/base_repository.dart';

class StatsUseCases {
  final TaskRepository _repository;

  StatsUseCases(this._repository);

  Future<TaskStatistics> getTaskStats(DateTime date) {
    return _repository.getTaskStats(date);
  }

  Future<List<TaskStatistics>> getTaskStatsRange(
      DateTime startDate, DateTime endDate) {
    return _repository.getTaskStatsRange(startDate, endDate);
  }

  Stream<TaskStatistics> watchTaskStats(DateTime date) {
    return _repository.watchTaskStats(date);
  }
}
