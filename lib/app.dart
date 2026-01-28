import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_config.dart';
import 'features/todo/presentation/pages/todo_list_page.dart';
import 'shared/widgets/crash_error_page.dart';

class MyApp extends ConsumerStatefulWidget {
  final AppConfig config;

  const MyApp({super.key, required this.config});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _hasError = false;
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();
    
    // Set up error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorDetails = details;
        });
      }
    };
  }

  void _resetError() {
    setState(() {
      _hasError = false;
      _errorDetails = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CrashErrorPage(
          errorDetails: _errorDetails,
          onRefresh: _resetError,
        ),
      );
    }

    return MaterialApp(
      title: widget.config.appName,
      debugShowCheckedModeBanner: widget.config.debugMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TodoListPage(),
    );
  }
}
