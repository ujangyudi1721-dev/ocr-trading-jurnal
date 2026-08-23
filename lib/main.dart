import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/account_transaction_model.dart';
import 'models/trade_model.dart';
import 'pages/auth_gate.dart';
import 'services/migration_service.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(TradeModelAdapter());

  Hive.registerAdapter(AccountTransactionModelAdapter());

  // Backfill remoteId/updatedAt untuk data lokal lama SEBELUM sync pertama
  // dicoba — lihat dokumentasi MigrationService untuk alasannya.
  await MigrationService.backfillRemoteIds();

  // Kalau kredensial Supabase kosong/salah (lupa pasang flag
  // --dart-define-from-file=env.json, atau akun tetapnya belum dibuat),
  // init()/ensureSignedIn() melempar exception. Tangkap di sini dan
  // tampilkan sebagai layar error yang jelas — TANPA ini, exception di
  // dalam main() sebelum runApp() bikin app nyangkut di splash screen
  // native selamanya tanpa pesan apa pun yang kelihatan di layar (cuma
  // masuk log).
  String? configError;
  try {
    await SupabaseService.init();
    // App ini dipakai sendiri, tidak ada layar login — langsung auto-login
    // pakai 1 akun tetap (lihat SupabaseService.ensureSignedIn).
    await SupabaseService.ensureSignedIn();
  } catch (e) {
    configError = e.toString();
  }

  runApp(MyApp(configError: configError));
}

class MyApp extends StatelessWidget {
  final String? configError;

  const MyApp({super.key, this.configError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OCR Trading Journal',
      home: configError != null ? _ConfigErrorPage(message: configError!) : const AuthGate(),
    );
  }
}

/// Ditampilkan kalau setup awal (saat ini: kredensial Supabase) gagal,
/// supaya user/developer langsung lihat penyebabnya di layar — bukan
/// nyangkut di splash screen tanpa penjelasan.
class _ConfigErrorPage extends StatelessWidget {
  final String message;

  const _ConfigErrorPage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Gagal memulai aplikasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
