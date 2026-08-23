// Port 1:1 dari lib/services/risk_limit_service.dart.
import type { RiskLimitResult } from "./types";

export function calculateRiskLimit(
  balance: number,
  maxLossPercent: number,
  profitTargetPercent: number,
): RiskLimitResult {
  const maxLossAmount = (balance * maxLossPercent) / 100;
  const profitTargetAmount = (balance * profitTargetPercent) / 100;

  return {
    balance,
    maxLossPercent,
    profitTargetPercent,
    maxLossAmount,
    profitTargetAmount,
    lossLimitBalance: balance - maxLossAmount,
    profitTargetBalance: balance + profitTargetAmount,
  };
}
