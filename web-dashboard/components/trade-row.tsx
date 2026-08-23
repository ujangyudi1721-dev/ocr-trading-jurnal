import { formatDateTime, parseDate } from "@/lib/date-helper";
import { findEmotion } from "@/lib/emotion-constants";
import type { TradeRow } from "@/lib/types";

export function TradeRowItem({ trade }: { trade: TradeRow }) {
  const isBuy = (trade.type ?? "").toUpperCase() === "BUY";
  const typeColor = isBuy ? "var(--status-good)" : "var(--status-critical)";
  const profitValue = Number.parseFloat((trade.profit ?? "0").replaceAll("+", ""));
  const isProfit = !Number.isNaN(profitValue) && profitValue >= 0;
  const profitColor = isProfit ? "var(--status-good)" : "var(--status-critical)";
  const closeDate = trade.close_time ? parseDate(trade.close_time) : null;
  const emotion = findEmotion(trade.emotion);

  return (
    <div className="flex h-full flex-col rounded-2xl border border-border bg-surface-1 p-4">
      <div className="flex items-start justify-between gap-2">
        <div className="flex items-center gap-2">
          <span className="text-base font-bold text-text-primary">{trade.pair}</span>
          <span
            className="rounded px-1.5 py-0.5 text-[11px] font-bold"
            style={{
              background: `color-mix(in srgb, ${typeColor} 15%, transparent)`,
              color: typeColor,
            }}
          >
            {trade.type}
          </span>
        </div>
        <span className="text-lg font-bold" style={{ color: profitColor }}>
          {trade.profit}
        </span>
      </div>

      <p className="mt-1 text-xs text-text-muted">
        #{trade.ticket}
        {closeDate && ` · ${formatDateTime(closeDate)}`}
      </p>

      <div className="mt-3 grid grid-cols-2 gap-x-4 gap-y-1.5 border-t border-gridline pt-3 text-xs">
        <InfoField label="Lot" value={trade.lot} />
        <InfoField label="Open" value={trade.open_price} />
        <InfoField label="SL" value={trade.sl} />
        <InfoField label="TP" value={trade.tp} />
      </div>

      {emotion && (
        <div className="mt-3 flex items-center gap-1.5 border-t border-gridline pt-3">
          <span
            className="inline-block h-2 w-2 rounded-full"
            style={{ background: emotion.color }}
          />
          <span className="text-xs text-text-secondary">{emotion.label}</span>
        </div>
      )}
    </div>
  );
}

function InfoField({ label, value }: { label: string; value: string | null }) {
  return (
    <div>
      <p className="text-text-muted">{label}</p>
      <p className="font-medium text-text-primary">{value || "-"}</p>
    </div>
  );
}
