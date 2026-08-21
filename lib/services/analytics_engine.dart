import '../models/account_timeline_model.dart';
import '../models/analytics_result_model.dart';
import '../models/equity_point_model.dart';
import '../models/pair_statistic_model.dart';
import '../models/emotion_statistic_model.dart';

import 'drawdown_service.dart';
import '../utils/app_logger.dart';
import 'risk_limit_service.dart';

/// Otak dari halaman Dashboard: mengubah [AccountTimelineModel] mentah
/// jadi satu [AnalyticsResultModel] siap pakai (statistik trade, growth,
/// drawdown, equity curve, performa per pair, performa per emosi, dan
/// risk limit).
///
/// Prinsip "Single Source of Truth": semua angka di Dashboard diturunkan
/// dari [AccountTimelineModel] yang sama lewat [calculate] — tidak ada
/// perhitungan statistik lain yang dilakukan di halaman/widget langsung.
class AnalyticsEngine {
  /// Hitung seluruh statistik dashboard dari [timeline].
  ///
  /// [maxLossPercent] dan [profitTargetPercent] dipakai untuk menghitung
  /// [RiskLimitModel] — datang dari preferensi user di [SettingsService],
  /// bukan dihitung di sini.
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
    AppLogger.log("Growth : $growth");

    // ========================================================
    // RISK LIMIT
    // ========================================================

    final riskLimit = RiskLimitService.calculate(
      balance: currentBalance,
      maxLossPercent: maxLossPercent,
      profitTargetPercent: profitTargetPercent,
    );

    AppLogger.log("");
    AppLogger.log("========== RISK LIMIT ==========");
    AppLogger.log("Balance               : ${riskLimit.balance}");
    AppLogger.log("Max Loss %            : ${riskLimit.maxLossPercent}");
    AppLogger.log("Max Loss Amount       : ${riskLimit.maxLossAmount}");
    AppLogger.log("Loss Limit Balance    : ${riskLimit.lossLimitBalance}");
    AppLogger.log("Profit Target %       : ${riskLimit.profitTargetPercent}");
    AppLogger.log("Profit Target Amount  : ${riskLimit.profitTargetAmount}");
    AppLogger.log("Profit Target Balance : ${riskLimit.profitTargetBalance}");
    AppLogger.log("================================");

    // ========================================================
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

  /// Ubah [timeline] jadi titik-titik untuk grafik equity/balance.
  /// [EquityPointModel.index] adalah urutan kejadian (1, 2, 3, ...),
  /// bukan tanggal, supaya jarak antar titik di grafik selalu rata.
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

  /// Kelompokkan trade di [timeline] berdasarkan pair, lalu urutkan
  /// dari yang paling profit ke yang paling rugi.
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

  /// Kelompokkan trade di [timeline] berdasarkan tag emosi, lalu
  /// urutkan dari yang paling profit ke yang paling rugi. Trade tanpa
  /// tag emosi dilewati (tidak ikut dihitung sama sekali).
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
