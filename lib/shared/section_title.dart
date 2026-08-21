import 'package:flutter/material.dart';

/// Judul section rata kiri dengan style konsisten (tebal, ukuran 18),
/// dipakai untuk memisahkan bagian-bagian di halaman seperti Dashboard.
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
