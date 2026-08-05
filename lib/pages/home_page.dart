/*
======================================================

FILE :
home_page.dart

TUGAS :
Halaman utama aplikasi OCR Trading

FITUR :
- Pilih Screenshot
- Crop Otomatis
- OCR MLKit
- Parsing Data Trading
- Menampilkan Hasil Parsing

FLOW :

Pilih Screenshot
        ↓
Crop Popup
        ↓
OCR
        ↓
Parser
        ↓
TradeModel
        ↓
Tampil di Card

======================================================
*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/trade_model.dart';
import '../widgets/trade_card.dart';
import '../services/ocr_service.dart';
import '../widgets/action_buttons.dart';

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

    setState(() {
      trade = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trading OCR")),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ActionButtons(onPickImage: pickImage, onScanOCR: scanOCR),
              const SizedBox(height: 20),

              if (imageFile != null) Image.file(imageFile!, height: 300),

              const SizedBox(height: 20),

              if (trade != null) TradeCard(trade: trade!),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
