import 'package:hive/hive.dart';

class SettingsService {
  static const String boxName = "settings";

  static const String _maxLossKey = "max_loss_percent";
  static const String _profitTargetKey = "profit_target_percent";

  static const double defaultMaxLossPercent = 2;
  static const double defaultProfitTargetPercent = 3;

  static Future<Box> _openBox() async {
    return await Hive.openBox(boxName);
  }

  static Future<double> getMaxLossPercent() async {
    final box = await _openBox();

    return box.get(_maxLossKey, defaultValue: defaultMaxLossPercent) as double;
  }

  static Future<double> getProfitTargetPercent() async {
    final box = await _openBox();

    return box.get(_profitTargetKey, defaultValue: defaultProfitTargetPercent)
        as double;
  }

  static Future<void> saveRiskLimit({
    required double maxLossPercent,
    required double profitTargetPercent,
  }) async {
    final box = await _openBox();

    await box.put(_maxLossKey, maxLossPercent);
    await box.put(_profitTargetKey, profitTargetPercent);
  }
}
