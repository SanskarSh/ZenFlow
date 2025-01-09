class AppConstants {
  // App Information
  static const String appName = 'ZenFlow';
  static const String appVersion = '1.0.0';

  // Database Constants
  static const String dbName = 'db.ZenFlow';
  static const int dbVersion = 1;

  // Background Task Constants
  static const String dailyMaintenanceTask = 'dailyMaintenance';
  static const Duration maintenanceInterval = Duration(days: 1);

  // Task Constants
  static const int maxSubTasks = 10;
  static const int maxTaskNameLength = 255;
  static const int maxDescriptionLength = 500;

  // UI Constants
  static const double mobileBreakpoint = 700;
  static const double tabletBreakpoint = 1024;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 16.0;

  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String userPrefsKey = 'user_preferences';

  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy • hh:mm a';

  // Validation
  static const int minTitleLength = 1;
  static const int maxTitleLength = 255;
  static const int maxSubtaskCount = 10;

  // Error Messages
  static const String errorTitleRequired = 'Title is required';
  static const String errorTitleTooLong = 'Title is too long';
  static const String errorMaxSubtasks = 'Maximum subtasks limit reached';
  static const String errorRoutineWeekDays = 'Please select at least one day';
}
