"use client";

import { useState } from "react";
import { fmt, fmtPercent } from "@/lib/format";
import type { PeriodReport, ReportPeriod } from "@/lib/types";
import { PeriodBarChart } from "./period-bar-chart";

const TABS: { key: ReportPeriod; label: string }[] = [
  { key: "day", label: "Harian" },
  { key: "week", label: "Mingguan" },
  { key: "month", label: "Bulanan" },
];

export function PeriodReportTabs({
  reports,
}: {
  reports: Record<ReportPeriod, PeriodReport[]>;
}) {
  const [active, setActive] = useState<ReportPeriod>("day");
  const periodReports = reports[active];
  const rows = [...periodReports].reverse(); // list: terbaru di atas, grafik: kronologis (lama->baru)

  return (
    <div>
      <div className="flex gap-1 rounded-xl border border-border bg-surface-1 p-1">
        {TABS.map((tab) => (
          <button
            key={tab.key}
            type="button"
            onClick={() => setActive(tab.key)}
            className="flex-1 rounded-lg px-3 py-2 text-sm font-medium transition-colors"
            style={{
              background: active === tab.key ? "var(--series-1)" : "transparent",
              color: active === tab.key ? "#ffffff" : "var(--text-secondary)",
            }}
          >
            {tab.label}
          </button>
        ))}
      </div>

      <div className="mt-4 grid grid-cols-1 items-start gap-4 lg:grid-cols-[3fr_2fr]">
        <PeriodBarChart reports={periodReports} />

        <div className="flex flex-col gap-2 lg:max-h-[26rem] lg:overflow-y-auto lg:pr-1">
          {rows.length === 0 ? (
            <p className="py-10 text-center text-sm text-text-muted">Belum ada data.</p>
          ) : (
            rows.map((r) => {
              const isProfit = r.profit >= 0;
              const color = isProfit ? "var(--status-good)" : "var(--status-critical)";

              return (
                <div
                  key={r.periodStart.getTime()}
                  className="rounded-xl border border-border bg-surface-1 px-4 py-3"
                >
                  <div className="flex items-baseline justify-between">
                    <span className="font-medium text-text-primary">{r.label}</span>
                    <span className="font-bold" style={{ color }}>
                      {fmt(r.profit)} ({fmtPercent(r.profitPercent)})
                    </span>
                  </div>
                  <div className="mt-2 flex flex-wrap gap-x-4 gap-y-1 text-xs text-text-muted">
                    <span>Open: {fmt(r.openingBalance)}</span>
                    <span>Close: {fmt(r.closingBalance)}</span>
                    <span>
                      Trade: {r.totalTrade} ({r.totalWin}W/{r.totalLoss}L)
                    </span>
                    {r.deposit > 0 && <span>Deposit: {fmt(r.deposit)}</span>}
                    {r.withdraw > 0 && <span>Withdraw: {fmt(r.withdraw)}</span>}
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>
    </div>
  );
}
