/// Rekap satu hari trading (dipakai di `DailyReportPage`), hasil
/// mengelompokkan [AccountTimelineModel] per tanggal oleh
/// `DailyReportService.generate()`.
class DailyReportModel {
  // Tanggal laporan (jam selalu 00:00:00)
  final DateTime date;

  // ================================
  // BALANCE
  // ================================

  // Balance sebelum event pertama hari ini
  final double openingBalance;

  // Balance setelah event terakhir hari ini
  final double closingBalance;

  // ================================
  // HASIL TRADING
  // ================================

  // Untung / rugi hari ini (khusus Trade)
  final double profit;

  // Persentase profit terhadap balance awal hari
  final double profitPercent;

  final int totalTrade;
  final int totalWin;
  final int totalLoss;

  // ================================
  // TRANSAKSI ACCOUNT
  // ================================

  final double deposit;
  final double withdraw;

  DailyReportModel({
    required this.date,
    required this.openingBalance,
    required this.closingBalance,
    required this.profit,
    required this.profitPercent,
    required this.totalTrade,
    required this.totalWin,
    required this.totalLoss,
    required this.deposit,
    required this.withdraw,
  });

  // ==========================================
  // HELPER
  // ==========================================

  /// `true` kalau hari ini profit (atau break-even).
  bool get isProfit => profit >= 0;

  /// Persentase trade yang profit hari ini (0-100), 0 kalau belum ada
  /// trade hari itu (hindari pembagian dengan nol).
  double get winRate {
    if (totalTrade == 0) return 0;

    return totalWin / totalTrade * 100;
  }
}
