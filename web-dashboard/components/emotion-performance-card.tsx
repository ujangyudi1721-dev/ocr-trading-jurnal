import { findEmotion } from "@/lib/emotion-constants";
import { fmt } from "@/lib/format";
import type { EmotionStatistic } from "@/lib/types";

// Port dari lib/widgets/dashboard/emotion_performance_card.dart — di app
// mobile ini yang menjawab "emosi apa yang paling menguntungkan/merugikan
// saat entry", salah satu tujuan utama app ini (lihat memory project).
export function EmotionPerformanceCard({ emotions }: { emotions: EmotionStatistic[] }) {
  const maxAbs = Math.max(1, ...emotions.map((e) => Math.abs(e.profit)));

  return (
    <div className="rounded-2xl border border-border bg-surface-1 p-5">
      <p className="text-sm font-bold text-text-primary">PERFORMA PER EMOSI</p>

      {emotions.length === 0 ? (
        <p className="mt-6 text-center text-sm text-text-muted">
          Belum ada trade dengan tag emosi.
        </p>
      ) : (
        <div className="mt-4 flex flex-col gap-3">
          {emotions.map((e) => {
            const option = findEmotion(e.emotion);
            const isProfit = e.profit >= 0;
            const barColor = isProfit ? "var(--status-good)" : "var(--status-critical)";
            const widthPercent = (Math.abs(e.profit) / maxAbs) * 100;
            const winRate = e.totalTrade === 0 ? 0 : (e.totalWin / e.totalTrade) * 100;

            return (
              <div key={e.emotion}>
                <div className="flex items-baseline justify-between text-sm">
                  <span className="flex items-center gap-2 font-medium text-text-primary">
                    <span
                      className="inline-block h-2.5 w-2.5 rounded-full"
                      style={{ background: option?.color ?? "var(--text-muted)" }}
                    />
                    {option?.label ?? e.emotion}
                  </span>
                  <span className="text-text-muted">
                    {e.totalTrade} trade · {winRate.toFixed(0)}% win
                  </span>
                  <span className="font-bold" style={{ color: barColor }}>
                    {fmt(e.profit)}
                  </span>
                </div>
                <div className="mt-1 h-1.5 w-full rounded-full bg-gridline">
                  <div
                    className="h-1.5 rounded-full"
                    style={{ width: `${widthPercent}%`, background: barColor }}
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
