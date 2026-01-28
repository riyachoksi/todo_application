import 'flavor.dart';

class AppConfig {
  final Flavor flavor;
  final String baseUrl;
  final String appName;
  final bool debugMode;
  final bool enableLogging;
  final int connectTimeout;
  final int receiveTimeout;

  AppConfig({
    required this.flavor,
    required this.baseUrl,
    required this.appName,
    required this.debugMode,
    required this.enableLogging,
    this.connectTimeout = 30000,
    this.receiveTimeout = 30000,
  });

  factory AppConfig.fromFlavor(Flavor flavor) {
    switch (flavor) {
      case Flavor.dev:
        return AppConfig(
          flavor: flavor,
          baseUrl: 'https://jsonplaceholder.typicode.com',
          appName: 'TODO Dev',
          debugMode: true,
          enableLogging: true,
          connectTimeout: 30000,
          receiveTimeout: 30000,
        );
      case Flavor.qa:
        return AppConfig(
          flavor: flavor,
          baseUrl: 'https://jsonplaceholder.typicode.com',
          appName: 'TODO QA',
          debugMode: true,
          enableLogging: true,
          connectTimeout: 30000,
          receiveTimeout: 30000,
        );
      case Flavor.staging:
        return AppConfig(
          flavor: flavor,
          baseUrl: 'https://jsonplaceholder.typicode.com',
          appName: 'TODO Staging',
          debugMode: false,
          enableLogging: true,
          connectTimeout: 25000,
          receiveTimeout: 25000,
        );
      case Flavor.prod:
        return AppConfig(
          flavor: flavor,
          baseUrl: 'https://jsonplaceholder.typicode.com',
          appName: 'TODO',
          debugMode: false,
          enableLogging: false,
          connectTimeout: 20000,
          receiveTimeout: 20000,
        );
    }
  }

  @override
  String toString() {
    return 'AppConfig(flavor: $flavor, baseUrl: $baseUrl, appName: $appName)';
  }
}
