import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/trade_model.dart';
import '../utils/app_logger.dart';
import 'image_cropper_service.dart';
import 'ocr_parser.dart';

/// Menjalankan proses OCR lengkap dari foto screenshot sampai jadi
/// [TradeModel] siap simpan.
///
/// Alurnya: Image -> Crop (buang bagian yang bukan popup detail trade)
/// -> OCR (baca teks dari gambar via ML Kit) -> Parser (ekstrak
/// field-field trade dari teks mentah) -> TradeModel.
class OCRService {
  /// Jalankan seluruh alur OCR untuk satu file gambar.
  static Future<TradeModel> scanTrade(File imageFile) async {
    final croppedFile = await ImageCropperService.cropPopup(imageFile);

    final inputImage = InputImage.fromFile(croppedFile);

    final textRecognizer = TextRecognizer();

    final recognizedText = await textRecognizer.processImage(inputImage);

    AppLogger.log("========== HASIL OCR ==========");
    AppLogger.log(recognizedText.text);
    AppLogger.log("===============================");

    final trade = OCRParser.parse(recognizedText.text);

    textRecognizer.close();

    return trade;
  }
}
