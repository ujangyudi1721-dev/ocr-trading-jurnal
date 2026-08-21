import 'package:flutter/material.dart';

import '../../models/analytics_result_model.dart';
import '../../shared/stat_card.dart';
import '../../pages/history_page.dart';
import '../../pages/account_transaction_page.dart';

/// Grid 2 kolom berisi ringkasan angka utama di Dashboard (total trade,
/// win rate, gross profit/loss, deposit/withdraw), masing-masing sebagai
/// [StatCard]. Beberapa kartu bisa ditekan untuk lompat ke halaman
/// detailnya (History Trade atau Account Transaction).
class StatisticGrid extends StatelessWidget {
  final AnalyticsResultModel analytics;

  const StatisticGrid({super.key, required this.analytics});

  void _openHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryPage()),
    );
  }

  void _openAccountTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccountTransactionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      crossAxisCount: 2,

      crossAxisSpacing: 10,

      mainAxisSpacing: 10,

      childAspectRatio: 1.25,

      children: [
        StatCard(
          title: "Total Trade",
          value: analytics.totalTrade.toString(),
          icon: Icons.swap_horiz,
          onTap: () => _openHistory(context),
        ),

        StatCard(
          title: "Win Rate",
          value: "${analytics.winRate.toStringAsFixed(2)}%",
          icon: Icons.percent,
        ),

        StatCard(
          title: "Total Win",
          value: analytics.totalWin.toString(),
          icon: Icons.trending_up,
          onTap: () => _openHistory(context),
        ),

        StatCard(
          title: "Total Loss",
          value: analytics.totalLoss.toString(),
          icon: Icons.trending_down,
          onTap: () => _openHistory(context),
        ),

        StatCard(
          title: "Gross Profit",
          value: analytics.grossProfit.toStringAsFixed(2),
          icon: Icons.attach_money,
        ),

        StatCard(
          title: "Gross Loss",
          value: analytics.grossLoss.toStringAsFixed(2),
          icon: Icons.money_off,
        ),

        StatCard(
          title: "Deposit",
          value: analytics.totalDeposit.toStringAsFixed(2),
          icon: Icons.account_balance_wallet,
          onTap: () => _openAccountTransaction(context),
        ),

        StatCard(
          title: "Withdraw",
          value: analytics.totalWithdraw.toStringAsFixed(2),
          icon: Icons.payments,
          onTap: () => _openAccountTransaction(context),
        ),
      ],
    );
  }
}
