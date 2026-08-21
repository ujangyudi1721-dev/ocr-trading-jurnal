import 'package:flutter/foundation.dart';

/// Logger sederhana pengganti `print()` langsung.
///
/// Bedanya dengan `print()`: [log] otomatis tidak melakukan apa-apa di
/// mode release ([kDebugMode] false), jadi log debug tidak ikut
/// terbawa ke build produksi. Pakai ini, bukan `print()`, untuk log
/// baru di service/halaman manapun.
class AppLogger {
  static void log(Object? message) {
    if (kDebugMode) {
      debugPrint(message.toString());
    }
  }
}
