import 'package:hive/hive.dart';

/// Menyimpan preferensi user yang persisten tapi bukan data trading
/// (saat ini: persentase batas rugi & target profit untuk fitur
/// Risk Limit). Beda box dari [HiveService] karena ini "settings",
/// bukan data transaksi.
class SettingsService {
  static const String boxName = "settings";

  static const String _maxLossKey = "max_loss_percent";
  static const String _profitTargetKey = "profit_target_percent";

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

  /// Simpan pengaturan batas risiko baru dari [RiskLimitEditDialog].
  static Future<void> saveRiskLimit({
    required double maxLossPercent,
    required double profitTargetPercent,
  }) async {
    final box = await _openBox();

    await box.put(_maxLossKey, maxLossPercent);
    await box.put(_profitTargetKey, profitTargetPercent);
  }
}
