import 'dart:io';

import 'package:flutter/material.dart';
import 'package:todo/main.dart';
import 'package:todo/src/core/config/app_config.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundService {
  static final AppConfig _config = AppConfig();
  static const String dailyMaintenanceTask = "dailyMaintenance";

  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

      if (Platform.isAndroid) {
        await scheduleDailyMaintenance();
      } else if (Platform.isIOS) {
        await Workmanager().registerPeriodicTask(
          dailyMaintenanceTask,
          dailyMaintenanceTask,
          frequency: const Duration(hours: 15),
          constraints: Constraints(
            networkType: NetworkType.not_required,
            requiresBatteryNotLow: true,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error initializing background service: $e');
    }
  }

  static Future<void> scheduleDailyMaintenance() async {
    await Workmanager().registerPeriodicTask(
      dailyMaintenanceTask,
      dailyMaintenanceTask,
      frequency: _config.taskRetentionTime,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: true,
      ),
      initialDelay: _getDelayUntilMidnight(),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  static Duration _getDelayUntilMidnight() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }
}
