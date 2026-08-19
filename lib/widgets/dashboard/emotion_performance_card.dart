import 'package:flutter/material.dart';

import '../../models/analytics_result_model.dart';
import '../../models/emotion_statistic_model.dart';
import '../../constants/emotion_constants.dart';

class EmotionPerformanceCard extends StatelessWidget {
  final AnalyticsResultModel analytics;

  const EmotionPerformanceCard({
    super.key,
    required this.analytics,
  });

  void _showEmotionDetail(
    BuildContext context,
    EmotionStatisticModel stat,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.emotion,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              _detailRow("Total Trade", "${stat.totalTrade}"),

              _detailRow(
                "Win / Loss",
                "${stat.totalWin} / ${stat.totalLoss}"
                "  (${stat.winRate.toStringAsFixed(0)}%)",
              ),

              _detailRow(
                "Total Profit",
                stat.profit.toStringAsFixed(2),
                color: stat.profit >= 0 ? Colors.green : Colors.red,
              ),

              _detailRow(
                "Rata-rata / Trade",
                stat.averageProfit.toStringAsFixed(2),
                color: stat.averageProfit >= 0 ? Colors.green : Colors.red,
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),

          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<EmotionStatisticModel> stats = analytics.emotionPerformance;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PERFORMA vs EMOSI",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            if (stats.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Belum ada trade yang ditandai emosinya",
                  ),
                ),
              ),

            ...stats.map((stat) {
              final option = EmotionConstants.find(stat.emotion);

              return ListTile(
                contentPadding: EdgeInsets.zero,

                leading: CircleAvatar(
                  backgroundColor: option?.color ?? Colors.grey,
                  child: Icon(
                    option?.icon ?? Icons.mood,
                    size: 18,
                    color: Colors.white,
                  ),
                ),

                title: Text(stat.emotion),

                subtitle: Text(
                  "Trade : ${stat.totalTrade}  |  "
                  "Win Rate : ${stat.winRate.toStringAsFixed(0)}%",
                ),

                trailing: Text(
                  stat.profit.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: stat.profit >= 0 ? Colors.green : Colors.red,
                  ),
                ),

                onTap: () => _showEmotionDetail(context, stat),
              );
            }),
          ],
        ),
      ),
    );
  }
}
