import 'package:flutter/material.dart';

/// Satu pilihan emosi (dipakai saat user tag emosi ke sebuah trade).
///
/// [key] adalah nilai yang disimpan ke database (harus persis sama
/// dengan yang dipakai di [TradeModel.emotion]), sedangkan [label],
/// [icon], dan [color] hanya untuk tampilan UI.
class EmotionOption {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const EmotionOption({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });
}

/// Daftar semua emosi yang bisa dipilih user, plus helper untuk
/// mencari [EmotionOption] dari key yang tersimpan di database.
class EmotionConstants {
  // Daftar emosi yang ditampilkan di dropdown/chip picker.
  static const List<EmotionOption> options = [
    EmotionOption(
      key: "Tenang",
      label: "Tenang",
      icon: Icons.self_improvement,
      color: Colors.green,
    ),

    EmotionOption(
      key: "Percaya Diri",
      label: "Percaya Diri",
      icon: Icons.thumb_up,
      color: Colors.blue,
    ),

    EmotionOption(
      key: "Serakah",
      label: "Serakah",
      icon: Icons.attach_money,
      color: Colors.orange,
    ),

    EmotionOption(
      key: "Takut / Ragu",
      label: "Takut / Ragu",
      icon: Icons.warning_amber,
      color: Colors.purple,
    ),

    EmotionOption(
      key: "FOMO",
      label: "FOMO",
      icon: Icons.bolt,
      color: Colors.red,
    ),

    EmotionOption(
      key: "Balas Dendam",
      label: "Balas Dendam",
      icon: Icons.whatshot,
      color: Colors.redAccent,
    ),

    EmotionOption(
      key: "Bosan",
      label: "Bosan",
      icon: Icons.hourglass_empty,
      color: Colors.grey,
    ),
  ];

  /// Cari [EmotionOption] berdasarkan [key] yang tersimpan di trade.
  /// Return `null` kalau [key] null atau tidak ditemukan di [options].
  static EmotionOption? find(String? key) {
    if (key == null) return null;

    for (final option in options) {
      if (option.key == key) return option;
    }

    return null;
  }
}
