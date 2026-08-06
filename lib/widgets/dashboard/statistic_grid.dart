import 'package:flutter/material.dart';

import '../../models/analytics_result_model.dart';
import '../../shared/stat_card.dart';

class StatisticGrid extends StatelessWidget {
  final AnalyticsResultModel analytics;

  const StatisticGrid({super.key, required this.analytics});

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
        ),

        StatCard(
          title: "Total Loss",
          value: analytics.totalLoss.toString(),
          icon: Icons.trending_down,
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
        ),

        StatCard(
          title: "Withdraw",
          value: analytics.totalWithdraw.toStringAsFixed(2),
          icon: Icons.payments,
        ),
      ],
    );
  }
}
