import { fmt } from "@/lib/format";
import type { PairStatistic } from "@/lib/types";

// Port dari lib/widgets/dashboard/pair_performance_card.dart. Bar horizontal
// panjangnya proporsional terhadap |profit| pair paling besar, warna
// status good/critical (bukan biru kategorikal) karena ini menandai
// polaritas untung/rugi, bukan identitas kategori.
export function PairPerformanceCard({ pairs }: { pairs: PairStatistic[] }) {
  const maxAbs = Math.max(1, ...pairs.map((p) => Math.abs(p.profit)));

  return (
    <div className="rounded-2xl border border-border bg-surface-1 p-5">
      <p className="text-sm font-bold text-text-primary">PERFORMA PER PAIR</p>

      {pairs.length === 0 ? (
        <p className="mt-6 text-center text-sm text-text-muted">Belum ada data.</p>
      ) : (
        <div className="mt-4 flex flex-col gap-3">
          {pairs.map((p) => {
            const isProfit = p.profit >= 0;
            const color = isProfit ? "var(--status-good)" : "var(--status-critical)";
            const widthPercent = (Math.abs(p.profit) / maxAbs) * 100;

            return (
              <div key={p.pair}>
                <div className="flex items-baseline justify-between text-sm">
                  <span className="font-medium text-text-primary">{p.pair}</span>
                  <span className="text-text-muted">
                    {p.totalTrade} trade · {p.totalWin}W/{p.totalLoss}L
                  </span>
                  <span className="font-bold" style={{ color }}>
                    {fmt(p.profit)}
                  </span>
                </div>
                <div className="mt-1 h-1.5 w-full rounded-full bg-gridline">
                  <div
                    className="h-1.5 rounded-full"
                    style={{ width: `${widthPercent}%`, background: color }}
                  />
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
