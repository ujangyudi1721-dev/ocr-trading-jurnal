import 'dart:io';

import 'package:image/image.dart' as img;

class ImageCropperService {
  static Future<File> cropPopup(File originalFile) async {
    final bytes = await originalFile.readAsBytes();

    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("Gagal membaca gambar");
    }

    final width = image.width;
    final height = image.height;

    final cropY = (height * 0.45).toInt();

    final cropped = img.copyCrop(
      image,
      x: 0,
      y: cropY,
      width: width,
      height: height - cropY,
    );

    final tempPath =
        "${originalFile.parent.path}/cropped_popup.png";

    final croppedFile = File(tempPath);

    await croppedFile.writeAsBytes(
      img.encodePng(cropped),
    );

    return croppedFile;
  }
}