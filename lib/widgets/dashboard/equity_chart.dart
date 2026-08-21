import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/analytics_result_model.dart';

/// Grafik garis (equity curve) yang menunjukkan naik-turunnya saldo
/// dari waktu ke waktu, dibangun dari [AnalyticsResultModel.equity]
/// memakai package `fl_chart`.
class EquityChart extends StatelessWidget {
  final AnalyticsResultModel analytics;

  const EquityChart({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    // Ubah setiap EquityPointModel jadi titik (x, y) untuk fl_chart:
    // x = urutan kejadian, y = saldo pada titik itu.
    final spots = analytics.equity
        .map((e) => FlSpot(e.index.toDouble(), e.balance))
        .toList();

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Equity Curve",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: LineChart(
                  LineChartData(
                    borderData: FlBorderData(
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade400),
                        bottom: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),

                    gridData: FlGridData(show: true),

                    titlesData: FlTitlesData(show: true),

                    lineTouchData: LineTouchData(
                      enabled: true,

                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              spot.y.toStringAsFixed(2),
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),

                      getTouchedSpotIndicator: (barData, spotIndexes) {
                        return spotIndexes.map((index) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: Colors.green,
                              strokeWidth: 2,
                              dashArray: [4, 4],
                            ),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                    radius: 5,
                                    color: Colors.green,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  ),
                            ),
                          );
                        }).toList();
                      },
                    ),

                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,

                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: Colors.green,

                        dotData: const FlDotData(show: false),

                        barWidth: 4,

                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.green.withValues(alpha: 0.35),
                              Colors.green.withValues(alpha: 0.02),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
