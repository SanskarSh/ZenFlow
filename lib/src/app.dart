import 'package:todo/src/view/binding/app_binding.dart';
import 'package:todo/src/view/controller/layout_controller.dart';
import 'package:todo/src/core/common/ui_imports.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<ThemeController>();
    return GetBuilder<ThemeController>(
      init: settingsController,
      builder: (controller) {
        return GetMaterialApp(
          initialBinding: AppBinding(),
          themeMode: settingsController.themeMode,
          theme: AppTheme.lightTheme(context),
          darkTheme: AppTheme.darkTheme(context),
          home: const ResponsiveLayout(),
        );
      },
    );
  }
}
