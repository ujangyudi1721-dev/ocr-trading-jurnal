import 'package:flutter/material.dart';

import '../models/account_transaction_model.dart';
import '../services/hive_service.dart';
import '../utils/date_helper.dart';
import 'account_history_page.dart';

/// Form tambah/edit satu transaksi akun (Deposit/Withdraw).
///
/// Halaman ini dipakai untuk dua mode sekaligus: kalau [transaction]
/// diisi (dibuka dari `AccountHistoryPage` untuk edit), form terisi
/// otomatis dan menyimpan akan meng-update data lama; kalau `null`,
/// ini form tambah baru. Lihat [isEdit].
class AccountTransactionPage extends StatefulWidget {
  /// Transaksi yang sedang diedit, atau `null` kalau ini form tambah baru.
  final AccountTransactionModel? transaction;

  const AccountTransactionPage({super.key, this.transaction});

  @override
  State<AccountTransactionPage> createState() => _AccountTransactionPageState();
}

class _AccountTransactionPageState extends State<AccountTransactionPage> {
  final amountController = TextEditingController();

  String type = "Deposit";

  DateTime selectedDate = DateTime.now();

  /// `true` kalau form ini sedang mengedit transaksi lama
  /// ([widget.transaction] tidak null), `false` kalau tambah baru.
  bool get isEdit => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      amountController.text = widget.transaction!.amount.toString();

      type = widget.transaction!.type;

      selectedDate = widget.transaction!.dateTime ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  /// Validasi nominal lalu simpan — update [widget.transaction] kalau
  /// [isEdit], atau buat [AccountTransactionModel] baru kalau tidak.
  Future<void> saveData() async {
    final amount = double.tryParse(amountController.text) ?? 0;

    if (amount <= 0) return;

    if (isEdit) {
      widget.transaction!
        ..date = DateHelper.formatStorage(selectedDate)
        ..type = type
        ..amount = amount;

      await widget.transaction!.save();
    } else {
      final tx = AccountTransactionModel(
        date: DateHelper.formatStorage(selectedDate),
        type: type,
        amount: amount,
      );

      await HiveService.saveAccountTransaction(tx);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEdit ? "Data berhasil diupdate" : "Data berhasil disimpan",
        ),
      ),
    );

    Navigator.pop(context, true);
  }

  /// Buka [showDatePicker] bawaan Flutter untuk memilih [selectedDate].
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Transaction" : "Deposit / Withdraw"),
      ),
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

            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text("Tanggal"),
                subtitle: Text(DateHelper.formatDisplay(selectedDate)),
                trailing: const Icon(Icons.edit),
                onTap: pickDate,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveData,
              child: Text(isEdit ? "Update" : "Simpan"),
            ),

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
