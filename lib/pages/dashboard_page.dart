import 'package:flutter/material.dart';

import '../models/analytics_result_model.dart';

import '../services/hive_service.dart';
import '../services/account_timeline_service.dart';
import '../services/analytics_engine.dart';

import '../widgets/dashboard/balance_card.dart';
import '../widgets/dashboard/health_card.dart';
import '../widgets/dashboard/statistic_grid.dart';
import '../widgets/dashboard/pair_performance_card.dart';
import '../widgets/dashboard/emotion_performance_card.dart';

import '../shared/loading_widget.dart';

import 'home_page.dart';
import 'history_page.dart';
import 'account_transaction_page.dart';
import '../widgets/dashboard/equity_chart.dart';
import 'timeline_page.dart';
import 'daily_report_page.dart';
import '../widgets/dashboard/risk_limit_card.dart';
import '../widgets/dashboard/risk_limit_edit_dialog.dart';

import '../services/settings_service.dart';
import '../utils/app_logger.dart';

/// Halaman ringkasan performa trading (equity, win rate, drawdown,
/// performa per pair/emosi, risk limit) — kumpulan widget di
/// `widgets/dashboard/` yang semuanya dibangun dari satu
/// [AnalyticsResultModel] hasil [AnalyticsEngine.calculate].
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  AnalyticsResultModel? analytics;

  double maxLossPercent = SettingsService.defaultMaxLossPercent;
  double profitTargetPercent = SettingsService.defaultProfitTargetPercent;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  /// Ambil ulang seluruh data (trade + transaksi akun), hitung ulang
  /// [analytics] lewat [AnalyticsEngine], lalu refresh tampilan.
  /// Dipanggil saat halaman dibuka pertama kali dan saat pull-to-refresh.
  Future<void> loadDashboard() async {
    maxLossPercent = await SettingsService.getMaxLossPercent();
    profitTargetPercent = await SettingsService.getProfitTargetPercent();

    final trades = await HiveService.getTrades();

    final transactions = await HiveService.getAccountTransactions();

    final timeline = AccountTimelineService.generate(
      transactions: transactions,
      trades: trades,
    );

    analytics = AnalyticsEngine.calculate(
      timeline,
      maxLossPercent: maxLossPercent,
      profitTargetPercent: profitTargetPercent,
    );

    final result = analytics!;

    // =========================
    // ANALYTICS
    // =========================

    AppLogger.log("");
    AppLogger.log("========== ANALYTICS ==========");

    AppLogger.log("Trade           : ${result.totalTrade}");
    AppLogger.log("Win             : ${result.totalWin}");
    AppLogger.log("Loss            : ${result.totalLoss}");

    AppLogger.log("Gross Profit    : ${result.grossProfit}");
    AppLogger.log("Gross Loss      : ${result.grossLoss}");
    AppLogger.log("Net Profit      : ${result.netProfit}");

    AppLogger.log("Win Rate        : ${result.winRate}");
    AppLogger.log("Average Win     : ${result.averageWin}");
    AppLogger.log("Average Loss    : ${result.averageLoss}");
    AppLogger.log("Profit Factor   : ${result.profitFactor}");

    AppLogger.log("Deposit         : ${result.totalDeposit}");
    AppLogger.log("Withdraw        : ${result.totalWithdraw}");

    AppLogger.log("Balance         : ${result.currentBalance}");

    AppLogger.log("Peak Balance    : ${result.drawdown.peakBalance}");
    AppLogger.log("Current DD      : ${result.drawdown.currentDrawdown}");
    AppLogger.log("Maximum DD      : ${result.drawdown.maximumDrawdown}");

    AppLogger.log("===============================");

    // =========================
    // EQUITY
    // =========================

    AppLogger.log("");
    AppLogger.log("========== EQUITY ==========");

    for (final point in result.equity) {
      AppLogger.log("${point.index} -> ${point.balance}");
    }

    AppLogger.log("============================");

    // =========================
    // PAIR PERFORMANCE
    // =========================

    AppLogger.log("");
    AppLogger.log("===== PAIR PERFORMANCE =====");

    for (final pair in result.pairPerformance) {
      AppLogger.log(
        "${pair.pair} | "
        "Trade=${pair.totalTrade} | "
        "Profit=${pair.profit}",
      );
    }

    AppLogger.log("============================");
    if (!mounted) return;

    setState(() {});
  }

  /// Buka [RiskLimitEditDialog], simpan hasilnya lewat [SettingsService]
  /// kalau user menekan "Simpan", lalu reload dashboard supaya
  /// [RiskLimitCard] menampilkan angka baru.
  Future<void> editRiskLimit() async {
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (_) => RiskLimitEditDialog(
        maxLossPercent: maxLossPercent,
        profitTargetPercent: profitTargetPercent,
      ),
    );

    if (result == null) return;

    await SettingsService.saveRiskLimit(
      maxLossPercent: result["maxLoss"]!,
      profitTargetPercent: result["profitTarget"]!,
    );

    await loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    if (analytics == null) {
      return const LoadingWidget();
    }
    final drawdownModel = analytics!.drawdown;

    final drawdownPercent = drawdownModel.peakBalance <= 0
        ? 0.0
        : (drawdownModel.currentDrawdown / drawdownModel.peakBalance) * 100.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),

        actions: [
          IconButton(
            icon: const Icon(Icons.scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccountTransactionPage(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.timeline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TimelinePage()),
              );
            },
          ),

          // REPORT HARIAN
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DailyReportPage()),
              );
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadDashboard,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(15),

          child: Column(
            children: [
              BalanceCard(
                balance: analytics!.currentBalance,

                netProfit: analytics!.netProfit,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AccountTransactionPage(),
                    ),
                  );
                },
              ),

              RiskLimitCard(
                riskLimit: analytics!.riskLimit,
                onTap: editRiskLimit,
              ),

              const SizedBox(height: 15),

              HealthCard(
                growth: analytics!.growth,
                drawdown: drawdownPercent,
                status: "Normal",
              ),

              const SizedBox(height: 15),

              StatisticGrid(analytics: analytics!),

              const SizedBox(height: 15),

              EquityChart(analytics: analytics!),

              const SizedBox(height: 15),

              PairPerformanceCard(analytics: analytics!),

              const SizedBox(height: 15),

              EmotionPerformanceCard(analytics: analytics!),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
