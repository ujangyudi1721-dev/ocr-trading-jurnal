import 'package:flutter/material.dart';

import '../models/account_timeline_model.dart';
import '../services/account_timeline_service.dart';
import '../services/hive_service.dart';

class DebugTimelinePage extends StatefulWidget {
  const DebugTimelinePage({super.key});

  @override
  State<DebugTimelinePage> createState() =>
      _DebugTimelinePageState();
}

class _DebugTimelinePageState
    extends State<DebugTimelinePage> {
  List<AccountTimelineModel> timeline = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadTimeline();
  }

  Future<void> loadTimeline() async {
    final transactions =
        await HiveService.getAccountTransactions();

    final trades =
        await HiveService.getTrades();

    timeline =
        AccountTimelineService.generate(
          transactions: transactions,
          trades: trades,
        );

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Timeline Debug"),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: timeline.length,
              itemBuilder: (context, index) {
                final item = timeline[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  child: Padding(
                    padding:
                        const EdgeInsets.all(12),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        Text(
                          item.type,
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          "Amount : ${item.amount.toStringAsFixed(2)}",
                        ),

                        Text(
                          "Balance : ${item.balance.toStringAsFixed(2)}",
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          item.date.toString(),
                          style:
                              const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}