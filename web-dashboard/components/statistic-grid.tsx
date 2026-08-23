import Link from "next/link";
import { fmt, fmtPercent } from "@/lib/format";
import type { AnalyticsResult } from "@/lib/types";

// Port dari lib/widgets/dashboard/statistic_grid.dart.
export function StatisticGrid({ analytics }: { analytics: AnalyticsResult }) {
  const tiles = [
    { title: "Total Trade", value: String(analytics.totalTrade), color: "#4f46e5", href: "/history" },
    { title: "Win Rate", value: fmtPercent(analytics.winRate), color: "#a855f7" },
    { title: "Total Win", value: String(analytics.totalWin), color: "var(--status-good)", href: "/history" },
    { title: "Total Loss", value: String(analytics.totalLoss), color: "var(--status-critical)", href: "/history" },
    { title: "Gross Profit", value: fmt(analytics.grossProfit), color: "#14b8a6" },
    { title: "Gross Loss", value: fmt(analytics.grossLoss), color: "#ea580c" },
    { title: "Deposit", value: fmt(analytics.totalDeposit), color: "var(--series-1)" },
    { title: "Withdraw", value: fmt(analytics.totalWithdraw), color: "#b45309" },
  ];

  return (
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
      {tiles.map((tile) => {
        const content = (
          <div className="flex h-full flex-col justify-between rounded-xl border border-border bg-surface-1 p-4">
            <p className="text-xs text-text-secondary">{tile.title}</p>
            <p className="mt-2 text-xl font-bold" style={{ color: tile.color }}>
              {tile.value}
            </p>
          </div>
        );

        return tile.href ? (
          <Link key={tile.title} href={tile.href} className="block hover:opacity-80">
            {content}
          </Link>
        ) : (
          <div key={tile.title}>{content}</div>
        );
      })}
    </div>
  );
}
