/// Rekap performa trading untuk satu tag emosi tertentu (mis. "Serakah"),
/// dipakai oleh `EmotionPerformanceCard` di Dashboard untuk menunjukkan
/// emosi mana yang cenderung menghasilkan profit vs loss.
///
/// Dihitung oleh `AnalyticsEngine` dengan mengelompokkan semua trade
/// berdasarkan `TradeModel.emotion`.
class EmotionStatisticModel {
  final String emotion;
  final int totalTrade;
  final double profit;
  final int totalWin;
  final int totalLoss;

  EmotionStatisticModel({
    required this.emotion,
    required this.totalTrade,
    required this.profit,
    required this.totalWin,
    required this.totalLoss,
  });

  /// Persentase trade yang profit (0-100), 0 kalau belum ada trade
  /// dengan emosi ini (hindari pembagian dengan nol).
  double get winRate => totalTrade == 0 ? 0 : totalWin / totalTrade * 100;

  /// Rata-rata profit/loss per trade untuk emosi ini.
  double get averageProfit => totalTrade == 0 ? 0 : profit / totalTrade;
}
