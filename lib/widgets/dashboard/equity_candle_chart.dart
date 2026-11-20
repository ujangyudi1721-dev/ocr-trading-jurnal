import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/account_timeline_model.dart';

/// One candle = one day of the account balance.
class _DayCandle {
  final DateTime day;
  final double open;
  final double high;
  final double low;
  final double close;

  const _DayCandle({
    required this.day,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}

/// Candlestick chart of the daily account balance (equity).
class EquityCandleChart extends StatelessWidget {
  /// Account events from the oldest to the newest, with running balance.
  final List<AccountTimelineModel> timeline;

  const EquityCandleChart({super.key, required this.timeline});

  /// Group the timeline by day and make one candle for each day.
  List<_DayCandle> _buildCandles() {
    // day -> the balance after each event of that day
    final Map<DateTime, List<double>> byDay = {};

    for (final event in timeline) {
      final day = DateTime(event.date.year, event.date.month, event.date.day);
      byDay.putIfAbsent(day, () => []).add(event.balance);
    }

    final days = byDay.keys.toList()..sort();
    final List<_DayCandle> candles = [];
    double? previousClose;

    for (final day in days) {
      final balances = byDay[day]!;

      // Open = yesterday's close (or the first balance on the first day).
      final open = previousClose ?? balances.first;
      final close = balances.last;
      final high = balances.fold<double>(open, (m, b) => max(m, b));
      final low = balances.fold<double>(open, (m, b) => min(m, b));

      candles.add(
        _DayCandle(day: day, open: open, high: high, low: low, close: close),
      );
      previousClose = close;
    }

    return candles;
  }

  /// 1500 -> "1.5k", 2500000 -> "2.5M"
  String _shortNumber(double v) {
    if (v.abs() >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  Widget _buildChart(List<_DayCandle> candles) {
    final count = candles.length;

    // Show about 5 date labels, not one for every candle.
    final labelInterval = max(1, (count / 5).ceil()).toDouble();

    // Thin candles when there are many days.
    final bodyWidth = count > 30 ? 4.0 : 10.0;

    // Leave some empty space above and below the candles.
    final lowest = candles.map((c) => c.low).reduce(min);
    final highest = candles.map((c) => c.high).reduce(max);
    final padding = max((highest - lowest) * 0.1, 1.0);

    return CandlestickChart(
      CandlestickChartData(
        candlestickSpots: candles.asMap().entries.map((entry) {
          final c = entry.value;
          return CandlestickSpot(
            x: entry.key.toDouble(), // 0, 1, 2, ... (no gaps for weekends)
            open: c.open,
            high: c.high,
            low: c.low,
            close: c.close,
          );
        }).toList(),
        minX: -0.5,
        maxX: count - 0.5,
        minY: lowest - padding,
        maxY: highest + padding,
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(
          border: Border(
            left: BorderSide(color: Colors.grey.shade400),
            bottom: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        candlestickPainter: DefaultCandlestickPainter(
          candlestickStyleProvider: (spot, index) {
            final color = spot.isUp ? Colors.green : Colors.red;
            return CandlestickStyle(
              lineColor: color,
              lineWidth: 1.5,
              bodyStrokeColor: color,
              bodyStrokeWidth: 0,
              bodyFillColor: color,
              bodyWidth: bodyWidth,
              bodyRadius: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              minIncluded: false,
              maxIncluded: false,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  _shortNumber(value),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: labelInterval,
              minIncluded: false,
              maxIncluded: false,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= count) return const SizedBox.shrink();

                final d = candles[i].day;
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '${d.day}/${d.month}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        candlestickTouchData: CandlestickTouchData(
          touchTooltipData: CandlestickTouchTooltipData(
            getTooltipItems: (painter, spot, index) {
              final c = candles[index];
              return CandlestickTooltipItem(
                '${c.day.day}/${c.day.month}/${c.day.year}\n'
                'Open  ${c.open.toStringAsFixed(2)}\n'
                'High  ${c.high.toStringAsFixed(2)}\n'
                'Low   ${c.low.toStringAsFixed(2)}\n'
                'Close ${c.close.toStringAsFixed(2)}',
                textStyle: const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final candles = _buildCandles();

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Equity Candle (harian)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: candles.isEmpty
                    ? const Center(child: Text("Belum ada data."))
                    : _buildChart(candles),
              ),
            ],
          ),
        ),
      ),
    );
  }
}