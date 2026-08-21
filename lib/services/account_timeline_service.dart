import '../models/account_timeline_model.dart';
import '../models/account_transaction_model.dart';
import '../models/trade_model.dart';
import '../utils/app_logger.dart';

/// Menggabungkan dua sumber data terpisah — [AccountTransactionModel]
/// (deposit/withdraw manual) dan [TradeModel] (hasil OCR) — jadi satu
/// [AccountTimelineModel] terurut dengan saldo berjalan (running balance).
///
/// Ini adalah titik masuk (entry point) utama sebelum data dipakai oleh
/// `AnalyticsEngine`, `DailyReportService`, maupun `DrawdownService` —
/// ketiganya hanya menerima [AccountTimelineModel], bukan data mentah.
class AccountTimelineService {
  // ==========================================================
  // GENERATE TIMELINE
  //
  // Membuat daftar seluruh event account:
  // - Deposit
  // - Withdraw
  // - Trade
  //
  // Urutan:
  // 1. Ambil semua event
  // 2. Validasi tanggal
  // 3. Sort dari tanggal paling lama -> terbaru
  // 4. Hitung running balance
  // ==========================================================

  /// Gabungkan [transactions] dan [trades] jadi satu timeline terurut
  /// (lama -> baru) lengkap dengan saldo berjalan.
  ///
  /// Item dengan tanggal yang gagal di-parse akan dilewati (bukan
  /// dianggap `DateTime.now()`) supaya tidak masuk ke tanggal yang salah.
  static List<AccountTimelineModel> generate({
    required List<AccountTransactionModel> transactions,
    required List<TradeModel> trades,
  }) {
    final List<AccountTimelineModel> timeline = [];

    // ========================================================
    // ACCOUNT TRANSACTION
    // ========================================================

    for (final transaction in transactions) {
      final date = transaction.dateTime;

      // Jangan gunakan DateTime.now() sebagai fallback.
      // Kalau tanggal tidak valid, data dilewati agar tidak
      // masuk ke timeline pada tanggal yang salah.
      if (date == null) {
        AppLogger.log(
          "WARNING: Invalid transaction date: "
          "${transaction.date}",
        );
        continue;
      }

      timeline.add(
        AccountTimelineModel(
          date: date,
          type: transaction.type,
          amount: transaction.amount,
          balance: 0,
          reference: transaction.type,
        ),
      );
    }

    // ========================================================
    // TRADE
    // ========================================================

    for (final trade in trades) {
      final date = trade.closeDateTime;

      // Jangan gunakan DateTime.now() sebagai fallback.
      if (date == null) {
        AppLogger.log(
          "WARNING: Invalid trade close date: "
          "${trade.ticket}",
        );
        continue;
      }

      final double profit =
          double.tryParse(trade.profit.replaceAll("+", "")) ?? 0;

      timeline.add(
        AccountTimelineModel(
          date: date,
          type: "Trade",
          amount: profit,
          balance: 0,
          reference: trade.ticket,
          pair: trade.pair,
          tradeType: trade.type,
          emotion: trade.emotion,
        ),
      );
    }

    // ========================================================
    // SORT TIMELINE
    //
    // PENTING:
    // Timeline internal harus dari LAMA -> BARU.
    //
    // Ini diperlukan agar running balance benar.
    // ========================================================

    timeline.sort((a, b) => a.date.compareTo(b.date));

    // ========================================================
    // HITUNG RUNNING BALANCE
    // ========================================================

    calculateBalance(timeline);

    // ========================================================
    // DEBUG
    // ========================================================

    AppLogger.log("");
    AppLogger.log("========== TIMELINE ==========");

    for (final item in timeline) {
      AppLogger.log(
        "${item.date} | "
        "${item.type} | "
        "${item.amount} | "
        "Balance=${item.balance.toStringAsFixed(2)} | "
        "${item.reference}",
      );
    }

    AppLogger.log("==============================");
    AppLogger.log("");

    return timeline;
  }

  // ==========================================================
  // CALCULATE RUNNING BALANCE
  //
  // Timeline harus sudah di-sort LAMA -> BARU.
  //
  // Deposit  -> +
  // Withdraw -> -
  // Trade    -> Profit/Loss
  // ==========================================================

  /// Isi field `balance` setiap item di [timeline] secara berjalan
  /// (running total), dari item pertama sampai terakhir. [timeline]
  /// diubah langsung di tempat (in-place), tidak me-return list baru.
  static void calculateBalance(List<AccountTimelineModel> timeline) {
    double balance = 0;

    for (final item in timeline) {
      switch (item.type) {
        case "Deposit":
          balance += item.amount;
          break;

        case "Withdraw":
          balance -= item.amount;
          break;

        case "Trade":
          balance += item.amount;
          break;
      }

      item.balance = balance;
    }
  }
}
