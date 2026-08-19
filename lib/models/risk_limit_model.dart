class RiskLimitModel {
  final double balance;

  final double maxLossPercent;
  final double profitTargetPercent;

  final double maxLossAmount;
  final double profitTargetAmount;

  final double lossLimitBalance;
  final double profitTargetBalance;

  RiskLimitModel({
    required this.balance,
    required this.maxLossPercent,
    required this.profitTargetPercent,
    required this.maxLossAmount,
    required this.profitTargetAmount,
    required this.lossLimitBalance,
    required this.profitTargetBalance,
  });
}
