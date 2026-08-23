// Port 1:1 dari lib/services/analytics_engine.dart.
import { calculateDrawdown } from "./drawdown";
import { calculateRiskLimit } from "./risk-limit";
import type {
  AnalyticsResult,
  EmotionStatistic,
  EquityPoint,
  PairStatistic,
  TimelineItem,
} from "./types";

export function calculateAnalytics(
  timeline: TimelineItem[],
  maxLossPercent = 2,
  profitTargetPercent = 3,
): AnalyticsResult {
  let totalTrade = 0;
  let totalWin = 0;
  let totalLoss = 0;
  let grossProfit = 0;
  let grossLoss = 0;
  let totalDeposit = 0;
  let totalWithdraw = 0;
  let currentBalance = 0;

  for (const item of timeline) {
    switch (item.type) {
      case "Deposit":
        totalDeposit += item.amount;
        break;
      case "Withdraw":
        totalWithdraw += item.amount;
        break;
      case "Trade":
        totalTrade++;
        if (item.amount >= 0) {
          totalWin++;
          grossProfit += item.amount;
        } else {
          totalLoss++;
          grossLoss += Math.abs(item.amount);
        }
        break;
    }
    currentBalance = item.balance;
  }

  const netDeposit = totalDeposit - totalWithdraw;
  const growth = netDeposit > 0 ? ((currentBalance - netDeposit) / netDeposit) * 100 : 0;

  const riskLimit = calculateRiskLimit(currentBalance, maxLossPercent, profitTargetPercent);

  const netProfit = grossProfit - grossLoss;
  const winRate = totalTrade === 0 ? 0 : (totalWin / totalTrade) * 100;
  const averageWin = totalWin === 0 ? 0 : grossProfit / totalWin;
  const averageLoss = totalLoss === 0 ? 0 : grossLoss / totalLoss;
  const profitFactor = grossLoss === 0 ? 0 : grossProfit / grossLoss;

  const drawdown = calculateDrawdown(timeline);
  const equity = calculateEquity(timeline);
  const pairPerformance = calculatePairPerformance(timeline);
  const emotionPerformance = calculateEmotionPerformance(timeline);

  return {
    totalTrade,
    totalWin,
    totalLoss,
    grossProfit,
    grossLoss,
    netProfit,
    winRate,
    averageWin,
    averageLoss,
    profitFactor,
    totalDeposit,
    totalWithdraw,
    currentBalance,
    growth,
    equity,
    pairPerformance,
    emotionPerformance,
    drawdown,
    riskLimit,
  };
}

export function calculateEquity(timeline: TimelineItem[]): EquityPoint[] {
  return timeline.map((item, i) => ({ index: i + 1, balance: item.balance }));
}

export function calculatePairPerformance(timeline: TimelineItem[]): PairStatistic[] {
  const map = new Map<string, PairStatistic>();

  for (const item of timeline) {
    if (item.type !== "Trade") continue;

    const pair = item.pair ?? "UNKNOWN";
    const existing = map.get(pair) ?? {
      pair,
      totalTrade: 0,
      profit: 0,
      totalWin: 0,
      totalLoss: 0,
    };

    const isWin = item.amount >= 0;
    map.set(pair, {
      pair,
      totalTrade: existing.totalTrade + 1,
      profit: existing.profit + item.amount,
      totalWin: existing.totalWin + (isWin ? 1 : 0),
      totalLoss: existing.totalLoss + (isWin ? 0 : 1),
    });
  }

  return [...map.values()].sort((a, b) => b.profit - a.profit);
}

/** Hanya trade yang punya tag emosi yang dihitung. */
export function calculateEmotionPerformance(timeline: TimelineItem[]): EmotionStatistic[] {
  const map = new Map<string, EmotionStatistic>();

  for (const item of timeline) {
    if (item.type !== "Trade") continue;

    const emotion = item.emotion;
    if (!emotion) continue;

    const existing = map.get(emotion) ?? {
      emotion,
      totalTrade: 0,
      profit: 0,
      totalWin: 0,
      totalLoss: 0,
    };

    const isWin = item.amount >= 0;
    map.set(emotion, {
      emotion,
      totalTrade: existing.totalTrade + 1,
      profit: existing.profit + item.amount,
      totalWin: existing.totalWin + (isWin ? 1 : 0),
      totalLoss: existing.totalLoss + (isWin ? 0 : 1),
    });
  }

  return [...map.values()].sort((a, b) => b.profit - a.profit);
}
