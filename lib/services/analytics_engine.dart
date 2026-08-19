import '../models/account_timeline_model.dart';
import '../models/analytics_result_model.dart';
import '../models/equity_point_model.dart';
import '../models/pair_statistic_model.dart';
import '../models/emotion_statistic_model.dart';

import 'drawdown_service.dart';
import '../models/risk_limit_model.dart';
import 'risk_limit_service.dart';

class AnalyticsEngine {
  // ==========================================================
  // ANALYTICS ENGINE
  //
  // Single Source of Truth:
  // Semua statistik dihitung dari Timeline.
  // ==========================================================

  static AnalyticsResultModel calculate(
    List<AccountTimelineModel> timeline, {
    double maxLossPercent = 2,
    double profitTargetPercent = 3,
  }) {
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

    for (final item in timeline) {
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

      // ======================================================
      // CURRENT BALANCE
      // ======================================================

      currentBalance = item.balance;
    }

    //=============================
    // GROWTH
    //=============================

    double netDeposit = totalDeposit - totalWithdraw;

    double growth = 0.0;

    if (netDeposit > 0) {
      growth = ((currentBalance - netDeposit) / netDeposit) * 100;
    }
    print("Growth : $growth");

    // ========================================================
    // RISK LIMIT
    // ========================================================

    final riskLimit = RiskLimitService.calculate(
      balance: currentBalance,
      maxLossPercent: maxLossPercent,
      profitTargetPercent: profitTargetPercent,
    );

    print("");
    print("========== RISK LIMIT ==========");
    print("Balance               : ${riskLimit.balance}");
    print("Max Loss %            : ${riskLimit.maxLossPercent}");
    print("Max Loss Amount       : ${riskLimit.maxLossAmount}");
    print("Loss Limit Balance    : ${riskLimit.lossLimitBalance}");
    print("Profit Target %       : ${riskLimit.profitTargetPercent}");
    print("Profit Target Amount  : ${riskLimit.profitTargetAmount}");
    print("Profit Target Balance : ${riskLimit.profitTargetBalance}");
    print(
      "================================",
    ); // ========================================================
    // FINAL CALCULATION
    // ========================================================

    final double netProfit = grossProfit - grossLoss;

    final double winRate = totalTrade == 0 ? 0 : (totalWin / totalTrade) * 100;

    final double averageWin = totalWin == 0 ? 0 : grossProfit / totalWin;

    final double averageLoss = totalLoss == 0 ? 0 : grossLoss / totalLoss;

    final double profitFactor = grossLoss == 0 ? 0 : grossProfit / grossLoss;

    // ========================================================
    // DRAWDOWN
    //
    // Gunakan DrawdownService.
    // Jangan hitung drawdown di sini lagi.
    // ========================================================

    final drawdown = DrawdownService.calculate(timeline);

    // ========================================================
    // EQUITY
    // ========================================================

    final equity = calculateEquity(timeline);

    // ========================================================
    // PAIR PERFORMANCE
    // ========================================================

    final pairPerformance = calculatePairPerformance(timeline);

    // ========================================================
    // EMOTION PERFORMANCE
    // ========================================================

    final emotionPerformance = calculateEmotionPerformance(timeline);

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
      growth: growth,

      timeline: timeline,

      equity: equity,

      pairPerformance: pairPerformance,

      emotionPerformance: emotionPerformance,

      drawdown: drawdown,

      riskLimit: riskLimit,
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
      if (item.type != "Trade") {
        continue;
      }

      final pair = item.pair ?? "UNKNOWN";

      if (!pairMap.containsKey(pair)) {
        pairMap[pair] = PairStatisticModel(
          pair: pair,
          totalTrade: 0,
          profit: 0,
          totalWin: 0,
          totalLoss: 0,
        );
      }

      final old = pairMap[pair]!;

      final bool isWin = item.amount >= 0;

      pairMap[pair] = PairStatisticModel(
        pair: old.pair,
        totalTrade: old.totalTrade + 1,
        profit: old.profit + item.amount,
        totalWin: old.totalWin + (isWin ? 1 : 0),
        totalLoss: old.totalLoss + (isWin ? 0 : 1),
      );
    }

    final result = pairMap.values.toList();

    result.sort((a, b) => b.profit.compareTo(a.profit));

    return result;
  }

  // ==========================================================
  // CALCULATE EMOTION PERFORMANCE
  //
  // Hanya trade yang punya tag emosi yang dihitung.
  // ==========================================================

  static List<EmotionStatisticModel> calculateEmotionPerformance(
    List<AccountTimelineModel> timeline,
  ) {
    final Map<String, EmotionStatisticModel> emotionMap = {};

    for (final item in timeline) {
      if (item.type != "Trade") {
        continue;
      }

      final emotion = item.emotion;

      if (emotion == null || emotion.isEmpty) {
        continue;
      }

      if (!emotionMap.containsKey(emotion)) {
        emotionMap[emotion] = EmotionStatisticModel(
          emotion: emotion,
          totalTrade: 0,
          profit: 0,
          totalWin: 0,
          totalLoss: 0,
        );
      }

      final old = emotionMap[emotion]!;

      final bool isWin = item.amount >= 0;

      emotionMap[emotion] = EmotionStatisticModel(
        emotion: old.emotion,
        totalTrade: old.totalTrade + 1,
        profit: old.profit + item.amount,
        totalWin: old.totalWin + (isWin ? 1 : 0),
        totalLoss: old.totalLoss + (isWin ? 0 : 1),
      );
    }

    final result = emotionMap.values.toList();

    result.sort((a, b) => b.profit.compareTo(a.profit));

    return result;
  }
}
