import { fmt } from "@/lib/format";
import type { RiskLimitResult } from "@/lib/types";

// Port dari lib/widgets/dashboard/risk_limit_card.dart.
export function RiskLimitCard({ riskLimit }: { riskLimit: RiskLimitResult }) {
  return (
    <div className="rounded-2xl border border-border bg-surface-1 p-5">
      <p className="text-center text-lg font-bold text-text-primary">RISK MANAGEMENT</p>

      <div className="mt-5 grid grid-cols-2 gap-3">
        <RiskPanel
          color="var(--status-critical)"
          label="MAX LOSS"
          percent={riskLimit.maxLossPercent}
          amount={riskLimit.maxLossAmount}
          balanceLabel="Batas balance"
          balance={riskLimit.lossLimitBalance}
        />
        <RiskPanel
          color="var(--status-good)"
          label="PROFIT TARGET"
          percent={riskLimit.profitTargetPercent}
          amount={riskLimit.profitTargetAmount}
          balanceLabel="Target balance"
          balance={riskLimit.profitTargetBalance}
        />
      </div>
    </div>
  );
}

function RiskPanel({
  color,
  label,
  percent,
  amount,
  balanceLabel,
  balance,
}: {
  color: string;
  label: string;
  percent: number;
  amount: number;
  balanceLabel: string;
  balance: number;
}) {
  return (
    <div
      className="rounded-xl p-3"
      style={{ background: `color-mix(in srgb, ${color} 8%, transparent)`, border: `1px solid color-mix(in srgb, ${color} 25%, transparent)` }}
    >
      <p className="text-sm font-bold" style={{ color }}>
        {label}
      </p>
      <p className="mt-2 text-2xl font-bold" style={{ color }}>
        {percent.toFixed(0)}%
      </p>
      <p className="text-sm" style={{ color }}>
        {fmt(amount)}
      </p>
      <p className="mt-2 text-xs text-text-muted">
        {balanceLabel}: {fmt(balance)}
      </p>
    </div>
  );
}
