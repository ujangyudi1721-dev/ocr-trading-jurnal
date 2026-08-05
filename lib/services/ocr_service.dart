/*
======================================================

FILE :
ocr_service.dart

TUGAS :
Menjalankan proses OCR lengkap

FLOW :

Image
 ↓
Crop
 ↓
OCR
 ↓
Parser
 ↓
TradeModel

======================================================
*/

import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/trade_model.dart';
import 'image_cropper_service.dart';
import 'ocr_parser.dart';

class OCRService {
  static Future<TradeModel> scanTrade(File imageFile) async {
    final croppedFile = await ImageCropperService.cropPopup(imageFile);

    final inputImage = InputImage.fromFile(croppedFile);

    final textRecognizer = TextRecognizer();

    final recognizedText = await textRecognizer.processImage(inputImage);

    print("========== HASIL OCR ==========");
    print(recognizedText.text);
    print("===============================");

    final trade = OCRParser.parse(recognizedText.text);

    textRecognizer.close();

    return trade;
  }
}
