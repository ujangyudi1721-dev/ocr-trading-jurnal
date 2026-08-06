import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(Object? message) {
    if (kDebugMode) {
      debugPrint(message.toString());
    }
  }
}