import 'package:get/get.dart';
import 'package:todo/src/data/db/dao/dao.dart';
import 'package:todo/src/controller/task_controller.dart';
import 'package:todo/src/data/repository/task_repository.dart';

class AppBinding extends Bindings {
  final TodoDao todoDao;

  AppBinding({required this.todoDao});

  @override
  void dependencies() {
    Get.put(TaskRepository(todoDao));
    Get.put(TaskController(Get.find<TaskRepository>()));
  }
}
