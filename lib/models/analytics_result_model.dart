import 'equity_point_model.dart';
import 'pair_statistic_model.dart';
import 'drawdown_model.dart';
import 'account_timeline_model.dart';

class AnalyticsResultModel {
  // =============================
  // TRADE STATISTICS
  // =============================

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

  // ===============================
  // ACCOUNT STATISTICS
  // ===============================

  final double totalDeposit;
  final double totalWithdraw;

  /// Saldo terakhir setelah seluruh transaksi diproses
  final double currentBalance;

  // ================================
  // TIMELINE
  // ================================

  final List<AccountTimelineModel> timeline;

  // ================================
  // EQUITY
  // ================================

  final List<EquityPointModel> equity;

  // =================================
  // PAIR PERFORMANCE
  // =================================

  final List<PairStatisticModel> pairPerformance;

  // ==================================
  // DRAWDOWN
  // ==================================

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

    // ACCOUNT
    required this.totalDeposit,
    required this.totalWithdraw,
    required this.currentBalance,

    // TIMELINE
    required this.timeline,

    // EQUITY
    required this.equity,

    // PAIR
    required this.pairPerformance,

    // DRAWDOWN
    required this.drawdown,
  });
}
