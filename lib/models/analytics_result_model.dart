import 'equity_point_model.dart';
import 'pair_statistic_model.dart';
import 'drawdown_model.dart';

class AnalyticsResultModel {
  final int totalTrade;
  final int totalWin;
  final int totalLoss;

  final double grossProfit;
  final double grossLoss;
  final double netProfit;

  final double winRate;

  final double averageWin;
  final double averageLoss;

  final double profitFactor;

  final List<EquityPointModel> equity;

  final List<PairStatisticModel> pairPerformance;

  final DrawdownModel drawdown;

  AnalyticsResultModel({
    required this.totalTrade,
    required this.totalWin,
    required this.totalLoss,
    required this.grossProfit,
    required this.grossLoss,
    required this.netProfit,
    required this.winRate,
    required this.averageWin,
    required this.averageLoss,
    required this.profitFactor,
    required this.equity,
    required this.pairPerformance,
    required this.drawdown,
  });
}
