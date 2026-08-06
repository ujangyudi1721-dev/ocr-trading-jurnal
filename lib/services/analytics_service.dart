import '../models/analytics_result_model.dart';
import '../models/equity_point_model.dart';
import '../models/pair_statistic_model.dart';
import '../models/trade_model.dart';

class AnalyticsService {
  static AnalyticsResultModel calculate(
    List<TradeModel> trades,
  ) {

    int totalTrade = trades.length;

    int totalWin = 0;
    int totalLoss = 0;

    double grossProfit = 0;
    double grossLoss = 0;

    double balance = 0;

    List<EquityPointModel> equity = [];

    Map<String, PairStatisticModel> pairMap = {};

    for (int i = 0; i < trades.length; i++) {

      final trade = trades[i];

      double profit =
          double.tryParse(
                trade.profit.replaceAll("+", ""),
              ) ??
              0;

      // =========================
      // WIN / LOSS
      // =========================

      if (profit >= 0) {
        totalWin++;
        grossProfit += profit;
      } else {
        totalLoss++;
        grossLoss += profit.abs();
      }

      // =========================
      // EQUITY
      // =========================

      balance += profit;

      equity.add(
        EquityPointModel(
          index: i + 1,
          balance: balance,
        ),
      );

      // =========================
      // PAIR PERFORMANCE
      // =========================

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
      equity: equity,
      pairPerformance:
          pairMap.values.toList(),
    );
  }
}