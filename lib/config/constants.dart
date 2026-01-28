class AppConstants {
  AppConstants._();

  // Database
  static const String databaseName = 'todo_app.db';
  static const int databaseVersion = 1;

  // Tables
  static const String todosTable = 'todos';
  static const String syncQueueTable = 'sync_queue';

  // Sync
  static const int maxRetryAttempts = 3;
  static const int syncIntervalSeconds = 30;
  static const Duration syncRetryDelay = Duration(seconds: 5);

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;

  // Error messages
  static const String networkErrorMessage =
      'No internet connection. Changes will be synced when online.';
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String securityErrorMessage =
      'This app cannot run on rooted/jailbroken devices for security reasons.';
  static const String crashErrorMessage =
      'The app encountered an unexpected error.';
}
