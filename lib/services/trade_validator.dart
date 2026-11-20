import '../models/trade_model.dart';

/// Validasi apakah hasil parsing OCR ([OCRParser]) cukup lengkap untuk
/// disimpan, atau harus ditolak/diminta scan ulang.
class TradeValidator {
  /// Daftar alasan kenapa [trade] tidak valid. Kosong = valid.
  static List<String> reasons(TradeModel trade) {
    final List<String> result = [];

    if (trade.ticket == "UNKNOWN") {
      result.add("Nomor tiket tidak terbaca");
    }

    if (trade.pair == "UNKNOWN") {
      result.add("Pair tidak terbaca");
    }

    if (trade.openDateTime == null) {
      result.add('Waktu buka tidak terbaca (teks: "${trade.openTime}")');
    }

    if (trade.closeDateTime == null) {
      result.add('Waktu tutup tidak terbaca (teks: "${trade.closeTime}")');
    }

    return result;
  }

  /// `true` kalau [trade] punya cukup data untuk disimpan.
  static bool isValid(TradeModel trade) {
    return reasons(trade).isEmpty;
  }
}