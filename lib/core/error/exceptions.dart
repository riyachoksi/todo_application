class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.details});
}

class ServerException extends AppException {
  final int? statusCode;

  ServerException(super.message, {this.statusCode, super.code, super.details});
}

class DatabaseException extends AppException {
  DatabaseException(super.message, {super.code, super.details});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.code, super.details});
}

class CacheException extends AppException {
  CacheException(super.message, {super.code, super.details});
}

class SecurityException extends AppException {
  SecurityException(super.message, {super.code, super.details});
}
