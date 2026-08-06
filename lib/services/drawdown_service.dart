import '../models/drawdown_model.dart';
import '../models/equity_point_model.dart';

class DrawdownService {
  static DrawdownModel calculate(
    List<EquityPointModel> equity,
  ) {
    if (equity.isEmpty) {
      return DrawdownModel(
        peakBalance: 0,
        currentBalance: 0,
        currentDrawdown: 0,
        maximumDrawdown: 0,
      );
    }

    double peak = equity.first.balance;

    double maxDD = 0;

    for (final point in equity) {
      if (point.balance > peak) {
        peak = point.balance;
      }

      double dd = 0;

      if (peak > 0) {
        dd = ((peak - point.balance) / peak) * 100;
      }

      if (dd > maxDD) {
        maxDD = dd;
      }
    }

    double currentBalance =
        equity.last.balance;

    double currentDD = 0;

    if (peak > 0) {
      currentDD =
          ((peak - currentBalance) / peak) *
              100;
    }

    return DrawdownModel(
      peakBalance: peak,
      currentBalance: currentBalance,
      currentDrawdown: currentDD,
      maximumDrawdown: maxDD,
    );
  }
}