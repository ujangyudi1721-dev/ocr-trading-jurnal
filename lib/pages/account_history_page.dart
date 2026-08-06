import 'package:flutter/material.dart';

import '../models/account_transaction_model.dart';
import '../services/hive_service.dart';

class AccountHistoryPage extends StatefulWidget {
  const AccountHistoryPage({super.key});

  @override
  State<AccountHistoryPage> createState() => _AccountHistoryPageState();
}

class _AccountHistoryPageState extends State<AccountHistoryPage> {
  List<AccountTransactionModel> data = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    data = await HiveService.getAccountTransactions();

    data = data.reversed.toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History Deposit/Withdraw")),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];

          return ListTile(
            leading: Icon(
              item.type == "Deposit"
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
            ),
            title: Text(item.type),
            subtitle: Text(item.date),
            trailing: Text(item.amount.toString()),
          );
        },
      ),
    );
  }
}
