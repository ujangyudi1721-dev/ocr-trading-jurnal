import '../models/account_timeline_model.dart';
import '../models/drawdown_model.dart';
import '../utils/app_logger.dart';

/// Menghitung [DrawdownModel] (peak balance, drawdown saat ini, dan
/// drawdown maksimum) dari [AccountTimelineModel] yang sudah punya
/// saldo berjalan (running balance).
class DrawdownService {
  /// Hitung drawdown dari [timeline]. [timeline] harus sudah terurut
  /// LAMA -> BARU dan setiap item sudah punya `balance` terisi
  /// (lihat `AccountTimelineService.calculateBalance`).
  static DrawdownModel calculate(List<AccountTimelineModel> timeline) {
    // ==========================================
    // TIMELINE KOSONG
    // ==========================================

    if (timeline.isEmpty) {
      return const DrawdownModel(
        peakBalance: 0,
        currentBalance: 0,
        currentDrawdown: 0,
        maximumDrawdown: 0,
      );
    }

    // ==========================================
    // PEAK AWAL
    // ==========================================

    double peakBalance = timeline.first.balance;

    double maximumDrawdown = 0;

    // ==========================================
    // HITUNG DRAWDOWN
    // ==========================================

    for (final item in timeline) {
      final balance = item.balance;

      // Jika balance membuat high baru,
      // update peak.
      if (balance > peakBalance) {
        peakBalance = balance;
      }

      // Drawdown = Peak - Balance
      final drawdown = peakBalance - balance;

      // Simpan drawdown terbesar
      if (drawdown > maximumDrawdown) {
        maximumDrawdown = drawdown;
      }
    }

    // ==========================================
    // CURRENT BALANCE
    // ==========================================

    final currentBalance = timeline.last.balance;

    // ==========================================
    // CURRENT DRAWDOWN
    // ==========================================

    final currentDrawdown = peakBalance - currentBalance;

    // ==========================================
    // DEBUG
    // ==========================================

    AppLogger.log("");
    AppLogger.log("========== DRAWDOWN ==========");
    AppLogger.log("Peak Balance     : $peakBalance");
    AppLogger.log("Current Balance  : $currentBalance");
    AppLogger.log("Current Drawdown : $currentDrawdown");
    AppLogger.log("Maximum Drawdown : $maximumDrawdown");
    AppLogger.log("==============================");
    AppLogger.log("");

    return DrawdownModel(
      peakBalance: peakBalance,
      currentBalance: currentBalance,
      currentDrawdown: currentDrawdown,
      maximumDrawdown: maximumDrawdown,
    );
  }
}
