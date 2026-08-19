import 'package:flutter/material.dart';

import '../models/trade_model.dart';
import '../constants/emotion_constants.dart';

class TradeDetailPage extends StatelessWidget {
  final TradeModel trade;

  const TradeDetailPage({
    super.key,
    required this.trade,
  });

  Widget buildItem(
    String title,
    String value,
  ) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emotion = EmotionConstants.find(trade.emotion);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Trade"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildItem("Ticket", trade.ticket),
            buildItem("Pair", trade.pair),
            buildItem("Type", trade.type),
            buildItem("Lot", trade.lot),
            buildItem("Profit", trade.profit),

            if (emotion != null)
              Card(
                child: ListTile(
                  leading: Icon(emotion.icon, color: emotion.color),
                  title: const Text("Emosi saat entry"),
                  subtitle: Text(emotion.label),
                ),
              ),

            buildItem("Open Time", trade.openTime),
            buildItem("Close Time", trade.closeTime),

            buildItem("SL", trade.sl),
            buildItem("TP", trade.tp),

            buildItem("Open Price", trade.openPrice),
            buildItem("Close Price", trade.closePrice),
          ],
        ),
      ),
    );
  }
}