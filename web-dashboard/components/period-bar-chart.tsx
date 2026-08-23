"use client";

import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  ReferenceLine,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { fmt, fmtPercent } from "@/lib/format";
import type { PeriodReport } from "@/lib/types";

function BarTooltip({
  active,
  payload,
}: {
  active?: boolean;
  payload?: { payload: PeriodReport }[];
}) {
  if (!active || !payload?.length) return null;
  const r = payload[0].payload;
  const color = r.profit >= 0 ? "var(--status-good)" : "var(--status-critical)";

  return (
    <div className="rounded-lg border border-border bg-surface-1 px-3 py-2 text-sm shadow-md">
      <p className="text-text-secondary">{r.label}</p>
      <p className="font-bold" style={{ color }}>
        {fmt(r.profit)} ({fmtPercent(r.profitPercent)})
      </p>
      <p className="text-xs text-text-muted">
        {r.totalTrade} trade · {r.totalWin}W/{r.totalLoss}L
      </p>
    </div>
  );
}

/** Grafik batang profit per periode — hijau untung, merah rugi (status color, bukan kategorikal). */
export function PeriodBarChart({ reports }: { reports: PeriodReport[] }) {
  if (reports.length === 0) {
    return (
      <div className="rounded-2xl border border-border bg-surface-1 p-5">
        <p className="text-sm font-bold text-text-primary">GRAFIK PROFIT PER PERIODE</p>
        <p className="mt-10 text-center text-sm text-text-muted">Belum ada data.</p>
      </div>
    );
  }

  return (
    <div className="rounded-2xl border border-border bg-surface-1 p-5">
      <p className="text-sm font-bold text-text-primary">GRAFIK PROFIT PER PERIODE</p>
      <div className="mt-4 h-96 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={reports} margin={{ top: 8, right: 8, bottom: 8, left: 0 }}>
            <CartesianGrid stroke="var(--gridline)" vertical={false} />
            <XAxis
              dataKey="label"
              tick={{ fill: "var(--text-muted)", fontSize: 11 }}
              stroke="var(--axis)"
              tickLine={false}
              angle={-35}
              textAnchor="end"
              height={60}
              interval="preserveStartEnd"
            />
            <YAxis
              width={64}
              tick={{ fill: "var(--text-muted)", fontSize: 11 }}
              stroke="var(--axis)"
              tickLine={false}
              axisLine={false}
              tickFormatter={(v: number) => fmt(v)}
            />
            <ReferenceLine y={0} stroke="var(--axis)" />
            <Tooltip content={<BarTooltip />} cursor={{ fill: "var(--gridline)" }} />
            <Bar dataKey="profit" radius={[3, 3, 3, 3]} maxBarSize={40}>
              {reports.map((r) => (
                <Cell
                  key={r.periodStart.getTime()}
                  fill={r.profit >= 0 ? "var(--status-good)" : "var(--status-critical)"}
                />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
