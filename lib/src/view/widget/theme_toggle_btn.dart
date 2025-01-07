import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/src/controller/theme_controller.dart';

class ToggleTheme extends GetView<SettingsController> {
  const ToggleTheme({super.key, required this.controller});

  @override
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      init: controller,
      builder: (controller) => IconButton(
        onPressed: controller.toggleTheme,
        icon: Icon(
          controller.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        ),
      ),
    );
  }
}
