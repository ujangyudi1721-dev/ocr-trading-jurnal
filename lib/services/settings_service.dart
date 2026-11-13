import 'dart:async';

import 'package:hive/hive.dart';

import 'sync_service.dart';

/// Menyimpan preferensi user yang persisten tapi bukan data trading
/// (saat ini: persentase batas rugi & target profit untuk fitur
/// Risk Limit, plus bookmark waktu sync terakhir). Beda box dari
/// [HiveService] karena ini "settings", bukan data transaksi.
class SettingsService {
  static const String _tradingRulesKey = "trading_rules";

  static const String boxName = "settings";

  static const String _maxLossKey = "max_loss_percent";
  static const String _profitTargetKey = "profit_target_percent";
  static const String _lastSyncedAtKey = "last_synced_at";

  static const double defaultMaxLossPercent = 2;
  static const double defaultProfitTargetPercent = 3;

  static Future<Box> _openBox() async {
    return await Hive.openBox(boxName);
  }

  /// Ambil persentase batas rugi tersimpan, atau [defaultMaxLossPercent]
  /// kalau belum pernah diset user.
  static Future<double> getMaxLossPercent() async {
    final box = await _openBox();

    return box.get(_maxLossKey, defaultValue: defaultMaxLossPercent) as double;
  }

  /// Ambil persentase target profit tersimpan, atau
  /// [defaultProfitTargetPercent] kalau belum pernah diset user.
  static Future<double> getProfitTargetPercent() async {
    final box = await _openBox();

    return box.get(_profitTargetKey, defaultValue: defaultProfitTargetPercent)
        as double;
  }

  /// Simpan pengaturan batas risiko baru dari [RiskLimitEditDialog], lalu
  /// coba sinkronkan ke Supabase (best-effort, tidak blokir kalau offline).
  static Future<void> saveRiskLimit({
    required double maxLossPercent,
    required double profitTargetPercent,
  }) async {
    await saveRiskLimitLocalOnly(
      maxLossPercent: maxLossPercent,
      profitTargetPercent: profitTargetPercent,
    );

    unawaited(
      SyncService.pushSettings(
        maxLossPercent: maxLossPercent,
        profitTargetPercent: profitTargetPercent,
      ),
    );
  }

  /// Simpan pengaturan batas risiko tanpa memicu push ke Supabase. Dipakai
  /// [SyncService] sendiri saat menulis hasil pull dari server ke lokal,
  /// supaya tidak terjadi push-balik yang tidak perlu.
  static Future<void> saveRiskLimitLocalOnly({
    required double maxLossPercent,
    required double profitTargetPercent,
  }) async {
    final box = await _openBox();

    await box.put(_maxLossKey, maxLossPercent);
    await box.put(_profitTargetKey, profitTargetPercent);
  }

  /// Waktu terakhir [SyncService.pullAndReconcile] berhasil jalan, atau
  /// `null` kalau belum pernah sync sama sekali.
  static Future<DateTime?> getLastSyncedAt() async {
    final box = await _openBox();

    final iso = box.get(_lastSyncedAtKey) as String?;
    return iso == null ? null : DateTime.parse(iso);
  }

  /// Set bookmark waktu sync terakhir.
  static Future<void> setLastSyncedAt(DateTime time) async {
    final box = await _openBox();

    await box.put(_lastSyncedAtKey, time.toIso8601String());
  }

  static const List<String> defaultTradingRules = [
    'Stop Loss tidak boleh melebihi presentasi yang ditentukan',
    'Tidak boleh melanggar aturan',
  ];

  static Future<List<String>> getTradingRules() async {
    final box = await _openBox();
    final saved = box.get(_tradingRulesKey);

    if (saved == null) return List<String>.from(defaultTradingRules);
    return List<String>.from(saved as List);
  }

  static Future<void> saveTradingRules(List<String> rules) async {
    final box = await _openBox();
    await box.put(_tradingRulesKey, rules);
  }
}
