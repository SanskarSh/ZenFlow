import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:todo/src/data/db/dao/dao.dart';
import 'package:todo/src/core/theme/theme.dart';
import 'package:todo/src/core/binding/app_binding.dart';
import 'package:todo/src/controller/theme_controller.dart';
import 'package:todo/src/controller/layout_controller.dart';

class MyApp extends StatelessWidget {
  final TodoDao todoDao;
  final SettingsController settingsController;

  const MyApp({
    super.key,
    required this.todoDao,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      init: settingsController,
      builder: (controller) {
        return GetMaterialApp(
          initialBinding: AppBinding(todoDao: todoDao),
          themeMode: settingsController.themeMode,
          theme: MyTheme.lightTheme(context),
          darkTheme: MyTheme.darkTheme(context),
          home: const ResponsiveLayout(),
        );
      },
    );
  }
}
