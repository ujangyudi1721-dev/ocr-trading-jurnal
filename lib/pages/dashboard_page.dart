import 'package:flutter/material.dart';

import '../models/analytics_result_model.dart';

import '../services/hive_service.dart';
import '../services/account_timeline_service.dart';
import '../services/analytics_engine.dart';

import '../widgets/dashboard/balance_card.dart';
import '../widgets/dashboard/health_card.dart';
import '../widgets/dashboard/statistic_grid.dart';
import '../widgets/dashboard/pair_performance_card.dart';

import '../shared/loading_widget.dart';

import 'home_page.dart';
import 'history_page.dart';
import 'account_transaction_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  AnalyticsResultModel? analytics;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final trades = await HiveService.getTrades();

    final transactions = await HiveService.getAccountTransactions();

    final timeline = AccountTimelineService.generate(
      transactions: transactions,
      trades: trades,
    );

    analytics = AnalyticsEngine.calculate(timeline);

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (analytics == null) {
      return const LoadingWidget();
    }

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
              ),

              const SizedBox(height: 15),

              HealthCard(growth: 0, drawdown: 0, status: "Coming Soon"),

              const SizedBox(height: 15),

              StatisticGrid(analytics: analytics!),

              const SizedBox(height: 15),

              PairPerformanceCard(analytics: analytics!),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
