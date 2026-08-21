import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/trade_model.dart';
import '../widgets/trade_card.dart';
import '../services/ocr_service.dart';
import '../services/trade_validator.dart';
import '../widgets/action_buttons.dart';
import '../services/hive_service.dart';
import '../constants/emotion_constants.dart';
import 'history_page.dart';
import 'dashboard_page.dart';
import 'account_transaction_page.dart';

/// Halaman utama alur input trade baru: pilih screenshot -> scan OCR
/// -> koreksi/tag emosi -> simpan. Ini juga halaman pertama yang
/// dibuka user (lihat `main.dart`), dengan akses cepat ke Dashboard,
/// History, dan Account Transaction lewat AppBar.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Maksimal gambar yang bisa di-scan sekaligus
  static const int maxImages = 5;

  /// Screenshot yang dipilih user, sebelum di-scan.
  List<File> imageFiles = [];

  /// Hasil scan OCR untuk tiap [imageFiles] (index-nya sejajar).
  List<TradeModel> trades = [];

  /// Tag emosi yang dipilih user untuk tiap [trades] (index-nya
  /// sejajar juga) — `null` berarti belum/tidak ditandai.
  List<String?> emotions = [];

  bool isScanning = false;

  /// Buka gallery, biarkan user pilih sampai [maxImages] screenshot.
  /// Reset hasil scan sebelumnya karena gambarnya berganti.
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final List<XFile> images = await picker.pickMultiImage(limit: maxImages);

    if (images.isEmpty) return;

    setState(() {
      imageFiles = images.map((image) => File(image.path)).toList();
      trades = [];
      emotions = [];
    });
  }

  /// Jalankan OCR ([OCRService]) satu-per-satu untuk setiap [imageFiles].
  Future<void> scanOCR() async {
    if (imageFiles.isEmpty) return;

    setState(() {
      isScanning = true;
      trades = [];
      emotions = [];
    });

    final List<TradeModel> results = [];

    for (final file in imageFiles) {
      final result = await OCRService.scanTrade(file);

      results.add(result);
    }

    if (!mounted) return;

    setState(() {
      trades = results;
      emotions = List<String?>.filled(results.length, null);
      isScanning = false;
    });
  }

  /// Toggle tag emosi untuk trade ke-[index] menjadi [key].
  void selectEmotion(int index, String key) {
    setState(() {
      // Tap lagi pada tag yang sama akan membatalkan pilihan
      emotions[index] = emotions[index] == key ? null : key;
    });
  }

  /// Simpan semua [trades] yang valid ([TradeValidator]) ke database,
  /// sekalian menempelkan [emotions] yang sudah dipilih user. Trade
  /// yang tidak valid (hasil OCR gagal baca ticket/pair) dilewati.
  Future<void> saveTrade() async {
    if (trades.isEmpty) return;

    int saved = 0;
    int skipped = 0;

    for (int i = 0; i < trades.length; i++) {
      final trade = trades[i];

      if (!TradeValidator.isValid(trade)) {
        skipped++;
        continue;
      }

      trade.emotion = emotions[i];

      await HiveService.saveTrade(trade);
      saved++;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          skipped == 0
              ? "$saved trade berhasil disimpan"
              : "$saved trade disimpan, $skipped dilewati (tidak valid)",
        ),
      ),
    );

    setState(() {
      imageFiles = [];
      trades = [];
      emotions = [];
    });
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
              ActionButtons(
                onPickImage: pickImage,
                onScanOCR: scanOCR,
                onSave: saveTrade,
              ),
              const SizedBox(height: 15),

              if (imageFiles.isNotEmpty)
                Text(
                  "${imageFiles.length}/$maxImages gambar dipilih",
                  style: const TextStyle(color: Colors.grey),
                ),

              const SizedBox(height: 10),

              if (imageFiles.isNotEmpty)
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageFiles.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          imageFiles[index],
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              if (isScanning)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),

              if (trades.isNotEmpty) ...[
                for (int i = 0; i < trades.length; i++) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      TradeValidator.isValid(trades[i])
                          ? "Gambar ${i + 1}"
                          : "Gambar ${i + 1} (tidak valid)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: TradeValidator.isValid(trades[i])
                            ? null
                            : Colors.red,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  TradeCard(trade: trades[i]),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Emosi saat entry",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: EmotionConstants.options.map((option) {
                      final bool selected = emotions[i] == option.key;

                      return ChoiceChip(
                        label: Text(option.label),
                        avatar: Icon(
                          option.icon,
                          size: 16,
                          color: selected ? Colors.white : option.color,
                        ),
                        selected: selected,
                        selectedColor: option.color,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : null,
                        ),
                        onSelected: (_) => selectEmotion(i, option.key),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 15),
                ],
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
