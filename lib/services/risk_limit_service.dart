import '../models/risk_limit_model.dart';

class RiskLimitService {
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

  static void test() {
    print("Profit Target Input : 3");
    final result = calculate(
      balance: 5000,
      maxLossPercent: 2,
      profitTargetPercent: 3,
    );

    print("========== RISK TEST ==========");
    print("Balance              : ${result.balance}");
    print("Max Loss %           : ${result.maxLossPercent}");
    print("Max Loss Amount      : ${result.maxLossAmount}");
    print("Loss Limit Balance   : ${result.lossLimitBalance}");
    print("Profit Target %      : ${result.profitTargetPercent}");
    print("Profit Target Amount : ${result.profitTargetAmount}");
    print("Profit Target Balance: ${result.profitTargetBalance}");
    print("===============================");
  }
}
