import 'package:equatable/equatable.dart';

/// Base failure class for the application
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server-side failures (Firebase, API, etc.)
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Local cache/storage failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// Camera/Permission failures
class CameraFailure extends Failure {
  const CameraFailure({required super.message, super.code});
}

/// AI Analysis failures
class AIFailure extends Failure {
  const AIFailure({required super.message, super.code});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
