import '../models/account_timeline_model.dart';
import '../models/analytics_result_model.dart';
import '../models/drawdown_model.dart';
import '../models/equity_point_model.dart';
import '../models/pair_statistic_model.dart';

class AnalyticsEngine {
  // ==========================================================
  // ANALYTICS ENGINE
  //
  // Single Source of Truth:
  // Semua statistik dihitung dari Timeline.
  // ==========================================================
  static AnalyticsResultModel calculate(List<AccountTimelineModel> timeline) {
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
    // LOOP TIMELINE
    // ========================================================

    for (int i = 0; i < timeline.length; i++) {
      final item = timeline[i];

      switch (item.type) {
        case "Deposit":
          totalDeposit += item.amount;
          break;

        case "Withdraw":
          totalWithdraw += item.amount;
          break;

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

      // ====================================================
      // CURRENT BALANCE
      // ====================================================

      currentBalance = item.balance;
    }

    // ========================================================
    // FINAL CALCULATION
    // ========================================================

    final double netProfit = grossProfit - grossLoss;

    final double winRate = totalTrade == 0 ? 0 : (totalWin / totalTrade) * 100;

    final double averageWin = totalWin == 0 ? 0 : grossProfit / totalWin;

    final double averageLoss = totalLoss == 0 ? 0 : grossLoss / totalLoss;

    final double profitFactor = grossLoss == 0 ? 0 : grossProfit / grossLoss;

    final drawdown = calculateDrawdown(timeline);

    final equity = calculateEquity(timeline);

    final pairPerformance = calculatePairPerformance(timeline);
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

  // ==========================================================
  // CALCULATE DRAWDOWN
  // ==========================================================
  static DrawdownModel calculateDrawdown(List<AccountTimelineModel> timeline) {
    double peakBalance = 0;

    double currentBalance = 0;

    double currentDrawdown = 0;

    double maximumDrawdown = 0;

    for (final item in timeline) {
      currentBalance = item.balance;

      // Peak baru
      if (currentBalance > peakBalance) {
        peakBalance = currentBalance;
      }

      // Hitung drawdown dari peak
      double drawdown = 0;

      if (peakBalance > 0) {
        drawdown = ((peakBalance - currentBalance) / peakBalance) * 100;
      }

      // Simpan drawdown terbesar
      if (drawdown > maximumDrawdown) {
        maximumDrawdown = drawdown;
      }

      // Drawdown terakhir
      currentDrawdown = drawdown;
    }

    return DrawdownModel(
      peakBalance: peakBalance,
      currentBalance: currentBalance,
      currentDrawdown: currentDrawdown,
      maximumDrawdown: maximumDrawdown,
    );
  }

  // ==========================================================
  // CALCULATE EQUITY
  // ==========================================================
  static List<EquityPointModel> calculateEquity(
    List<AccountTimelineModel> timeline,
  ) {
    final List<EquityPointModel> equity = [];

    for (int i = 0; i < timeline.length; i++) {
      equity.add(EquityPointModel(index: i + 1, balance: timeline[i].balance));
    }

    return equity;
  }

  // ==========================================================
  // CALCULATE PAIR PERFORMANCE
  // ==========================================================
  static List<PairStatisticModel> calculatePairPerformance(
    List<AccountTimelineModel> timeline,
  ) {
    final Map<String, PairStatisticModel> pairMap = {};

    for (final item in timeline) {
      if (item.type != "Trade") continue;

      final pair = item.pair ?? "UNKNOWN";

      if (!pairMap.containsKey(pair)) {
        pairMap[pair] = PairStatisticModel(
          pair: pair,
          totalTrade: 0,
          profit: 0,
        );
      }

      final old = pairMap[pair]!;

      pairMap[pair] = PairStatisticModel(
        pair: old.pair,
        totalTrade: old.totalTrade + 1,
        profit: old.profit + item.amount,
      );
    }

    final result = pairMap.values.toList();

    result.sort((a, b) => b.profit.compareTo(a.profit));

    return result;
  }
}
