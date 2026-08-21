import '../models/trade_model.dart';
import '../utils/app_logger.dart';

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
      r'([+-]\d+\.\d+)\s*USC',
    ).allMatches(text).toList();

    if (profitMatches.isNotEmpty) {
      profit = profitMatches.last.group(1)!;
    }

    // =========================
    // OPEN TIME / CLOSE TIME
    // =========================

    final dateMatches = RegExp(
      r'\d+\s+\w+\s+\d+\s+\d+[.,]\d+[.,]\d+',
    ).allMatches(text).toList();

    AppLogger.log("===== DATE MATCHES =====");

    for (var d in dateMatches) {
      AppLogger.log(d.group(0));
    }

    AppLogger.log("========================");

    if (dateMatches.length >= 2) {
      openTime = dateMatches[0].group(0)!;
      closeTime = dateMatches[1].group(0)!;
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
