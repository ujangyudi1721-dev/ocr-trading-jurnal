import 'dart:async';

import 'package:flutter/material.dart';

/// Screen shown when the app starts. After [duration] it calls [onFinish].
class SplashPage extends StatefulWidget {
  final VoidCallback onFinish;
  final Duration duration;

  const SplashPage({
    super.key,
    required this.onFinish,
    this.duration = const Duration(seconds: 10),
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // After the duration, tell the parent that the splash is done.
    _timer = Timer(widget.duration, widget.onFinish);
  }

  @override
  void dispose() {
    _timer?.cancel(); // stop the timer if the page closes early
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icon/icon.png',
              width: 120,
              // If the image can't load, show an icon instead.
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.show_chart, size: 96, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'OCR Trading Journal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Disiplin dulu, profit menyusul',
              style: TextStyle(color: Color.fromARGB(179, 0, 255, 106),
              fontSize: 27,
              fontWeight: FontWeight.bold,),
            ),
             const Text(
              '1. Batas maksimal stop loss 3% equity',
              style: TextStyle(color: Colors.white70),
            ),
             const Text(
              '2. Loss 5X stop trading',
              style: TextStyle(color: Colors.white70),
            ),
             const Text(
              '3. Hentikan balas dendam',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            const Text(
              'BALAS DENDAM',
              style: TextStyle(
                color: Color.fromARGB(255, 248, 0, 0),
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'MENGHANCURKAN MU',
              style: TextStyle(
                color: Color.fromARGB(255, 248, 0, 0),
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
