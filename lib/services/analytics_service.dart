import '../models/analytics_result_model.dart';
import '../models/drawdown_model.dart';
import '../models/equity_point_model.dart';
import '../models/pair_statistic_model.dart';
import '../models/trade_model.dart';

class AnalyticsService {

  static AnalyticsResultModel calculate(
    List<TradeModel> trades,
  ) {

    // ==========================================
    // TRADE STATISTIC
    // ==========================================

    int totalTrade = trades.length;

    int totalWin = 0;
    int totalLoss = 0;

    double grossProfit = 0;
    double grossLoss = 0;

    // ==========================================
    // EQUITY
    // ==========================================

    double balance = 0;

    List<EquityPointModel> equity = [];

    // ==========================================
    // DRAWDOWN
    // ==========================================

    double peakBalance = 0;

    double maximumDrawdown = 0;

    // ==========================================
    // PAIR PERFORMANCE
    // ==========================================

    Map<String, PairStatisticModel> pairMap = {};

    // ==========================================
    // MAIN LOOP
    // ==========================================

    for (int i = 0; i < trades.length; i++) {

      final trade = trades[i];

      double profit =
          double.tryParse(
                trade.profit.replaceAll("+", ""),
              ) ??
              0;

      // ==========================================
      // WIN / LOSS
      // ==========================================

      if (profit >= 0) {

        totalWin++;

        grossProfit += profit;

      } else {

        totalLoss++;

        grossLoss += profit.abs();
      }

      // ==========================================
      // EQUITY
      // ==========================================

      balance += profit;

      equity.add(
        EquityPointModel(
          index: i + 1,
          balance: balance,
        ),
      );

      // ==========================================
      // DRAWDOWN
      // ==========================================

      if (balance > peakBalance) {
        peakBalance = balance;
      }

      double drawdown = 0;

      if (peakBalance > 0) {
        drawdown =
            ((peakBalance - balance) /
                    peakBalance) *
                100;
      }

      if (drawdown > maximumDrawdown) {
        maximumDrawdown = drawdown;
      }

      // ==========================================
      // PAIR PERFORMANCE
      // ==========================================

      if (!pairMap.containsKey(trade.pair)) {

        pairMap[trade.pair] =
            PairStatisticModel(
          pair: trade.pair,
          totalTrade: 0,
          profit: 0,
        );
      }

      final old =
          pairMap[trade.pair]!;

      pairMap[trade.pair] =
          PairStatisticModel(
        pair: old.pair,
        totalTrade:
            old.totalTrade + 1,
        profit:
            old.profit + profit,
      );
    }

    // ==========================================
    // CURRENT DRAWDOWN
    // ==========================================

    double currentDrawdown = 0;

    if (peakBalance > 0) {
      currentDrawdown =
          ((peakBalance - balance) /
                  peakBalance) *
              100;
    }

    // ==========================================
    // FINAL STATISTIC
    // ==========================================

    double netProfit =
        grossProfit - grossLoss;

    double winRate = 0;

    if (totalTrade > 0) {
      winRate =
          (totalWin / totalTrade) * 100;
    }

    double averageWin = 0;

    if (totalWin > 0) {
      averageWin =
          grossProfit / totalWin;
    }

    double averageLoss = 0;

    if (totalLoss > 0) {
      averageLoss =
          grossLoss / totalLoss;
    }

    double profitFactor = 0;

    if (grossLoss > 0) {
      profitFactor =
          grossProfit / grossLoss;
    }

    // ==========================================
    // RETURN RESULT
    // ==========================================

    return AnalyticsResultModel(

      // Trade Statistic
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

      // Equity
      equity: equity,

      // Drawdown
      drawdown: DrawdownModel(
        peakBalance: peakBalance,
        currentBalance: balance,
        currentDrawdown: currentDrawdown,
        maximumDrawdown: maximumDrawdown,
      ),

      // Pair Performance
      pairPerformance:
          pairMap.values.toList(),
    );
  }
}