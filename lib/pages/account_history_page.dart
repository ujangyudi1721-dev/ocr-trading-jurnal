import 'package:flutter/material.dart';

import '../models/account_transaction_model.dart';
import '../services/hive_service.dart';
import 'account_transaction_page.dart';

/// Daftar transaksi akun manual (Deposit/Withdraw), terbaru di atas.
/// Tap satu item untuk edit (buka `AccountTransactionPage` mode edit),
/// atau tombol sampah untuk hapus (dengan dialog konfirmasi).
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

  /// Minta konfirmasi lewat dialog, lalu hapus [item] kalau user setuju.
  Future<void> deleteItem(AccountTransactionModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Data"),
        content: const Text("Yakin ingin menghapus transaksi ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await HiveService.deleteAccountTransaction(item);

    await loadData();
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
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AccountTransactionPage(transaction: item),
                ),
              );

              if (result == true) {
                loadData();
              }
            },

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.amount.toString()),

                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    deleteItem(item);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
