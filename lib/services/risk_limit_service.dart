import '../models/risk_limit_model.dart';

/// Menghitung batas risiko harian ([RiskLimitModel]) dari saldo saat
/// ini dan persentase yang diset user di [SettingsService].
class RiskLimitService {
  /// Hitung batas rugi & target profit (nominal + level saldo) dari
  /// [balance] saat ini dan persentase yang diinginkan user.
  static RiskLimitModel calculate({
    required double balance,
    required double maxLossPercent,
    required double profitTargetPercent,
  }) {
    final double maxLossAmount = balance * maxLossPercent / 100;

    final double profitTargetAmount = balance * profitTargetPercent / 100;

    final double lossLimitBalance = balance - maxLossAmount;

    final double profitTargetBalance = balance + profitTargetAmount;

    return RiskLimitModel(
      balance: balance,
      maxLossPercent: maxLossPercent,
      profitTargetPercent: profitTargetPercent,
      maxLossAmount: maxLossAmount,
      profitTargetAmount: profitTargetAmount,
      lossLimitBalance: lossLimitBalance,
      profitTargetBalance: profitTargetBalance,
    );
  }
}
