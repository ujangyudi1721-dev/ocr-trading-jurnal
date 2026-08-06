import '../models/statistic_model.dart';
import '../models/trade_model.dart';
import '../models/pair_statistic_model.dart';

class StatisticService {
  static StatisticModel calculate(List<TradeModel> trades) {
    int totalTrade = trades.length;

    int totalWin = 0;
    int totalLoss = 0;

    double grossProfit = 0;
    double grossLoss = 0;

    for (final trade in trades) {
      final profit = double.tryParse(trade.profit.replaceAll('+', '')) ?? 0;

      if (profit > 0) {
        totalWin++;

        grossProfit += profit;
      } else if (profit < 0) {
        totalLoss++;

        grossLoss += profit.abs();
      }
    }

    final double winRate = totalTrade == 0 ? 0 : (totalWin / totalTrade) * 100;

    final netProfit = grossProfit - grossLoss;

    return StatisticModel(
      totalTrade: totalTrade,
      totalWin: totalWin,
      totalLoss: totalLoss,
      winRate: winRate,
      grossProfit: grossProfit,
      grossLoss: grossLoss,
      netProfit: netProfit,
    );
  }

  static List<PairStatisticModel> calculatePairPerformance(
    List<TradeModel> trades,
  ) {
    final Map<String, List<TradeModel>> grouped = {};

    for (final trade in trades) {
      grouped.putIfAbsent(trade.pair, () => []);

      grouped[trade.pair]!.add(trade);
    }

    final result = <PairStatisticModel>[];

    grouped.forEach((pair, tradeList) {
      double profit = 0;

      for (final trade in tradeList) {
        profit += double.tryParse(trade.profit) ?? 0;
      }

      result.add(
        PairStatisticModel(
          pair: pair,
          totalTrade: tradeList.length,
          profit: profit,
        ),
      );
    });

    result.sort((a, b) => b.profit.compareTo(a.profit));

    return result;
  }
}
