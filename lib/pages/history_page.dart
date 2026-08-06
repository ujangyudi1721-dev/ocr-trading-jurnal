import 'package:flutter/material.dart';

import '../models/trade_model.dart';
import '../services/hive_service.dart';
import 'trade_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<TradeModel> trades = [];

  @override
  void initState() {
    super.initState();
    loadTrades();
  }

  Future<void> loadTrades() async {
    trades = await HiveService.getTrades();

    print("=== STATISTIC ===");

    print("Total Trade : ${trades.length}");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History Trade")),
      body: ListView.builder(
        itemCount: trades.length,
        itemBuilder: (context, index) {
          final trade = trades[trades.length - 1 - index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: CircleAvatar(child: Text(trade.pair.substring(0, 1))),

              title: Text("${trade.pair} (${trade.type})"),

              subtitle: Text(trade.ticket),

              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(trade.profit),

                  Text(trade.lot, style: const TextStyle(fontSize: 12)),
                ],
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TradeDetailPage(trade: trade),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
