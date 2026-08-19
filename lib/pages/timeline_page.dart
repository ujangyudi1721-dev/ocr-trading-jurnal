import 'package:flutter/material.dart';

import '../models/account_timeline_model.dart';
import '../services/account_timeline_service.dart';
import '../services/hive_service.dart';
import '../utils/date_helper.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  List<AccountTimelineModel> timeline = [];

  Color getColor(String type) {
    switch (type) {
      case "Deposit":
        return Colors.green;

      case "Withdraw":
        return Colors.orange;

      case "Trade":
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    loadTimeline();
  }

  Future<void> loadTimeline() async {
    final trades = await HiveService.getTrades();
    final transactions = await HiveService.getAccountTransactions();

    timeline = AccountTimelineService.generate(
      trades: trades,
      transactions: transactions,
    );

    timeline = timeline.reversed.toList();

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Timeline")),
      body: ListView.builder(
        itemCount: timeline.length,
        itemBuilder: (context, index) {
          final item = timeline[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getColor(item.type),
                child: Icon(
                  item.type == "Deposit"
                      ? Icons.account_balance_wallet
                      : item.type == "Withdraw"
                      ? Icons.money_off
                      : Icons.show_chart,
                    color: Colors.white,
                ),
              ),

              title: Text(item.type),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateHelper.formatDateTime(item.date)),

                  if (item.reference != null)
                    Text("Reference : ${item.reference}"),

                  if (item.pair != null) Text("Pair : ${item.pair}"),

                  Text("Balance : ${item.balance.toStringAsFixed(2)}"),
                ],
              ),

              trailing: Text(
                " ${item.amount >= 0 ? "+" : ""}${item.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  color: item.amount >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
