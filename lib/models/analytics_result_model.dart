import 'equity_point_model.dart';
import 'pair_statistic_model.dart';
import 'emotion_statistic_model.dart';
import 'drawdown_model.dart';
import 'account_timeline_model.dart';
import 'risk_limit_model.dart';

/// Hasil akhir seluruh perhitungan analytics untuk halaman Dashboard,
/// dibuat sekali oleh `AnalyticsEngine.generate()` dari data mentah
/// (trades + account transactions), lalu dipakai apa adanya oleh
/// widget-widget di `lib/widgets/dashboard/`.
///
/// Ini murni "kotak data" (tidak ada logic hitung di sini) — semua
/// perhitungan ada di `AnalyticsEngine` dan service-service pendukungnya
/// (`DrawdownService`, dst).
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

  final double growth;
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

  // =================================
  // EMOTION PERFORMANCE
  // =================================

  final List<EmotionStatisticModel> emotionPerformance;

  // ==================================
  // DRAWDOWN
  // ==================================

  final DrawdownModel drawdown;

  // ==================================
  // RISK LIMIT
  // ==================================

  final RiskLimitModel riskLimit;

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
    required this.growth,

    // TIMELINE
    required this.timeline,

    // EQUITY
    required this.equity,

    // PAIR
    required this.pairPerformance,

    // EMOTION
    required this.emotionPerformance,

    // DRAWDOWN
    required this.drawdown,

    // RISK LIMIT
    required this.riskLimit,
  });
}
