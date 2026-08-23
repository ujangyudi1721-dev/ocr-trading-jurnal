import { calculateAnalytics } from "@/lib/analytics-engine";
import { fetchTimeline, fetchUserSettings } from "@/lib/supabase-server";
import { BalanceCard } from "@/components/balance-card";
import { EmotionPerformanceCard } from "@/components/emotion-performance-card";
import { EquityChart } from "@/components/equity-chart";
import { HealthCard } from "@/components/health-card";
import { PairPerformanceCard } from "@/components/pair-performance-card";
import { RiskLimitCard } from "@/components/risk-limit-card";
import { StatisticGrid } from "@/components/statistic-grid";

// Data trading berubah dari app mobile kapan saja — jangan cache statis,
// selalu ambil data terbaru tiap kali halaman ini dibuka.
export const dynamic = "force-dynamic";

export default async function DashboardPage() {
  const [timeline, settings] = await Promise.all([fetchTimeline(), fetchUserSettings()]);

  const analytics = calculateAnalytics(
    timeline,
    settings?.max_loss_percent ?? 2,
    settings?.profit_target_percent ?? 3,
  );

  const drawdownPercent =
    analytics.drawdown.peakBalance <= 0
      ? 0
      : (analytics.drawdown.currentDrawdown / analytics.drawdown.peakBalance) * 100;

  return (
    <div className="flex flex-col gap-5">
      <div className="grid grid-cols-1 items-start gap-4 lg:grid-cols-3">
        <BalanceCard balance={analytics.currentBalance} netProfit={analytics.netProfit} />
        <RiskLimitCard riskLimit={analytics.riskLimit} />
        <HealthCard growth={analytics.growth} drawdown={drawdownPercent} />
      </div>

      <StatisticGrid analytics={analytics} />

      <EquityChart equity={analytics.equity} />

      <div className="grid grid-cols-1 items-start gap-4 lg:grid-cols-2">
        <PairPerformanceCard pairs={analytics.pairPerformance} />
        <EmotionPerformanceCard emotions={analytics.emotionPerformance} />
      </div>
    </div>
  );
}
