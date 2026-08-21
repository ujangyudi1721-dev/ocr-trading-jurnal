import '../models/trade_model.dart';

/// Validasi apakah hasil parsing OCR ([OCRParser]) cukup lengkap untuk
/// disimpan, atau harus ditolak/diminta scan ulang.
class TradeValidator {
  /// `true` kalau [trade] punya cukup data untuk disimpan.
  ///
  /// Field yang gagal terbaca oleh [OCRParser] diisi "UNKNOWN" —
  /// kalau ticket atau pair masih "UNKNOWN", trade dianggap tidak valid
  /// karena dua field itu wajib ada untuk mengidentifikasi trade-nya.
  static bool isValid(TradeModel trade) {
    if (trade.ticket == "UNKNOWN") {
      return false;
    }

    if (trade.pair == "UNKNOWN") {
      return false;
    }

    return true;
  }
}
