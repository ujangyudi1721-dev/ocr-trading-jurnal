// Generalisasi dari lib/services/daily_report_service.dart — logika intinya
// (opening/closing balance, profit%, base persentase pakai deposit hari
// pertama) di-port 1:1, cuma kunci pengelompokannya dibuat bisa
// hari/minggu/bulan karena app mobile cuma punya laporan harian.
import type { PeriodReport, ReportPeriod, TimelineItem } from "./types";

const MONTH_NAMES = [
  "Januari",
  "Februari",
  "Maret",
  "April",
  "Mei",
  "Juni",
  "Juli",
  "Agustus",
  "September",
  "Oktober",
  "November",
  "Desember",
];

/** Awal periode yang memuat `date` — awal hari, Senin minggu itu, atau tanggal 1 bulan itu. */
function periodStartOf(date: Date, period: ReportPeriod): Date {
  if (period === "day") {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate());
  }

  if (period === "month") {
    return new Date(date.getFullYear(), date.getMonth(), 1);
  }

  // week: Senin sebagai awal minggu.
  const day = date.getDay(); // 0=Minggu, 1=Senin, ... 6=Sabtu
  const diffToMonday = day === 0 ? -6 : 1 - day;
  const monday = new Date(date.getFullYear(), date.getMonth(), date.getDate() + diffToMonday);
  return monday;
}

function two(n: number): string {
  return n.toString().padStart(2, "0");
}

function formatPeriodLabel(periodStart: Date, period: ReportPeriod): string {
  if (period === "day") {
    return `${two(periodStart.getDate())}/${two(periodStart.getMonth() + 1)}/${periodStart.getFullYear()}`;
  }

  if (period === "month") {
    return `${MONTH_NAMES[periodStart.getMonth()]} ${periodStart.getFullYear()}`;
  }

  const weekEnd = new Date(periodStart);
  weekEnd.setDate(weekEnd.getDate() + 6);
  const sameMonth = periodStart.getMonth() === weekEnd.getMonth();
  const startLabel = sameMonth
    ? `${two(periodStart.getDate())}`
    : `${two(periodStart.getDate())}/${two(periodStart.getMonth() + 1)}`;
  return `${startLabel} - ${two(weekEnd.getDate())}/${two(weekEnd.getMonth() + 1)}/${weekEnd.getFullYear()}`;
}

/**
 * Rekap timeline per periode (hari/minggu/bulan), terurut LAMA -> BARU.
 * `timeline` tidak diubah (di-copy dulu sebelum di-sort).
 */
export function generatePeriodReport(
  timeline: TimelineItem[],
  period: ReportPeriod,
): PeriodReport[] {
  if (timeline.length === 0) return [];

  const sorted = [...timeline].sort((a, b) => a.date.getTime() - b.date.getTime());

  const grouped = new Map<number, TimelineItem[]>();
  const starts = new Map<number, Date>();

  for (const item of sorted) {
    const start = periodStartOf(item.date, period);
    const key = start.getTime();
    if (!grouped.has(key)) {
      grouped.set(key, []);
      starts.set(key, start);
    }
    grouped.get(key)!.push(item);
  }

  const reports: PeriodReport[] = [];
  let previousBalance = 0;

  for (const [key, items] of grouped) {
    let profit = 0;
    let deposit = 0;
    let withdraw = 0;
    let totalTrade = 0;
    let totalWin = 0;
    let totalLoss = 0;

    for (const item of items) {
      switch (item.type) {
        case "Deposit":
          deposit += item.amount;
          break;
        case "Withdraw":
          withdraw += item.amount;
          break;
        case "Trade":
          profit += item.amount;
          totalTrade++;
          if (item.amount >= 0) totalWin++;
          else totalLoss++;
          break;
      }
    }

    const openingBalance = previousBalance;
    const closingBalance = items[items.length - 1].balance;

    let base = openingBalance;
    if (base <= 0) base = openingBalance + deposit;

    const profitPercent = base <= 0 ? 0 : (profit / base) * 100;

    const periodStart = starts.get(key)!;
    reports.push({
      periodStart,
      label: formatPeriodLabel(periodStart, period),
      openingBalance,
      closingBalance,
      profit,
      profitPercent,
      totalTrade,
      totalWin,
      totalLoss,
      deposit,
      withdraw,
    });

    previousBalance = closingBalance;
  }

  return reports;
}
