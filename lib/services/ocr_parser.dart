import '../models/trade_model.dart';

class OCRParser {
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

    print("===== DATE MATCHES =====");

    for (var d in dateMatches) {
      print(d.group(0));
    }

    print("========================");

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

    print("===== SEMUA HARGA =====");

    for (final p in prices) {
      print(p);
    }

    print("=======================");

    if (prices.length >= 4) {
      sl = prices[prices.length - 4];
      tp = prices[prices.length - 3];
      openPrice = prices[prices.length - 2];
      closePrice = prices[prices.length - 1];
    }

    // =========================
    // DEBUG
    // =========================

    print("========== HASIL PARSER ==========");

    print("Ticket      : $ticket");
    print("Pair        : $pair");
    print("Type        : $type");
    print("Lot         : $lot");
    print("Profit      : $profit");

    print("Open Time   : $openTime");
    print("Close Time  : $closeTime");

    print("SL          : $sl");
    print("TP          : $tp");

    print("Open Price  : $openPrice");
    print("Close Price : $closePrice");

    print("==================================");

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
