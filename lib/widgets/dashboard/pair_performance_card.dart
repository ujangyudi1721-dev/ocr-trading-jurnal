import 'package:flutter/material.dart';

import '../../models/analytics_result_model.dart';
import '../../models/pair_statistic_model.dart';

/// Kartu Dashboard yang menampilkan daftar [PairStatisticModel] —
/// performa trading dikelompokkan per pair — mirror dari
/// [EmotionPerformanceCard] tapi grouping-nya per pair, bukan emosi.
/// Tap satu baris untuk buka detail lengkapnya lewat [_showPairDetail].
class PairPerformanceCard extends StatelessWidget {
  final AnalyticsResultModel analytics;

  const PairPerformanceCard({super.key, required this.analytics});

  /// Tampilkan detail satu pair dalam bottom sheet.
  void _showPairDetail(BuildContext context, PairStatisticModel pair) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pair.pair,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              _detailRow("Total Trade", "${pair.totalTrade}"),

              _detailRow(
                "Win / Loss",
                "${pair.totalWin} / ${pair.totalLoss}"
                    "  (${pair.winRate.toStringAsFixed(0)}%)",
              ),

              _detailRow(
                "Total Profit",
                pair.profit.toStringAsFixed(2),
                color: pair.profit >= 0 ? Colors.green : Colors.red,
              ),

              _detailRow(
                "Rata-rata / Trade",
                pair.averageProfit.toStringAsFixed(2),
                color: pair.averageProfit >= 0 ? Colors.green : Colors.red,
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  /// Satu baris "label - value" di dalam bottom sheet detail.
  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),

          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<PairStatisticModel> pairs = analytics.pairPerformance;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PAIR PERFORMANCE",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                contentPadding: EdgeInsets.zero,

                leading: CircleAvatar(
                  child: Text(
                    pair.pair.substring(0, pair.pair.length > 2 ? 2 : 1),
                  ),
                ),

                title: Text(pair.pair),

                subtitle: Text("Trade : ${pair.totalTrade}"),

                trailing: Text(
                  pair.profit.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: pair.profit >= 0 ? Colors.green : Colors.red,
                  ),
                ),

                onTap: () => _showPairDetail(context, pair),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
