import 'package:supabase_flutter/supabase_flutter.dart';

/// Lapisan akses ke Supabase (auth + client). Kredensial dibaca dari
/// `--dart-define-from-file=env.json` (lihat `env.example.json`), bukan
/// dari `.env` bundled asset — supaya tidak perlu deklarasi asset khusus
/// dan konsisten di semua platform (android/ios/linux/macos/web/windows).
///
/// App ini dipakai sendiri (tidak di-publish), jadi tidak ada layar login —
/// [ensureSignedIn] otomatis masuk pakai SATU akun tetap yang emailnya
/// diset di `env.json` (`SUPABASE_EMAIL`/`SUPABASE_PASSWORD`). Akun itu
/// sendiri harus sudah dibuat lebih dulu lewat Supabase Dashboard
/// (Authentication > Users > Add user, centang "Auto Confirm User") —
/// app ini tidak punya alur signup.
///
/// Kalau kredensial kosong/salah, sengaja dibuat gagal keras dengan pesan
/// jelas (lihat `main.dart`), bukan diam-diam nyangkut di splash screen.
class SupabaseService {
  static const String _url = String.fromEnvironment('SUPABASE_URL');
  static const String _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _fixedEmail = String.fromEnvironment('SUPABASE_EMAIL');
  static const String _fixedPassword = String.fromEnvironment('SUPABASE_PASSWORD');

  static Future<void> init() async {
    if (_url.isEmpty || _anonKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL/SUPABASE_ANON_KEY kosong. Jalankan app dengan '
        '--dart-define-from-file=env.json (isi dulu dari env.example.json).',
      );
    }

    // `publishableKey` adalah nama baru untuk apa yang di dashboard Supabase
    // (Settings > API) masih disebut "anon key" / "publishable key" —
    // keduanya sama-sama aman dipakai di client, diproteksi oleh RLS.
    await Supabase.initialize(url: _url, publishableKey: _anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static User? get currentUser => auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() {
    return auth.signOut();
  }

  /// Login otomatis pakai akun tetap kalau belum ada sesi aktif. Idempotent
  /// — dipanggil sekali di startup ([main.dart]) dan diulang lagi oleh
  /// [AuthGate] tiap kali sesi hilang (mis. token kedaluwarsa), tanpa
  /// pernah menampilkan form login ke user.
  static Future<void> ensureSignedIn() async {
    if (isLoggedIn) return;

    if (_fixedEmail.isEmpty || _fixedPassword.isEmpty) {
      throw StateError(
        'SUPABASE_EMAIL/SUPABASE_PASSWORD kosong di env.json. Buat 1 akun '
        'lewat Supabase Dashboard (Authentication > Users > Add user, '
        'centang "Auto Confirm User"), lalu isi email/password itu di '
        'env.json.',
      );
    }

    await signIn(email: _fixedEmail, password: _fixedPassword);
  }
}
