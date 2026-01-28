import 'package:flutter/foundation.dart';
import 'dart:async';
import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack);
      return true;
    };
  }

  static void _logError(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print('=== ERROR ===');
      print('Error: $error');
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
      print('=============');
    }
    
    // In production, send to crash reporting service (e.g., Sentry, Firebase Crashlytics)
    // Example: Sentry.captureException(error, stackTrace: stackTrace);
  }

  static Failure handleException(dynamic error) {
    if (error is NetworkException) {
      return NetworkFailure(error.message, code: error.code);
    } else if (error is ServerException) {
      return ServerFailure(
        error.message,
        statusCode: error.statusCode,
        code: error.code,
      );
    } else if (error is DatabaseException) {
      return DatabaseFailure(error.message, code: error.code);
    } else if (error is ValidationException) {
      return ValidationFailure(error.message, code: error.code);
    } else if (error is CacheException) {
      return CacheFailure(error.message, code: error.code);
    } else if (error is SecurityException) {
      return SecurityFailure(error.message, code: error.code);
    } else {
      return UnexpectedFailure(
        error.toString(),
        code: 'UNEXPECTED_ERROR',
      );
    }
  }

  static String getErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Network error: ${failure.message}';
    } else if (failure is ServerFailure) {
      return 'Server error: ${failure.message}';
    } else if (failure is DatabaseFailure) {
      return 'Database error: ${failure.message}';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is SecurityFailure) {
      return 'Security error: ${failure.message}';
    } else {
      return 'An unexpected error occurred: ${failure.message}';
    }
  }

  static void runWithErrorHandling(Function() callback) {
    runZonedGuarded(
      () => callback(),
      (error, stackTrace) {
        _logError(error, stackTrace);
      },
    );
  }
}
