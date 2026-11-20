class DateHelper {
  // ==========================================================
  // MONTH MAP (INDONESIA + ENGLISH)
  // ==========================================================

  static const Map<String, int> _months = {
    "Jan": 1,
    "Feb": 2,
    "Mar": 3,
    "Apr": 4,
    "Mei": 5,
    "May": 5,
    "Jun": 6,
    "Jul": 7,
    "Agu": 8,
    "Aug": 8,
    "Sep": 9,
    "Okt": 10,
    "Oct": 10,
    "Nov": 11,
    "Des": 12,
    "Dec": 12,
  };

  // ==========================================================
  // PARSE DATE
  //
  // Support:
  // 1. 2 Agu 2026 17.08.15
  // 2. 2026-08-06 08:41:08.572515
  // ==========================================================

  static DateTime? parse(String text) {
    text = text.trim();

    // FORMAT ISO
    try {
      return DateTime.parse(text);
    } catch (_) {}

    // FORMAT OCR
    try {
      // Split on ANY whitespace (space, new line, tab), not only " ".
      final parts = text.split(RegExp(r'\s+'));
      if (parts.length < 4) return null;

      final day = int.parse(parts[0]);

      final month = _months[_normalizeMonth(parts[1])];
      if (month == null) return null;

      final year = int.parse(parts[2]);

      // The time may use ".", "," or ":" between the numbers, and OCR
      // sometimes gives two characters in a row (for example "10.,44.09").
      final time = parts[3].split(RegExp(r'[.,:]+'));
      if (time.length != 3) return null;

      return DateTime(
        year,
        month,
        day,
        int.parse(time[0]),
        int.parse(time[1]),
        int.parse(time[2]),
      );
    } catch (_) {
      return null;
    }
  }

  /// "NOV", "nov", "N0v", "Nov." -> "Nov"
  static String _normalizeMonth(String raw) {
    final letters = raw
        .replaceAll(RegExp(r'[^A-Za-z0]'), '')
        .replaceAll('0', 'o')
        .toLowerCase();

    if (letters.isEmpty) return letters;
    return letters[0].toUpperCase() + letters.substring(1);
  }

  // ==========================================================
  // FORMAT
  // ==========================================================

  /// Output: 2026-08-02T17:08:15.000
  static String formatStorage(DateTime date) {
    return date.toIso8601String();
  }

  /// Output: 02/08/2026
  static String formatDisplay(DateTime date) {
    String two(int value) => value.toString().padLeft(2, "0");

    return "${two(date.day)}/${two(date.month)}/${date.year}";
  }

  /// Output: 17:08:15
  static String formatTime(DateTime date) {
    String two(int value) => value.toString().padLeft(2, "0");

    return "${two(date.hour)}:${two(date.minute)}:${two(date.second)}";
  }

  /// Output: 02/08/2026 17:08:15
  static String formatDateTime(DateTime date) {
    return "${formatDisplay(date)} ${formatTime(date)}";
  }
}