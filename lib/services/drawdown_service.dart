import '../models/account_timeline_model.dart';
import '../models/drawdown_model.dart';

class DrawdownService {
  static DrawdownModel calculate(
    List<AccountTimelineModel> timeline,
  ) {
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
    // HITUNG DRAWDown
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

    final currentDrawdown =
        peakBalance - currentBalance;

    // ==========================================
    // DEBUG
    // ==========================================

    print("");
    print("========== DRAWDOWN ==========");
    print("Peak Balance     : $peakBalance");
    print("Current Balance  : $currentBalance");
    print("Current Drawdown : $currentDrawdown");
    print("Maximum Drawdown : $maximumDrawdown");
    print("==============================");
    print("");

    return DrawdownModel(
      peakBalance: peakBalance,
      currentBalance: currentBalance,
      currentDrawdown: currentDrawdown,
      maximumDrawdown: maximumDrawdown,
    );
  }
}