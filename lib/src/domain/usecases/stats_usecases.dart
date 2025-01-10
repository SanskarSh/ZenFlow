import 'package:todo/src/core/common/domain_imports.dart';

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
