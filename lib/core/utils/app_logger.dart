import 'package:flutter/foundation.dart';

class AppLogger {
  /// Simple log method that prints only in debug mode
  static void log(Object? message) {
    if (kDebugMode) {
      debugPrint(message?.toString());
    }
  }

  /// Logs errors with optional exception and stack trace in debug mode
  static void error(Object? message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('❌ ERROR: $message');
      if (error != null) debugPrint('⚠️ Exception: $error');
      if (stackTrace != null) debugPrint('📜 StackTrace: $stackTrace');
    }
  }
}
