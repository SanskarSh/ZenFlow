import 'package:flutter/material.dart';
import 'package:todo/src/core/di/services_locator.dart';
import 'package:todo/src/core/service/background/background_service.dart';
import 'package:todo/src/data/local_db/dao/task_dao.dart';
import 'package:todo/src/data/repository/task_repository_impl.dart';

import 'package:todo/src/view/controller/background_service_controller.dart';

class BackgroundWorker {
  static Future<bool> executeTask(
      [String? task, Map<String, dynamic>? inputData]) async {
    try {
      switch (task) {
        case BackgroundService.dailyMaintenanceTask:
          await _executeDailyMaintenance();
          return true;
        default:
          return false;
      }
    } catch (e) {
      debugPrint('Background task error: $e');
      return false;
    }
  }

  static Future<void> _executeDailyMaintenance() async {
    final database = await ServicesLocator.initializeDatabase();
    final todoDao = TaskDao(database);
    final repository = TaskRepositoryImpl(todoDao, database);
    final controller = BackgroundServiceController(repository);
    await controller.runMaintenance();
  }
}
