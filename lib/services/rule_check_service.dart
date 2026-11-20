import '../models/account_timeline_model.dart';
import '../models/rule_violation_model.dart';
import '../models/trade_model.dart';

/// The limits used by the rule checker.
class RuleSettings {
  /// Maximum risk (and maximum loss) of one trade, in % of the balance.
  final double maxLossPercent;

  /// Maximum number of trades opened in one day.
  final int maxTradesPerDay;

  /// Money change for 1.0 price move with 1 lot, for each pair.
  /// Only pairs in this map get the "stop loss too wide" check.
  final Map<String, double> contractSizes;

  const RuleSettings({
    required this.maxLossPercent,
    this.maxTradesPerDay = 5,
    this.contractSizes = const {'XAUUSD': 100},
  });
}

/// Checks every trade against your trading rules.
/// It only reads data and returns a list, so it is easy to test.
class RuleCheckService {
  static List<RuleViolation> check({
    required List<TradeModel> trades,
    required List<AccountTimelineModel> timeline, // oldest -> newest
    required RuleSettings settings,
  }) {
    // Ignore trades that were deleted.
    final activeTrades = trades.where((t) => t.deletedAt == null).toList();

    final List<RuleViolation> violations = [];

    for (final trade in activeTrades) {
      violations.addAll(_checkTrade(trade, timeline, settings));
    }

    violations.addAll(_checkOvertrading(activeTrades, settings));

    return violations;
  }

  /// Group violations by trade ticket (useful for the screens later).
  static Map<String, List<RuleViolation>> groupByTicket(
    List<RuleViolation> violations,
  ) {
    final Map<String, List<RuleViolation>> result = {};
    for (final v in violations) {
      result.putIfAbsent(v.ticket, () => []).add(v);
    }
    return result;
  }

  // ==========================================================
  // RULES FOR ONE TRADE
  // ==========================================================

  static List<RuleViolation> _checkTrade(
    TradeModel trade,
    List<AccountTimelineModel> timeline,
    RuleSettings settings,
  ) {
    final List<RuleViolation> result = [];

    final sl = _toNumber(trade.sl);
    final lot = _toNumber(trade.lot);
    final openPrice = _toNumber(trade.openPrice);
    final profit = _toNumber(trade.profit);

    // ---- Rule 1: no stop loss ----
    if (sl == null || sl <= 0) {
      result.add(
        RuleViolation(
          ticket: trade.ticket,
          rule: RuleId.noStopLoss,
          severity: ViolationSeverity.serious,
          title: 'Tanpa stop loss',
          detail: 'Trade ini tidak memakai stop loss.',
        ),
      );
    }

    // The next rules need the balance at the moment the trade was opened.
    final openTime = trade.openDateTime;
    final balance = openTime == null ? null : _balanceAt(openTime, timeline);
    if (balance == null || balance <= 0) return result;

    final maxLossAmount = balance * settings.maxLossPercent / 100;

    // ---- Rule 2: stop loss too wide ----
    final contractSize = settings.contractSizes[_normalizePair(trade.pair)];

    if (sl != null &&
        sl > 0 &&
        openPrice != null &&
        lot != null &&
        contractSize != null) {
      final risk = (openPrice - sl).abs() * lot * contractSize;

      if (risk > maxLossAmount) {
        final riskPercent = risk / balance * 100;
        result.add(
          RuleViolation(
            ticket: trade.ticket,
            rule: RuleId.slTooWide,
            severity: ViolationSeverity.serious,
            title: 'Stop loss terlalu jauh',
            detail:
                'Risiko jika SL kena: ${risk.toStringAsFixed(2)} '
                '(${riskPercent.toStringAsFixed(1)}% dari saldo). '
                'Batas: ${settings.maxLossPercent}% = '
                '${maxLossAmount.toStringAsFixed(2)}.',
          ),
        );
      }
    }

    // ---- Rule 3: the real loss is over the limit ----
    if (profit != null && profit < 0 && profit.abs() > maxLossAmount) {
      final lossPercent = profit.abs() / balance * 100;
      result.add(
        RuleViolation(
          ticket: trade.ticket,
          rule: RuleId.lossOverLimit,
          severity: ViolationSeverity.serious,
          title: 'Rugi melebihi batas',
          detail:
              'Rugi ${profit.abs().toStringAsFixed(2)} '
              '(${lossPercent.toStringAsFixed(1)}% dari saldo). '
              'Batas: ${settings.maxLossPercent}% = '
              '${maxLossAmount.toStringAsFixed(2)}.',
        ),
      );
    }

    return result;
  }

  // ==========================================================
  // RULE FOR ALL TRADES: OVERTRADING
  // ==========================================================

  static List<RuleViolation> _checkOvertrading(
    List<TradeModel> trades,
    RuleSettings settings,
  ) {
    // Group the trades by the day they were opened.
    final Map<DateTime, List<TradeModel>> byDay = {};

    for (final trade in trades) {
      final time = trade.openDateTime;
      if (time == null) continue;

      final day = DateTime(time.year, time.month, time.day);
      byDay.putIfAbsent(day, () => []).add(trade);
    }

    final List<RuleViolation> result = [];

    for (final entry in byDay.entries) {
      final dayTrades = entry.value;
      dayTrades.sort((a, b) => a.openDateTime!.compareTo(b.openDateTime!));

      // Every trade after the limit is a violation.
      for (var i = settings.maxTradesPerDay; i < dayTrades.length; i++) {
        result.add(
          RuleViolation(
            ticket: dayTrades[i].ticket,
            rule: RuleId.overtrading,
            severity: ViolationSeverity.warning,
            title: 'Overtrading',
            detail:
                'Ini trade ke-${i + 1} pada hari itu. '
                'Batas: ${settings.maxTradesPerDay} trade per hari.',
          ),
        );
      }
    }

    return result;
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  /// "3,910.006" -> 3910.006, "+1,233.00" -> 1233.0, "" -> null
  static double? _toNumber(String text) {
    final cleaned = text.replaceAll(',', '').replaceAll('+', '').trim();
    return double.tryParse(cleaned);
  }

  /// "XAU/USD" -> "XAUUSD"
  static String _normalizePair(String pair) {
    return pair.toUpperCase().replaceAll('/', '').replaceAll(' ', '');
  }

  /// The balance at [time]: the balance after the last account event
  /// that happened before or at that time. Returns null if there was none.
  static double? _balanceAt(
    DateTime time,
    List<AccountTimelineModel> timeline,
  ) {
    double? balance;

    for (final event in timeline) {
      if (event.date.isAfter(time)) break; // timeline is old -> new
      balance = event.balance;
    }

    return balance;
  }
}