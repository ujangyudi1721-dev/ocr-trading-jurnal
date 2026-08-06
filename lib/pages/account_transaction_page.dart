import 'package:flutter/material.dart';

import '../models/account_transaction_model.dart';
import '../services/hive_service.dart';
import 'account_history_page.dart';

class AccountTransactionPage extends StatefulWidget {
  const AccountTransactionPage({super.key});

  @override
  State<AccountTransactionPage> createState() => _AccountTransactionPageState();
}

class _AccountTransactionPageState extends State<AccountTransactionPage> {
  final amountController = TextEditingController();

  String type = "Deposit";

  Future<void> saveData() async {
    final amount = double.tryParse(amountController.text) ?? 0;

    if (amount <= 0) return;

    final tx = AccountTransactionModel(
      date: DateTime.now().toString(),
      type: type,
      amount: amount,
    );

    await HiveService.saveAccountTransaction(tx);

    final data = await HiveService.getAccountTransactions();

    print("===== ACCOUNT DATA =====");

    for (final item in data) {
      print("${item.type} | ${item.amount} | ${item.date}");
    }

    print("========================");

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Data berhasil disimpan")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deposit / Withdraw")),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Nominal"),
            ),

            const SizedBox(height: 20),

            DropdownButton<String>(
              value: type,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "Deposit", child: Text("Deposit")),
                DropdownMenuItem(value: "Withdraw", child: Text("Withdraw")),
              ],
              onChanged: (value) {
                setState(() {
                  type = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: saveData, child: const Text("Simpan")),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountHistoryPage()),
                );
              },
              child: const Text("Lihat History"),
            ),
          ],
        ),
      ),
    );
  }
}
