import 'dart:io';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/src/app.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:todo/src/data/db/dao/dao.dart';
import 'package:todo/src/data/db/drift_db.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo/src/core/service/theme_services.dart';
import 'package:todo/src/controller/theme_controller.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Initialize Settings Controller
    final settingsController = SettingsController(SettingService(prefs));
    await settingsController.loadSettings();

    // Initialize Database
    final dbFolder = await getApplicationDocumentsDirectory();
    await dbFolder.create(recursive: true);
    final file = File(path.join(dbFolder.path, "db.todo"));
    final db = AppDatabase(NativeDatabase(file));
    final todoDao = TodoDao(db);

    // Put SettingsController into Get
    Get.put(settingsController, permanent: true);

    runApp(MyApp(
      todoDao: todoDao,
      settingsController: settingsController,
    ));
  } catch (e) {
    debugPrint('Error initializing app: $e');
  }
}
