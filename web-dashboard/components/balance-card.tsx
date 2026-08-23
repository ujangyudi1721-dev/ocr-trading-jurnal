import { fmt } from "@/lib/format";

// Port tampilan dari lib/widgets/dashboard/balance_card.dart (gradient
// ungu-biru, angka besar di tengah).
export function BalanceCard({
  balance,
  netProfit,
}: {
  balance: number;
  netProfit: number;
}) {
  const isProfit = netProfit >= 0;

  return (
    <div
      className="rounded-2xl p-5 shadow-lg"
      style={{
        background: "linear-gradient(135deg, #4A00E0 0%, #2979FF 100%)",
        boxShadow: "0 8px 16px rgba(41,121,255,0.35)",
      }}
    >
      <p className="text-center text-sm font-bold tracking-wide text-white/70">BALANCE</p>
      <p className="mt-3 text-center text-4xl font-bold text-white">{fmt(balance)}</p>
      <div className="mt-4 flex justify-center">
        <span
          className="inline-flex items-center gap-1.5 rounded-full px-3.5 py-1.5 text-sm font-bold"
          style={{
            background: "rgba(255,255,255,0.15)",
            color: isProfit ? "#69f0ae" : "#ff8a80",
          }}
        >
          {isProfit ? "▲" : "▼"} Net Profit : {fmt(netProfit)}
        </span>
      </div>
    </div>
  );
}
