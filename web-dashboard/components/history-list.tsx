"use client";

import { useMemo, useState } from "react";
import { parseDate } from "@/lib/date-helper";
import type { TradeRow } from "@/lib/types";
import { TradeRowItem } from "./trade-row";

// Port perilaku dari lib/pages/history_page.dart: urut terbaru->lama,
// filter rentang tanggal berdasarkan close_time. Data sudah di-fetch
// lengkap di server (Server Component induk) — filter di sini murni
// client-side, tidak ada request tambahan.
export function HistoryList({ trades }: { trades: TradeRow[] }) {
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");

  const sorted = useMemo(() => {
    return [...trades].sort((a, b) => {
      const da = a.close_time ? parseDate(a.close_time)?.getTime() ?? 0 : 0;
      const db = b.close_time ? parseDate(b.close_time)?.getTime() ?? 0 : 0;
      return db - da;
    });
  }, [trades]);

  const filtered = useMemo(() => {
    if (!startDate && !endDate) return sorted;

    const start = startDate ? new Date(`${startDate}T00:00:00`) : null;
    const end = endDate ? new Date(`${endDate}T23:59:59`) : null;

    return sorted.filter((t) => {
      const date = t.close_time ? parseDate(t.close_time) : null;
      if (!date) return false;
      if (start && date < start) return false;
      if (end && date > end) return false;
      return true;
    });
  }, [sorted, startDate, endDate]);

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-wrap items-end gap-3">
        <label className="flex flex-col text-sm text-text-secondary">
          Dari
          <input
            type="date"
            value={startDate}
            onChange={(e) => setStartDate(e.target.value)}
            className="mt-1 rounded-lg border border-border bg-transparent px-2 py-1.5 text-text-primary"
          />
        </label>
        <label className="flex flex-col text-sm text-text-secondary">
          Sampai
          <input
            type="date"
            value={endDate}
            onChange={(e) => setEndDate(e.target.value)}
            className="mt-1 rounded-lg border border-border bg-transparent px-2 py-1.5 text-text-primary"
          />
        </label>
        {(startDate || endDate) && (
          <button
            type="button"
            onClick={() => {
              setStartDate("");
              setEndDate("");
            }}
            className="rounded-lg px-3 py-1.5 text-sm text-text-secondary hover:bg-gridline"
          >
            Reset filter
          </button>
        )}
        <span className="text-sm text-text-muted">{filtered.length} trade</span>
      </div>

      <div className="grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-3">
        {filtered.length === 0 ? (
          <p className="col-span-full py-10 text-center text-sm text-text-muted">
            Belum ada data.
          </p>
        ) : (
          filtered.map((trade) => <TradeRowItem key={trade.id} trade={trade} />)
        )}
      </div>
    </div>
  );
}
