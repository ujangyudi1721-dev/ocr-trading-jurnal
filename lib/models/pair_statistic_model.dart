/// Rekap performa trading untuk satu pair tertentu (mis. "XAUUSD"),
/// dipakai oleh `PairPerformanceCard` di Dashboard untuk menunjukkan
/// pair mana yang paling menguntungkan/merugikan.
///
/// Bentuknya sengaja mirip [EmotionStatisticModel] — sama-sama hasil
/// pengelompokan trade, bedanya kunci grouping-nya pair vs emosi.
class PairStatisticModel {
  final String pair;
  final int totalTrade;
  final double profit;
  final int totalWin;
  final int totalLoss;

  PairStatisticModel({
    required this.pair,
    required this.totalTrade,
    required this.profit,
    required this.totalWin,
    required this.totalLoss,
  });

  /// Persentase trade yang profit (0-100), 0 kalau belum ada trade
  /// untuk pair ini (hindari pembagian dengan nol).
  double get winRate => totalTrade == 0 ? 0 : totalWin / totalTrade * 100;

  /// Rata-rata profit/loss per trade untuk pair ini.
  double get averageProfit => totalTrade == 0 ? 0 : profit / totalTrade;
}
