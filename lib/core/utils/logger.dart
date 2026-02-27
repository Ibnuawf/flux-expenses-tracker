import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[Flux] $message ${error ?? ""}');
    }
  }
}
