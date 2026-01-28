import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode, super.code});

  @override
  List<Object?> get props => [message, code, statusCode];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class SecurityFailure extends Failure {
  const SecurityFailure(super.message, {super.code});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.code});
}
