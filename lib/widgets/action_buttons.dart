import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onScanOCR;

  const ActionButtons({
    super.key,
    required this.onPickImage,
    required this.onScanOCR,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPickImage,
          child: const Text(
            "Pilih Screenshot",
          ),
        ),

        const SizedBox(height: 10),

        ElevatedButton(
          onPressed: onScanOCR,
          child: const Text(
            "Scan OCR",
          ),
        ),
      ],
    );
  }
}