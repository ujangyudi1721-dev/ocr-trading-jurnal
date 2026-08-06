import 'package:flutter/material.dart';

import '../models/statistic_model.dart';
import '../models/pair_statistic_model.dart';

import '../services/hive_service.dart';
import '../services/statistic_service.dart';
import '../models/account_summary_model.dart';
import '../services/account_statistic_service.dart';
import '../models/account_health_model.dart';
import '../services/account_health_service.dart';
import 'history_page.dart';
import 'account_transaction_page.dart';
import 'home_page.dart';
import '../services/account_timeline_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  StatisticModel? stats;

  AccountHealthModel? health;

  AccountSummaryModel? accountSummary;

  List<PairStatisticModel> pairStats = [];

  @override
  void initState() {
    super.initState();
    loadStatistic();
  }

  Future<void> loadStatistic() async {
    final trades = await HiveService.getTrades();

    final transactions = await HiveService.getAccountTransactions();

    // ==========================================
    // TIMELINE DEBUG
    // ==========================================

    final timeline = AccountTimelineService.generate(
      transactions: transactions,
      trades: trades,
    );

    print("");
    print("========== TIMELINE ==========");

    for (final item in timeline) {
      print(
        "${item.date} | "
        "${item.type} | "
        "${item.amount} | "
        "Balance=${item.balance.toStringAsFixed(2)} | "
        "${item.reference}",
      );
    }

    print("==============================");
    print("");

    // ==========================================
    // DASHBOARD
    // ==========================================

    stats = StatisticService.calculate(trades);

    pairStats = StatisticService.calculatePairPerformance(trades);

    accountSummary = AccountStatisticService.calculate(transactions, trades);

    health = AccountHealthService.calculate(accountSummary!);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (stats == null || accountSummary == null || health == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          // DASHBOARD
          IconButton(
            icon: const Icon(Icons.scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          ),

          // HISTORY
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),

          // deposit page
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // ==========================
            // NET PROFIT
            // ==========================
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "BALANCE",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      accountSummary!.balance.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text("Net Profit : ${stats!.netProfit.toStringAsFixed(2)}"),
                  ],
                ),
              ),
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    const Text(
                      "ACCOUNT HEALTH",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text("Growth : ${health!.growth.toStringAsFixed(2)}%"),

                    Text("Drawdown : ${health!.drawdown.toStringAsFixed(2)}%"),

                    const SizedBox(height: 10),

                    Text(
                      health!.status,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==========================
            // STATISTIC GRID
            // ==========================
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                statCard("Total Trade", stats!.totalTrade.toString()),

                statCard("Win Rate", "${stats!.winRate.toStringAsFixed(2)}%"),

                statCard("Total Win", stats!.totalWin.toString()),

                statCard("Total Loss", stats!.totalLoss.toString()),

                statCard("Gross Profit", stats!.grossProfit.toStringAsFixed(2)),

                statCard("Gross Loss", stats!.grossLoss.toStringAsFixed(2)),

                statCard(
                  "Deposit",
                  accountSummary!.totalDeposit.toStringAsFixed(2),
                ),

                statCard(
                  "Withdraw",
                  accountSummary!.totalWithdraw.toStringAsFixed(2),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==========================
            // PAIR PERFORMANCE
            // ==========================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pair Performance",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (pairStats.isEmpty) const Text("Belum ada data"),

                    ...pairStats.map(
                      (pair) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(pair.pair),
                        subtitle: Text("Trade : ${pair.totalTrade}"),
                        trailing: Text(pair.profit.toStringAsFixed(2)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statCard(String title, String value) {
    return Card(
      elevation: 3,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, textAlign: TextAlign.center),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
