import '../models/account_timeline_model.dart';
import '../models/analytics_result_model.dart';
import '../models/drawdown_model.dart';
import '../models/equity_point_model.dart';
import '../models/pair_statistic_model.dart';

class AnalyticsEngine {
  // ==========================================================
  // ANALYTICS ENGINE
  //
  // Semua statistik dihitung dari Timeline.
  // Timeline merupakan Single Source of Truth.
  // ==========================================================

  static AnalyticsResultModel calculate(
    List<AccountTimelineModel> timeline,
  ) {
    // ========================================================
    // TRADE STATISTIC
    // ========================================================

    int totalTrade = 0;
    int totalWin = 0;
    int totalLoss = 0;

    double grossProfit = 0;
    double grossLoss = 0;

    // ========================================================
    // ACCOUNT
    // ========================================================

    double totalDeposit = 0;
    double totalWithdraw = 0;

    double currentBalance = 0;

    // ========================================================
    // PLACEHOLDER
    // (akan kita isi pada step berikutnya)
    // ========================================================

    List<EquityPointModel> equity = [];

    List<PairStatisticModel> pairPerformance = [];

    DrawdownModel drawdown = const DrawdownModel(
      peakBalance: 0,
      currentBalance: 0,
      currentDrawdown: 0,
      maximumDrawdown: 0,
    );

    // ========================================================
    // LOOP TIMELINE
    // ========================================================

    for (final item in timeline) {
      switch (item.type) {
        // ----------------------------
        // DEPOSIT
        // ----------------------------

        case "Deposit":
          totalDeposit += item.amount;
          break;

        // ----------------------------
        // WITHDRAW
        // ----------------------------

        case "Withdraw":
          totalWithdraw += item.amount;
          break;

        // ----------------------------
        // TRADE
        // ----------------------------

        case "Trade":
          totalTrade++;

          if (item.amount >= 0) {
            totalWin++;
            grossProfit += item.amount;
          } else {
            totalLoss++;
            grossLoss += item.amount.abs();
          }

          break;
      }

      // Balance terakhir selalu disimpan
      currentBalance = item.balance;
    }

    // ========================================================
    // HITUNG HASIL
    // ========================================================

    double netProfit = grossProfit - grossLoss;

    double winRate = 0;

    if (totalTrade > 0) {
      winRate = (totalWin / totalTrade) * 100;
    }

    double averageWin = 0;

    if (totalWin > 0) {
      averageWin = grossProfit / totalWin;
    }

    double averageLoss = 0;

    if (totalLoss > 0) {
      averageLoss = grossLoss / totalLoss;
    }

    double profitFactor = 0;

    if (grossLoss > 0) {
      profitFactor = grossProfit / grossLoss;
    }

    // ========================================================
    // RETURN
    // ========================================================

    return AnalyticsResultModel(
      totalTrade: totalTrade,
      totalWin: totalWin,
      totalLoss: totalLoss,
      grossProfit: grossProfit,
      grossLoss: grossLoss,
      netProfit: netProfit,
      winRate: winRate,
      averageWin: averageWin,
      averageLoss: averageLoss,
      profitFactor: profitFactor,
      totalDeposit: totalDeposit,
      totalWithdraw: totalWithdraw,
      currentBalance: currentBalance,
      timeline: timeline,
      equity: equity,
      pairPerformance: pairPerformance,
      drawdown: drawdown,
    );
  }
}