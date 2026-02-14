/// Base exception for the application
class AppException implements Exception {
  final String message;
  final int? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server-side exceptions
class ServerException extends AppException {
  const ServerException({required super.message, super.code});
}

/// Cache/local storage exceptions
class CacheException extends AppException {
  const CacheException({required super.message, super.code});
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException({required super.message, super.code});
}

/// AI Analysis exceptions
class AIException extends AppException {
  const AIException({required super.message, super.code});
}
