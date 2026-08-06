class StatisticModel {
  final int totalTrade;
  final int totalWin;
  final int totalLoss;

  final double winRate;

  final double grossProfit;
  final double grossLoss;

  final double netProfit;

  StatisticModel({
    required this.totalTrade,
    required this.totalWin,
    required this.totalLoss,
    required this.winRate,
    required this.grossProfit,
    required this.grossLoss,
    required this.netProfit,
  });
}