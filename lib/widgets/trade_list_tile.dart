import 'package:flutter/material.dart';

import '../models/trade_model.dart';

/// Satu baris trade di daftar (dipakai di `HistoryPage` dan
/// `DailyTradesPage`), diwarnai supaya gampang dipindai sekilas:
/// avatar hijau/merah untuk BUY/SELL, dan angka profit hijau/merah
/// sesuai untung/rugi.
class TradeListTile extends StatelessWidget {
  final TradeModel trade;
  final VoidCallback? onTap;

  const TradeListTile({super.key, required this.trade, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isBuy = trade.type.toUpperCase() == "BUY";
    final Color typeColor = isBuy ? Colors.green : Colors.red;

    final double profitValue =
        double.tryParse(trade.profit.replaceAll("+", "")) ?? 0;
    final bool isProfit = profitValue >= 0;
    final Color profitColor = isProfit ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor,
          child: Icon(
            isBuy ? Icons.arrow_upward : Icons.arrow_downward,
            color: Colors.white,
            size: 18,
          ),
        ),

        title: Row(
          children: [
            Text(
              trade.pair,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(width: 6),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                trade.type,
                style: TextStyle(
                  color: typeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),

        subtitle: Text(trade.ticket),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              trade.profit,
              style: TextStyle(color: profitColor, fontWeight: FontWeight.bold),
            ),

            Text(
              trade.lot,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),

        onTap: onTap,
      ),
    );
  }
}
