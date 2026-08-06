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
  // Setelah semua event dibuat:
  // 1. Sort berdasarkan tanggal
  // 2. Hitung running balance
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
      timeline.add(
        AccountTimelineModel(
          date: transaction.dateTime ?? DateTime.now(),
          type: transaction.type,
          amount: transaction.amount,

          // akan dihitung nanti
          balance: 0,

          reference: transaction.type,
        ),
      );
    }

    // ========================================================
    // TRADE
    // ========================================================

    for (final trade in trades) {
      final double profit =
          double.tryParse(
                trade.profit.replaceAll("+", ""),
              ) ??
              0;

      timeline.add(
        AccountTimelineModel(
          date: trade.closeDateTime ?? DateTime.now(),
          type: "Trade",
          amount: profit,

          // akan dihitung nanti
          balance: 0,

          reference: trade.ticket,

          // khusus trade
          pair: trade.pair,
          tradeType: trade.type,
        ),
      );
    }

    // ========================================================
    // SORT TIMELINE
    // ========================================================

    timeline.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    // ========================================================
    // HITUNG BALANCE
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
  // Timeline HARUS sudah di-sort.
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