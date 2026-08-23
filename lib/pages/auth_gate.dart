import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../services/sync_service.dart';
import '../shared/loading_widget.dart';
import '../utils/app_logger.dart';
import 'dashboard_page.dart';

/// App ini dipakai sendiri (tidak di-publish) — tidak ada layar login
/// manual. [SupabaseService.ensureSignedIn] sudah dipanggil sekali di
/// `main.dart` sebelum `runApp()`, jadi biasanya begitu widget ini
/// dibangun sesi sudah aktif dan langsung tampil [DashboardPage].
///
/// Kalau sesi hilang saat app jalan (mis. token kedaluwarsa/offline lama),
/// widget ini otomatis coba login ulang sendiri (bukan minta user isi
/// form) — lihat [_retrySignIn].
///
/// Juga yang memicu [SyncService.pullAndReconcile]: sekali saat baru
/// login, dan setiap kali app kembali ke foreground
/// ([AppLifecycleState.resumed]) selama masih login (menutup celah
/// "offline lalu balik online" tanpa perlu queue sync terpisah, lihat
/// `SyncService`).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  late final StreamSubscription<AuthState> _authSubscription;
  bool _isLoggedIn = SupabaseService.isLoggedIn;
  bool _isRetrying = false;
  String? _retryError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _authSubscription = SupabaseService.authStateChanges.listen((state) {
      final loggedIn = state.session != null;
      final justLoggedIn = loggedIn && !_isLoggedIn;

      if (mounted) setState(() => _isLoggedIn = loggedIn);

      if (justLoggedIn) {
        SyncService.pullAndReconcile();
      } else if (!loggedIn) {
        _retrySignIn();
      }
    });

    if (_isLoggedIn) {
      SyncService.pullAndReconcile();
    } else {
      _retrySignIn();
    }
  }

  /// Coba login ulang otomatis pakai akun tetap. Dipakai saat sesi belum/
  /// tidak lagi aktif — tidak pernah menampilkan form login ke user.
  Future<void> _retrySignIn() async {
    if (_isRetrying) return;
    setState(() {
      _isRetrying = true;
      _retryError = null;
    });

    try {
      await SupabaseService.ensureSignedIn();
    } catch (e) {
      AppLogger.log('AuthGate: auto-login gagal: $e');
      if (mounted) setState(() => _retryError = e.toString());
    } finally {
      if (mounted) setState(() => _isRetrying = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    if (SupabaseService.isLoggedIn) {
      SyncService.pullAndReconcile();
    } else {
      _retrySignIn();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) return const DashboardPage();

    if (_retryError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 40,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tidak bisa konek ke Supabase:\n$_retryError',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _retrySignIn, child: const Text('Coba lagi')),
              ],
            ),
          ),
        ),
      );
    }

    return const LoadingWidget();
  }
}
