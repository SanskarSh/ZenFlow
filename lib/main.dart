import 'package:todo/src/app.dart';
import 'package:flutter/material.dart';
import 'package:todo/src/core/di/services_locator.dart';
import 'package:todo/src/core/service/background/background_worker.dart';

@pragma('vm:entry-point')
void callbackDispatcher() => BackgroundWorker.executeTask();

void main() async {
  try {
    await initializeApp();
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
  }
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServicesLocator.init();
}
