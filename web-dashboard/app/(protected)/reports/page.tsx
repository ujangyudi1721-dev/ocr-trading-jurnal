import { PeriodReportTabs } from "@/components/period-report-tabs";
import { generatePeriodReport } from "@/lib/period-report";
import { fetchTimeline } from "@/lib/supabase-server";
import type { PeriodReport, ReportPeriod } from "@/lib/types";

export const dynamic = "force-dynamic";

export default async function ReportsPage() {
  const timeline = await fetchTimeline();

  const reports: Record<ReportPeriod, PeriodReport[]> = {
    day: generatePeriodReport(timeline, "day"),
    week: generatePeriodReport(timeline, "week"),
    month: generatePeriodReport(timeline, "month"),
  };

  return (
    <div>
      <h1 className="mb-4 text-lg font-semibold text-text-primary">Laporan</h1>
      <PeriodReportTabs reports={reports} />
    </div>
  );
}
