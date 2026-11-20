import '../models/trade_model.dart';
import '../utils/app_logger.dart';
import '../utils/date_helper.dart';

/// Mengekstrak field-field [TradeModel] (pair, lot, profit, tanggal, dst)
/// dari teks mentah hasil OCR (ML Kit) atas screenshot popup detail
/// trade di MetaTrader.
///
/// Semua logic di sini murni regex/pattern-matching terhadap teks —
/// tidak ada akses database atau I/O. Karena sumbernya OCR (bisa salah
/// baca / format tidak konsisten), field yang gagal ditemukan diisi
/// nilai default ("UNKNOWN"/"0") di bagian VALIDATION di bawah,
/// bukan dibiarkan kosong atau melempar error.
class OCRParser {
  /// Parse [text] hasil OCR menjadi satu [TradeModel].
  static TradeModel parse(String text) {
    String ticket = "";
    String pair = "";
    String type = "";
    String lot = "";
    String profit = "";

    String openTime = "";
    String closeTime = "";

    String sl = "";
    String tp = "";

    String openPrice = "";
    String closePrice = "";

    // =========================
    // TICKET
    // =========================

    final ticketMatch = RegExp(r'#(\d+)').firstMatch(text);

    if (ticketMatch != null) {
      ticket = ticketMatch.group(1)!;
    }

    // =========================
    // PAIR
    // =========================

    final pairs = [
      "XAU/USD",
      "BTC",
      "ETH",
      "SOL",
      "EUR/USD",
      "GBP/USD",
      "USD/JPY",
      "US30",
      "NAS100",
      "GER40",
    ];
    for (final p in pairs) {
      if (text.contains(p)) {
        pair = p;
        break;
      }
    }
    // =========================
    // BUY / SELL + LOT
    // =========================

    final sellMatches = RegExp(r'Jual\s+(\d+\.\d+)').allMatches(text).toList();

    final buyMatches = RegExp(r'Beli\s+(\d+\.\d+)').allMatches(text).toList();

    if (sellMatches.isNotEmpty) {
      type = "SELL";
      lot = sellMatches.last.group(1)!;
    }

    if (buyMatches.isNotEmpty) {
      type = "BUY";
      lot = buyMatches.last.group(1)!;
    }

    // =========================
    // PROFIT
    // ambil profit terakhir
    // =========================

    final profitMatches = RegExp(
      r'([+-](?:\d{1,3}(?:,\d{3})+|\d+)\.\d+)\s*USC',
    ).allMatches(text).toList();

    if (profitMatches.isNotEmpty) {
      profit = profitMatches.last.group(1)!.replaceAll(',', '');
    }

    // =========================
    // OPEN TIME / CLOSE TIME
    //
    // Tahan terhadap hasil OCR yang tidak rapi:
    // - tanggal terpecah beberapa baris
    // - spasi ganda atau spasi khusus
    // - jam memakai ":" bukan "."
    // - angka 0 menggantikan huruf "o" di nama bulan (N0v)
    // - tanggal dan jam terbaca sebagai potongan terpisah
    //   (kolom kanan dibaca terpisah dari labelnya)
    // - pemisah jam ganda, misalnya "10.,44.09"
    // =========================

    // Membersihkan hasil tangkapan:
    // - baris baru / spasi ganda -> satu spasi
    // - pemisah jam yang berantakan ("10.,44") -> satu titik ("10.44")
    String cleanDateTime(String raw) {
      return raw
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAllMapped(
            RegExp(r'(\d)[.,:]+(\d)'),
            (m) => "${m[1]}.${m[2]}",
          );
    }

    // Cara 1: tanggal dan jam berdekatan ("20 Nov 2026 10.44.09").
    // Pemisah jam boleh lebih dari satu karakter ("10.,44.09").
    final dateTimes = RegExp(
      r'\d{1,2}\s+[A-Za-z0]{3,4}\.?\s+\d{4}\s+\d{1,2}[.,:]+\d{2}[.,:]+\d{2}',
    ).allMatches(text).map((m) => cleanDateTime(m.group(0)!)).toList();

    // Cara 2 (cadangan): tanggal dan jam terbaca terpisah. Ambil semua
    // tanggal dan semua jam, lalu pasangkan menurut urutannya.
    if (dateTimes.length < 2) {
      // Hanya terima tanggal yang bulannya dikenal. Ini mencegah teks
      // seperti "10 pada 3549" (dari "0.10 pada 3549.655") dikira tanggal.
      bool isRealDate(String d) => DateHelper.parse("$d 00.00.00") != null;

      final dates = RegExp(r'\d{1,2}\s+[A-Za-z0]{3,4}\.?\s+\d{4}')
          .allMatches(text)
          .map((m) => cleanDateTime(m.group(0)!))
          .where(isRealDate)
          .toList();

      final times = RegExp(
        r'\d{1,2}[.,:]+\d{2}[.,:]+\d{2}',
      ).allMatches(text).map((m) => cleanDateTime(m.group(0)!)).toList();

      if (dates.length >= 2 && times.length >= 2) {
        dateTimes
          ..clear()
          ..add("${dates[0]} ${times[0]}")
          ..add("${dates[1]} ${times[1]}");
      }
    }

    AppLogger.log("===== DATE MATCHES =====");

    for (final d in dateTimes) {
      AppLogger.log(d);
    }

    AppLogger.log("========================");

    if (dateTimes.length >= 2) {
      openTime = dateTimes[0];
      closeTime = dateTimes[1];
    }

    // =========================
    // HARGA
    // =========================

    final priceMatches = RegExp(
      r'(?:\d{1,3}(?:,\d{3})+|\d+)\.\d+',
    ).allMatches(text);

    List<String> prices = [];

    for (final match in priceMatches) {
      final value = match.group(0)!;

      prices.add(value.replaceAll(',', ''));
    }

    AppLogger.log("===== SEMUA HARGA =====");

    for (final p in prices) {
      AppLogger.log(p);
    }

    AppLogger.log("=======================");

    if (prices.length >= 4) {
      sl = prices[prices.length - 4];
      tp = prices[prices.length - 3];
      openPrice = prices[prices.length - 2];
      closePrice = prices[prices.length - 1];
    }

    // =========================
    // DEBUG
    // =========================

    AppLogger.log("========== HASIL PARSER ==========");

    AppLogger.log("Ticket      : $ticket");
    AppLogger.log("Pair        : $pair");
    AppLogger.log("Type        : $type");
    AppLogger.log("Lot         : $lot");
    AppLogger.log("Profit      : $profit");

    AppLogger.log("Open Time   : $openTime");
    AppLogger.log("Close Time  : $closeTime");

    AppLogger.log("SL          : $sl");
    AppLogger.log("TP          : $tp");

    AppLogger.log("Open Price  : $openPrice");
    AppLogger.log("Close Price : $closePrice");

    AppLogger.log("==================================");

    // ========================================
    // SECTION VALIDATION
    // ========================================

    ticket = ticket.trim();
    pair = pair.trim();
    type = type.trim();
    lot = lot.trim();
    profit = profit.trim();

    openTime = openTime.trim();
    closeTime = closeTime.trim();

    sl = sl.trim();
    tp = tp.trim();

    openPrice = openPrice.trim();
    closePrice = closePrice.trim();

    if (ticket.isEmpty) {
      ticket = "UNKNOWN";
    }

    if (pair.isEmpty) {
      pair = "UNKNOWN";
    }

    if (type.isEmpty) {
      type = "UNKNOWN";
    }

    if (lot.isEmpty) {
      lot = "0";
    }

    if (profit.isEmpty) {
      profit = "0";
    }

    return TradeModel(
      ticket: ticket,
      pair: pair,
      type: type,
      lot: lot,
      profit: profit,
      openTime: openTime,
      closeTime: closeTime,
      sl: sl,
      tp: tp,
      openPrice: openPrice,
      closePrice: closePrice,
    );
  }
}
