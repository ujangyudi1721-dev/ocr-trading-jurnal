import '../models/account_timeline_model.dart';
import '../models/account_transaction_model.dart';
import '../models/trade_model.dart';

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
        print(
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
        print(
          "WARNING: Invalid trade close date: "
          "${trade.ticket}",
        );
        continue;
      }

      final double profit =
          double.tryParse(
                trade.profit.replaceAll("+", ""),
              ) ??
              0;

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

    timeline.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    // ========================================================
    // HITUNG RUNNING BALANCE
    // ========================================================

    calculateBalance(timeline);

    // ========================================================
    // DEBUG
    // ========================================================

    print("");
    print("========== TIMELINE ==========");

    for (final item in timeline) {
      print(
        "${item.date} | "
        "${item.type} | "
        "${item.amount} | "
        "Balance=${item.balance.toStringAsFixed(2)} | "
        "${item.reference}",
      );
    }

    print("==============================");
    print("");

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

  static void calculateBalance(
    List<AccountTimelineModel> timeline,
  ) {
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