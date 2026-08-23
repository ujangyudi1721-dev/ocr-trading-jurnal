import { formatDateTime } from "@/lib/date-helper";
import { fmt } from "@/lib/format";
import { fetchTimeline } from "@/lib/supabase-server";
import type { TimelineItem } from "@/lib/types";

export const dynamic = "force-dynamic";

const TYPE_COLOR: Record<string, string> = {
  Deposit: "var(--status-good)",
  Withdraw: "#f97316",
  Trade: "var(--series-1)",
};

const TYPE_ICON: Record<string, string> = {
  Deposit: "＋",
  Withdraw: "－",
  Trade: "≈",
};

export default async function TimelinePage() {
  const timeline = await fetchTimeline();
  const reversed = [...timeline].reverse();

  return (
    <div>
      <h1 className="mb-4 text-lg font-semibold text-text-primary">Timeline</h1>

      <div className="grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-3">
        {reversed.length === 0 ? (
          <p className="col-span-full py-10 text-center text-sm text-text-muted">
            Belum ada data.
          </p>
        ) : (
          reversed.map((item, i) => <TimelineCard key={i} item={item} />)
        )}
      </div>
    </div>
  );
}

function TimelineCard({ item }: { item: TimelineItem }) {
  const color = TYPE_COLOR[item.type];
  const amountColor = item.amount >= 0 ? "var(--status-good)" : "var(--status-critical)";

  return (
    <div className="flex h-full flex-col rounded-2xl border border-border bg-surface-1 p-4">
      <div className="flex items-start justify-between gap-2">
        <div className="flex items-center gap-2.5">
          <span
            className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-sm font-bold text-white"
            style={{ background: color }}
          >
            {TYPE_ICON[item.type]}
          </span>
          <div>
            <p className="font-bold text-text-primary">{item.type}</p>
            <p className="text-xs text-text-muted">{formatDateTime(item.date)}</p>
          </div>
        </div>
        <span className="shrink-0 text-lg font-bold" style={{ color: amountColor }}>
          {item.amount >= 0 ? "+" : ""}
          {fmt(item.amount)}
        </span>
      </div>

      <div className="mt-3 grid grid-cols-2 gap-x-4 gap-y-1.5 border-t border-gridline pt-3 text-xs">
        <div>
          <p className="text-text-muted">Reference</p>
          <p className="truncate font-medium text-text-primary">{item.reference || "-"}</p>
        </div>
        <div>
          <p className="text-text-muted">Balance</p>
          <p className="font-medium text-text-primary">{fmt(item.balance)}</p>
        </div>
        {item.pair && (
          <div>
            <p className="text-text-muted">Pair</p>
            <p className="font-medium text-text-primary">{item.pair}</p>
          </div>
        )}
      </div>
    </div>
  );
}
