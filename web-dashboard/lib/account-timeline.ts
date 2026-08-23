// Port 1:1 dari lib/services/account_timeline_service.dart.
import { parseDate } from "./date-helper";
import type {
  AccountTransactionRow,
  TimelineItem,
  TradeRow,
} from "./types";

/**
 * Gabungkan trades + account_transactions jadi satu timeline terurut
 * (lama -> baru) lengkap dengan saldo berjalan (running balance).
 *
 * Item dengan tanggal yang gagal di-parse dilewati (tidak dianggap
 * "sekarang") — sama seperti versi Dart-nya.
 */
export function generateTimeline(
  transactions: AccountTransactionRow[],
  trades: TradeRow[],
): TimelineItem[] {
  const timeline: TimelineItem[] = [];

  for (const tx of transactions) {
    const date = tx.date ? parseDate(tx.date) : null;
    if (!date) continue;

    timeline.push({
      date,
      type: (tx.type as "Deposit" | "Withdraw") ?? "Deposit",
      amount: tx.amount ?? 0,
      balance: 0,
      reference: tx.type ?? "",
    });
  }

  for (const trade of trades) {
    const date = trade.close_time ? parseDate(trade.close_time) : null;
    if (!date) continue;

    const profit = Number.parseFloat((trade.profit ?? "0").replaceAll("+", ""));

    timeline.push({
      date,
      type: "Trade",
      amount: Number.isNaN(profit) ? 0 : profit,
      balance: 0,
      reference: trade.ticket ?? "",
      pair: trade.pair,
      tradeType: trade.type,
      emotion: trade.emotion,
    });
  }

  timeline.sort((a, b) => a.date.getTime() - b.date.getTime());

  calculateBalance(timeline);

  return timeline;
}

/** Isi field `balance` tiap item secara berjalan. Mengubah array in-place. */
export function calculateBalance(timeline: TimelineItem[]): void {
  let balance = 0;

  for (const item of timeline) {
    switch (item.type) {
      case "Deposit":
        balance += item.amount;
        break;
      case "Withdraw":
        balance -= item.amount;
        break;
      case "Trade":
        balance += item.amount;
        break;
    }
    item.balance = balance;
  }
}
