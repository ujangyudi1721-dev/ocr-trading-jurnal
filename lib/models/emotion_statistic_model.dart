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

  double get winRate => totalTrade == 0 ? 0 : totalWin / totalTrade * 100;

  double get averageProfit => totalTrade == 0 ? 0 : profit / totalTrade;
}
