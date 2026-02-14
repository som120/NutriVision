import 'env.dart';

/// API-related constants
class ApiConstants {
  ApiConstants._();

  // Gemini AI
  static const String geminiApiKey = Env.geminiApiKey;
  static const String geminiModel = 'gemini-2.5-pro';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
