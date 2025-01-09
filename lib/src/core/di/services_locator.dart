import 'dart:io';

import 'package:drift/native.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/src/core/config/app_config.dart';
import 'package:todo/src/core/service/background/background_service.dart';
import 'package:todo/src/core/service/notification/notification_services.dart';
import 'package:todo/src/core/theme/theme_services.dart';
import 'package:todo/src/data/local_db/dao/task_dao.dart';
import 'package:path/path.dart' as path;
import 'package:todo/src/data/local_db/database/app_db.dart';
import 'package:todo/src/data/repository/task_repository_impl.dart';
import 'package:todo/src/view/controller/background_service_controller.dart';
import 'package:todo/src/view/controller/theme_controller.dart';

class ServicesLocator {
  static Future<void> init() async {
    // Initialize SharedPreferences
    final pref = await SharedPreferences.getInstance();

    // Initialize app config
    final config = AppConfig();
    await config.init(Environment.dev);

    // Initialize Services
    final themeService = ThemeService(pref);
    Get.put(themeService);

    // Initialize Database
    final database = await initializeDatabase();
    Get.put<AppDatabase>(database);

    // Initialize DAOs
    final todoDao = TaskDao(database);
    Get.put(todoDao);

    // Initialize Repositories
    final taskRepository =
        TaskRepositoryImpl(Get.find<TaskDao>(), Get.find<AppDatabase>());
    Get.put(taskRepository);

    // Initialize Controllers
    final settingsController = ThemeController(themeService);
    await settingsController.loadSettings();
    Get.put(settingsController, permanent: true);

    // Background Services
    final backgroundController = BackgroundServiceController(taskRepository);
    Get.put(backgroundController);

    // Initialize notifications
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Initialize Background Service for mobile platforms
    if (!Platform.isLinux && !Platform.isMacOS && !Platform.isWindows) {
      await BackgroundService.initialize();
    }
  }

  static Future<AppDatabase> initializeDatabase() async {
    final config = AppConfig();
    final dbFolder = await getApplicationDocumentsDirectory();
    await dbFolder.create(recursive: true);
    final file = File(path.join(dbFolder.path, config.databaseName));
    return AppDatabase(NativeDatabase(file));
  }
}
