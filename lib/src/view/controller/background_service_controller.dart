import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/src/domain/repositories/base_repository.dart';

class BackgroundServiceController extends GetxController {
  final TaskRepository _repository;

  BackgroundServiceController(this._repository);

  Future<void> runMaintenance() async {
    try {
      await _repository.runDailyMaintenance();
    } catch (e) {
      debugPrint('Error in maintenance: $e');
    }
  }
}