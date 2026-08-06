import 'package:flutter/material.dart';

import '../../models/analytics_result_model.dart';
import '../../models/pair_statistic_model.dart';

class PairPerformanceCard extends StatelessWidget {
  final AnalyticsResultModel analytics;

  const PairPerformanceCard({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final List<PairStatisticModel> pairs =
        analytics.pairPerformance;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "PAIR PERFORMANCE",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            if (pairs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Belum ada data"),
                ),
              ),

            ...pairs.map(
              (pair) => ListTile(
                contentPadding:
                    EdgeInsets.zero,

                leading: CircleAvatar(
                  child: Text(
                    pair.pair.substring(
                      0,
                      pair.pair.length > 2
                          ? 2
                          : 1,
                    ),
                  ),
                ),

                title: Text(pair.pair),

                subtitle: Text(
                  "Trade : ${pair.totalTrade}",
                ),

                trailing: Text(
                  pair.profit.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        pair.profit >= 0
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}