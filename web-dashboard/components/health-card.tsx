import { fmtPercent } from "@/lib/format";

// Port dari lib/widgets/dashboard/health_card.dart. `status` sengaja
// hardcode "Normal" di app mobile (dashboard_page.dart tidak pernah
// menghitungnya dari growth/drawdown) — disamakan di sini biar konsisten,
// bukan bug yang saya lupa perbaiki.
const STATUS_COLOR: Record<string, string> = {
  excellent: "#22c55e",
  good: "#84cc16",
  normal: "#f97316",
  warning: "var(--status-critical)",
};

export function HealthCard({ growth, drawdown }: { growth: number; drawdown: number }) {
  const status = "Normal";
  const statusColor = STATUS_COLOR[status.toLowerCase()] ?? "var(--series-1)";
  const growthColor = growth >= 0 ? "var(--status-good)" : "var(--status-critical)";

  return (
    <div className="rounded-2xl border border-border bg-surface-1 p-5">
      <p className="text-center text-lg font-bold text-text-primary">ACCOUNT HEALTH</p>

      <div className="mt-5 flex justify-around">
        <HealthItem title="Growth" value={fmtPercent(growth)} color={growthColor} />
        <HealthItem title="Drawdown" value={fmtPercent(drawdown)} color="#f97316" />
      </div>

      <div className="mt-5 flex justify-center">
        <span
          className="rounded-full px-5 py-2 text-lg font-bold"
          style={{
            background: `color-mix(in srgb, ${statusColor} 20%, transparent)`,
            color: statusColor,
          }}
        >
          {status}
        </span>
      </div>
    </div>
  );
}

function HealthItem({ title, value, color }: { title: string; value: string; color: string }) {
  return (
    <div className="flex flex-col items-center gap-2">
      <div
        className="flex h-10 w-10 items-center justify-center rounded-full text-lg"
        style={{ background: `color-mix(in srgb, ${color} 12%, transparent)`, color }}
      >
        {title === "Growth" ? "↑" : "↓"}
      </div>
      <p className="text-sm text-text-secondary">{title}</p>
      <p className="text-lg font-bold" style={{ color }}>
        {value}
      </p>
    </div>
  );
}
