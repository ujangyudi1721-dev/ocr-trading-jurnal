import '../models/account_timeline_model.dart';
import '../models/daily_report_model.dart';

class DailyReportService {
  // ==========================================================
  // GENERATE LAPORAN HARIAN
  //
  // Input:
  // Timeline account (Deposit / Withdraw / Trade)
  // yang sudah punya running balance.
  //
  // Proses:
  // 1. Sort dari tanggal paling lama -> terbaru
  // 2. Kelompokkan per tanggal (tanpa jam)
  // 3. Hitung profit/loss + persentase per hari
  //
  // Output:
  // List laporan dari tanggal LAMA -> BARU.
  // ==========================================================

  static List<DailyReportModel> generate(
    List<AccountTimelineModel> timeline,
  ) {
    if (timeline.isEmpty) {
      return [];
    }

    // ========================================================
    // SORT (jangan ubah list aslinya)
    // ========================================================

    final sorted = [...timeline]
      ..sort((a, b) => a.date.compareTo(b.date));

    // ========================================================
    // GROUP PER TANGGAL
    //
    // Map di Dart menjaga urutan input,
    // jadi urutan hari tetap LAMA -> BARU.
    // ========================================================

    final Map<DateTime, List<AccountTimelineModel>> grouped = {};

    for (final item in sorted) {
      final day = DateTime(
        item.date.year,
        item.date.month,
        item.date.day,
      );

      grouped.putIfAbsent(day, () => []).add(item);
    }

    // ========================================================
    // HITUNG PER HARI
    // ========================================================

    final List<DailyReportModel> reports = [];

    // Balance penutup hari sebelumnya.
    // Hari pertama selalu mulai dari 0.
    double previousBalance = 0;

    for (final entry in grouped.entries) {
      final items = entry.value;

      double profit = 0;
      double deposit = 0;
      double withdraw = 0;

      int totalTrade = 0;
      int totalWin = 0;
      int totalLoss = 0;

      for (final item in items) {
        switch (item.type) {
          case "Deposit":
            deposit += item.amount;
            break;

          case "Withdraw":
            withdraw += item.amount;
            break;

          case "Trade":
            profit += item.amount;
            totalTrade++;

            // Break even (0) dihitung sebagai win,
            // sama seperti perhitungan analytics.
            if (item.amount >= 0) {
              totalWin++;
            } else {
              totalLoss++;
            }
            break;
        }
      }

      final double openingBalance = previousBalance;

      final double closingBalance = items.last.balance;

      // ====================================================
      // BASE PERSENTASE
      //
      // Normalnya persentase dihitung dari balance awal hari.
      //
      // Kasus khusus:
      // Hari pertama balance awal = 0 (belum ada modal),
      // sehingga persentase tidak bisa dihitung.
      // Untuk hari seperti itu, deposit hari tersebut
      // dipakai sebagai modal awal.
      // ====================================================

      double base = openingBalance;

      if (base <= 0) {
        base = openingBalance + deposit;
      }

      final double profitPercent = base <= 0 ? 0 : profit / base * 100;

      reports.add(
        DailyReportModel(
          date: entry.key,
          openingBalance: openingBalance,
          closingBalance: closingBalance,
          profit: profit,
          profitPercent: profitPercent,
          totalTrade: totalTrade,
          totalWin: totalWin,
          totalLoss: totalLoss,
          deposit: deposit,
          withdraw: withdraw,
        ),
      );

      previousBalance = closingBalance;
    }

    // ========================================================
    // DEBUG
    // ========================================================

    print("");
    print("========== DAILY REPORT ==========");

    for (final report in reports) {
      print(
        "${report.date.day}/${report.date.month}/${report.date.year} | "
        "Open=${report.openingBalance.toStringAsFixed(2)} | "
        "Profit=${report.profit.toStringAsFixed(2)} | "
        "${report.profitPercent.toStringAsFixed(2)}% | "
        "Close=${report.closingBalance.toStringAsFixed(2)} | "
        "Trade=${report.totalTrade}",
      );
    }

    print("==================================");
    print("");

    return reports;
  }
}
