import 'dart:io';

import 'package:image/image.dart' as img;

/// Memotong screenshot supaya OCR ([OCRService]) hanya membaca bagian
/// popup detail trade, bukan seluruh layar (chart, toolbar, dll yang
/// bisa membingungkan text recognizer).
class ImageCropperService {
  /// Potong bagian atas gambar (chart/header) dan sisakan 55% bagian
  /// bawah, tempat popup detail trade biasanya muncul di MetaTrader.
  static Future<File> cropPopup(File originalFile) async {
    final bytes = await originalFile.readAsBytes();

    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("Gagal membaca gambar");
    }

    final width = image.width;
    final height = image.height;

    // Buang 45% bagian atas gambar (bukan bagian popup trade).
    final cropY = (height * 0.45).toInt();

    final cropped = img.copyCrop(
      image,
      x: 0,
      y: cropY,
      width: width,
      height: height - cropY,
    );

    final tempPath = "${originalFile.parent.path}/cropped_popup.png";

    final croppedFile = File(tempPath);

    await croppedFile.writeAsBytes(img.encodePng(cropped));

    return croppedFile;
  }
}
