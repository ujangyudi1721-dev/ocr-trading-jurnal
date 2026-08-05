import 'package:flutter/material.dart';
import '../models/trade_model.dart';

class TradeCard extends StatelessWidget {
  final TradeModel trade;

  const TradeCard({
    super.key,
    required this.trade,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text("Ticket : ${trade.ticket}"),
            Text("Pair : ${trade.pair}"),
            Text("Type : ${trade.type}"),
            Text("Lot : ${trade.lot}"),
            Text("Profit : ${trade.profit}"),

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