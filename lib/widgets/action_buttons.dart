import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onScanOCR;
  final VoidCallback onSave;

  const ActionButtons({
    super.key,
    required this.onPickImage,
    required this.onScanOCR,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onPickImage,
            icon: const Icon(Icons.photo),
            label: const Text("Screenshot"),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: ElevatedButton.icon(
            onPressed: onScanOCR,
            icon: const Icon(Icons.document_scanner),
            label: const Text("Scan OCR"),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save),
            label: const Text("Save"),
          ),
        ),
      ],
    );
  }
}