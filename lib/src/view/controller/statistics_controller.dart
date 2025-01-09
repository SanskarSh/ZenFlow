import 'package:get/get.dart';
import 'package:todo/src/data/local_db/database/app_db.dart';
import 'package:todo/src/domain/repositories/base_repository.dart';

class StatisticsController extends GetxController {
  final TaskRepository _repository;

  StatisticsController(this._repository);

  final Rx<TaskStatistics?> todayStats = Rx<TaskStatistics?>(null);
  final RxList<TaskStatistics> monthStats = RxList<TaskStatistics>([]);

  @override
  void onInit() {
    super.onInit();
    _loadTodayStats();
    _loadMonthStats();
  }

  void _loadTodayStats() {
    _repository
        .watchTaskStats(DateTime.now())
        .listen((stats) => todayStats.value = stats);
  }

  Future<void> _loadMonthStats() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    monthStats.value = await _repository.getTaskStatsRange(
      startOfMonth,
      endOfMonth,
    );
  }
}
