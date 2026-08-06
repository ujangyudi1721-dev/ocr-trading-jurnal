import '../models/account_timeline_model.dart';
import '../models/account_transaction_model.dart';
import '../models/trade_model.dart';

class AccountTimelineService {
  // ============================================================
  // GENERATE TIMELINE
  //
  // Tahap ini HANYA membuat daftar event.
  //
  // Belum melakukan:
  // - Sorting
  // - Running Balance
  // - Drawdown
  //
  // Semua proses tersebut akan dikerjakan pada step berikutnya.
  // ============================================================

  static List<AccountTimelineModel> generate({
    required List<AccountTransactionModel> transactions,
    required List<TradeModel> trades,
  }) {
    final List<AccountTimelineModel> timeline = [];

    // ============================================================
    // ACCOUNT TRANSACTION
    //
    // Deposit
    // Withdraw
    // ============================================================

    for (final transaction in transactions) {
      timeline.add(
        AccountTimelineModel(
          date: transaction.dateTime ?? DateTime.now(),
          type: transaction.type,
          amount: transaction.amount,

          // sementara belum dihitung
          balance: 0,

          // referensi transaksi
          reference: transaction.type,
        ),
      );
    }

    // ============================================================
    // TRADE
    // ============================================================

    for (final trade in trades) {
      final double profit =
          double.tryParse(trade.profit.replaceAll("+", "")) ?? 0;

      timeline.add(
        AccountTimelineModel(
          // gunakan waktu close trade
          date: trade.closeDateTime ?? DateTime.now(),

          type: "Trade",

          amount: profit,

          // sementara belum dihitung
          balance: 0,

          // nomor ticket
          reference: trade.ticket,
        ),
      );
    }

    // ============================================================
    // SORT TIMELINE
    //
    // Urutkan semua event berdasarkan tanggal
    // dari yang paling lama ke yang paling baru.
    // ============================================================

    timeline.sort((a, b) => a.date.compareTo(b.date));

    print("========== TIMELINE ==========");

    for (final item in timeline) {
      print("${item.date} | ${item.type} | ${item.amount}");
    }

    print("==============================");
    // ============================================================
    // RETURN
    // ============================================================

    return timeline;
  }
}
