import 'package:todo/src/core/common/ui_imports.dart';

class ToggleTheme extends GetView<ThemeController> {
  const ToggleTheme({super.key, required this.controller});

  @override
  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
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
