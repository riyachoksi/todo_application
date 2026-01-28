import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'config/app_config.dart';
import 'config/flavor.dart';
import 'core/error/error_handler.dart';
import 'core/utils/security_checker.dart';
import 'features/todo/presentation/providers/todo_providers.dart';
import 'shared/widgets/security_block_page.dart';

void main() async {
  ErrorHandler.initialize();

  ErrorHandler.runWithErrorHandling(() async {
    WidgetsFlutterBinding.ensureInitialized();

    const flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    final flavor = Flavor.fromString(flavorString);
    final config = AppConfig.fromFlavor(flavor);

    final securityChecker = SecurityChecker();
    try {
      await securityChecker.checkDeviceSecurity();
    } catch (e) {
      runApp(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SecurityBlockPage(),
        ),
      );
      return;
    }

    runApp(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
        ],
        child: MyApp(config: config),
      ),
    );
  });
}
