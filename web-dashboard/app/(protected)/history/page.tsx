import { HistoryList } from "@/components/history-list";
import { fetchTrades } from "@/lib/supabase-server";

export const dynamic = "force-dynamic";

export default async function HistoryPage() {
  const trades = await fetchTrades();

  return (
    <div>
      <h1 className="mb-4 text-lg font-semibold text-text-primary">History Trade</h1>
      <HistoryList trades={trades} />
    </div>
  );
}
