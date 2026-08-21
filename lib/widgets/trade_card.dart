import 'package:flutter/material.dart';
import '../models/trade_model.dart';
import '../constants/emotion_constants.dart';

/// Kartu detail satu trade (dipakai di `HomePage` saat preview hasil
/// scan OCR sebelum disimpan) — menampilkan seluruh field trade plus
/// chip tag emosi kalau sudah dipilih.
class TradeCard extends StatelessWidget {
  final TradeModel trade;

  const TradeCard({super.key, required this.trade});

  @override
  Widget build(BuildContext context) {
    final emotion = EmotionConstants.find(trade.emotion);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ticket : ${trade.ticket}"),
            Text("Pair : ${trade.pair}"),
            Text("Type : ${trade.type}"),
            Text("Lot : ${trade.lot}"),
            Text("Profit : ${trade.profit}"),

            if (emotion != null) ...[
              const SizedBox(height: 6),

              Chip(
                avatar: Icon(emotion.icon, size: 16, color: Colors.white),
                label: Text(
                  emotion.label,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: emotion.color,
                visualDensity: VisualDensity.compact,
              ),
            ],

            const Divider(),

            Text("Open Time : ${trade.openTime}"),
            Text("Close Time : ${trade.closeTime}"),

            const Divider(),

            Text("SL : ${trade.sl}"),
            Text("TP : ${trade.tp}"),

            const Divider(),

            Text("Open Price : ${trade.openPrice}"),
            Text("Close Price : ${trade.closePrice}"),
          ],
        ),
      ),
    );
  }
}
