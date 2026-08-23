"use client";

import {
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { fmt } from "@/lib/format";
import type { EquityPoint } from "@/lib/types";

function EquityTooltip({
  active,
  payload,
}: {
  active?: boolean;
  payload?: { value: number }[];
}) {
  if (!active || !payload?.length) return null;
  return (
    <div className="rounded-lg border border-border bg-surface-1 px-3 py-2 text-sm shadow-md">
      <p className="text-text-secondary">Balance</p>
      <p className="font-bold text-text-primary">{fmt(payload[0].value)}</p>
    </div>
  );
}

// Single-series line chart (equity curve), kategori slot-1 (biru) per
// palet dataviz — 2px line, gridline & axis recessive, tooltip di hover.
export function EquityChart({ equity }: { equity: EquityPoint[] }) {
  if (equity.length === 0) {
    return (
      <div className="rounded-2xl border border-border bg-surface-1 p-5">
        <p className="text-sm font-bold text-text-primary">EQUITY CURVE</p>
        <p className="mt-6 text-center text-sm text-text-muted">Belum ada data.</p>
      </div>
    );
  }

  return (
    <div className="rounded-2xl border border-border bg-surface-1 p-5">
      <p className="text-sm font-bold text-text-primary">EQUITY CURVE</p>
      <div className="mt-4 h-80 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={equity} margin={{ top: 8, right: 8, bottom: 0, left: 0 }}>
            <CartesianGrid stroke="var(--gridline)" vertical={false} />
            <XAxis dataKey="index" hide />
            <YAxis
              width={56}
              tick={{ fill: "var(--text-muted)", fontSize: 11 }}
              stroke="var(--axis)"
              tickLine={false}
              axisLine={false}
            />
            <Tooltip content={<EquityTooltip />} cursor={{ stroke: "var(--axis)" }} />
            <Line
              type="monotone"
              dataKey="balance"
              stroke="var(--series-1)"
              strokeWidth={2}
              dot={false}
              activeDot={{ r: 4 }}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
