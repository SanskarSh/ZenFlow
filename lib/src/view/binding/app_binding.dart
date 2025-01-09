import 'package:get/get.dart';
import 'package:todo/src/core/theme/theme_services.dart';
import 'package:todo/src/data/local_db/dao/task_dao.dart';
import 'package:todo/src/data/local_db/database/app_db.dart';
import 'package:todo/src/data/repository/task_repository_impl.dart';
import 'package:todo/src/domain/repositories/base_repository.dart';
import 'package:todo/src/domain/usecases/stats_usecases.dart';
import 'package:todo/src/domain/usecases/task_usecases.dart';
import 'package:todo/src/view/controller/task_controller.dart';
import 'package:todo/src/view/controller/theme_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.put<TaskRepository>(
      TaskRepositoryImpl(
        Get.find<TaskDao>(),
        Get.find<AppDatabase>(),
      ),
    );

    // Use Cases
    Get.put(TaskUseCases(Get.find<TaskRepository>()));
    Get.put(StatsUseCases(Get.find<TaskRepository>()));

    // Controllers
    Get.put(TaskController(
      Get.find<TaskUseCases>(),
      Get.find<StatsUseCases>(),
    ));
    Get.put(ThemeController(Get.find<ThemeService>()));
  }
}
