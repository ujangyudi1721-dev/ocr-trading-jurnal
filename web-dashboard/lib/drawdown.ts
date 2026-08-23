// Port 1:1 dari lib/services/drawdown_service.dart.
import type { DrawdownResult, TimelineItem } from "./types";

/**
 * Hitung drawdown dari timeline. `timeline` harus sudah terurut
 * LAMA -> BARU dan setiap item sudah punya `balance` terisi.
 */
export function calculateDrawdown(timeline: TimelineItem[]): DrawdownResult {
  if (timeline.length === 0) {
    return { peakBalance: 0, currentBalance: 0, currentDrawdown: 0, maximumDrawdown: 0 };
  }

  let peakBalance = timeline[0].balance;
  let maximumDrawdown = 0;

  for (const item of timeline) {
    const balance = item.balance;

    if (balance > peakBalance) {
      peakBalance = balance;
    }

    const drawdown = peakBalance - balance;
    if (drawdown > maximumDrawdown) {
      maximumDrawdown = drawdown;
    }
  }

  const currentBalance = timeline[timeline.length - 1].balance;
  const currentDrawdown = peakBalance - currentBalance;

  return { peakBalance, currentBalance, currentDrawdown, maximumDrawdown };
}
