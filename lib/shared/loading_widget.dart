import 'package:flutter/material.dart';

/// Layar loading generik (spinner di tengah, dibungkus [Scaffold]
/// sendiri) — dipakai di halaman-halaman yang perlu tampilan penuh
/// sementara menunggu data pertama kali dimuat.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
