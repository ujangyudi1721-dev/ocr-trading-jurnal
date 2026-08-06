import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/trade_model.dart';
import '../widgets/trade_card.dart';
import '../services/ocr_service.dart';
import '../widgets/action_buttons.dart';
import '../services/hive_service.dart';
import 'history_page.dart';
import 'dashboard_page.dart';
import 'account_transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? imageFile;
  String resultText = "";
  TradeModel? trade;

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      imageFile = File(image.path);
    });
  }

  Future<void> scanOCR() async {
    if (imageFile == null) return;

    final result = await OCRService.scanTrade(imageFile!);

    // ============================
    // TEST Date Helper
    // ============================

    print("===== DATE TEST =====");

    print(result.openDateTime);

    print(result.closeDateTime);

    print("=====================");

    setState(() {
      trade = result;
    });
  }

  Future<void> saveTrade() async {
    if (trade == null) return;

    await HiveService.saveTrade(trade!);

    // DEBUG
    final trades = await HiveService.getTrades();
    print("TOTAL TRADE = ${trades.length}");

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Trade berhasil disimpan")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trading OCR"),

        actions: [
          // DASHBOARD
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            },
          ),

          // HISTORY
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),

          // deposit page
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccountTransactionPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ActionButtons(onPickImage: pickImage, onScanOCR: scanOCR),
              const SizedBox(height: 20),

              if (imageFile != null) Image.file(imageFile!, height: 300),

              const SizedBox(height: 20),

              if (trade != null) ...[
                TradeCard(trade: trade!),

                const SizedBox(height: 15),

                ElevatedButton.icon(
                  onPressed: saveTrade,
                  icon: const Icon(Icons.save),
                  label: const Text("Simpan Trade"),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
