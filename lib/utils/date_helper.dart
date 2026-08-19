class DateHelper {
  // ==========================================================
  // MONTH MAP (INDONESIA)
  // ==========================================================

  static const Map<String, int> _months = {
    "Jan": 1,
    "Feb": 2,
    "Mar": 3,
    "Apr": 4,
    "Mei": 5,
    "Jun": 6,
    "Jul": 7,
    "Agu": 8,
    "Sep": 9,
    "Okt": 10,
    "Nov": 11,
    "Des": 12,
  };

  // ==========================================================
  // PARSE DATE
  //
  // Support:
  //
  // 1.
  // 2 Agu 2026 17.08.15
  //
  // 2.
  // 2026-08-06 08:41:08.572515
  // ==========================================================

  static DateTime? parse(String text) {
    text = text.trim();

    // ======================================================
    // FORMAT ISO
    //
    // Contoh:
    // 2026-08-06 08:41:08.572515
    // ======================================================

    try {
      return DateTime.parse(text);
    } catch (_) {}

    // ======================================================
    // FORMAT OCR
    //
    // Contoh:
    // 2 Agu 2026 17.08.15
    // ======================================================

    try {
      final parts = text.split(" ");

      if (parts.length < 4) {
        return null;
      }

      final day = int.parse(parts[0]);

      final month = _months[parts[1]];

      if (month == null) {
        return null;
      }

      final year = int.parse(parts[2]);

      final normalizedTime = parts[3].replaceAll(",", ".");
      final time = normalizedTime.split(".");
      if (time.length != 3) {
        return null;
      }

      final hour = int.parse(time[0]);
      final minute = int.parse(time[1]);
      final second = int.parse(time[2]);

      return DateTime(year, month, day, hour, minute, second);
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // FORMAT
  //
  // Output:
  // 02/08/2026 17:08:15
  // ==========================================================

  static String formatStorage(DateTime date) {
    return date.toIso8601String();
  }
  // ==========================================================
  // FORMAT DATE ONLY
  //
  // Output:
  // 02/08/2026
  // ==========================================================

  static String formatDisplay(DateTime date) {
    String two(int value) => value.toString().padLeft(2, "0");

    return "${two(date.day)}/${two(date.month)}/${date.year}";
  }
  // ==========================================================
  // FORMAT TIME ONLY
  //
  // Output:
  // 17:08:15
  // ==========================================================

  static String formatTime(DateTime date) {
    String two(int value) => value.toString().padLeft(2, "0");

    return "${two(date.hour)}:${two(date.minute)}:${two(date.second)}";
  }

  // ==========================================================
  // FORMAT DATE + TIME
  //
  // Output:
  // 02/08/2026 17:08:15
  // ==========================================================
  static String formatDateTime(DateTime date) {
    return "${formatDisplay(date)} ${formatTime(date)}";
  }
}
