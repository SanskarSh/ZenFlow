enum Environment { dev, staging, prod }

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Environment
  late Environment environment;

  // Feature flags
  bool enableBackgroundTasks = true;
  bool enableNotifications = true;
  bool enableAnalytics = true;

  // App settings
  Duration taskRetentionTime = const Duration(days: 1);
  int maxSubTasks = 10;
  Duration taskCleanupInterval = const Duration(days: 1);

  // Database settings
  String databaseName = 'db.ZenFlow';
  int databaseVersion = 1;

  // Theme settings
  bool enableDynamicTheming = true;

  // Initialization
  Future<void> init(Environment env) async {
    environment = env;

    switch (env) {
      case Environment.dev:
        _initDevelopment();
        break;
      case Environment.staging:
        _initStaging();
        break;
      case Environment.prod:
        _initProduction();
        break;
    }
  }

  void _initDevelopment() {
    enableAnalytics = false;
    taskRetentionTime = const Duration(minutes: 10);
    // TODO: Add other dev-specific settings
  }

  void _initStaging() {
    enableAnalytics = true;
    taskRetentionTime = const Duration(hours: 12);
    // TODO: Add other staging-specific settings
  }

  void _initProduction() {
    enableAnalytics = true;
    taskRetentionTime = const Duration(days: 1);
    // TODO: Add other production-specific settings
  }
}
