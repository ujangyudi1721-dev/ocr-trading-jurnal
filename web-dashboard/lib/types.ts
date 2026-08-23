// Bentuk baris mentah dari Supabase (lihat supabase/schema.sql di root repo).
// Semua field trade sengaja string (hasil OCR), persis seperti TradeModel
// di app Flutter (lib/models/trade_model.dart).

export interface TradeRow {
  id: string;
  ticket: string | null;
  pair: string | null;
  type: string | null;
  lot: string | null;
  profit: string | null;
  open_time: string | null;
  close_time: string | null;
  sl: string | null;
  tp: string | null;
  open_price: string | null;
  close_price: string | null;
  emotion: string | null;
}

export interface AccountTransactionRow {
  id: string;
  date: string | null;
  type: string | null; // "Deposit" | "Withdraw"
  amount: number | null;
  note: string | null;
}

export interface UserSettingsRow {
  max_loss_percent: number | null;
  profit_target_percent: number | null;
}

// Hasil gabungan trades + account_transactions, terurut lama->baru,
// dengan running balance — persis AccountTimelineModel di Flutter
// (lib/models/account_timeline_model.dart).
export type TimelineEventType = "Deposit" | "Withdraw" | "Trade";

export interface TimelineItem {
  date: Date;
  type: TimelineEventType;
  amount: number;
  balance: number;
  reference: string;
  pair?: string | null;
  tradeType?: string | null;
  emotion?: string | null;
}

export interface DrawdownResult {
  peakBalance: number;
  currentBalance: number;
  currentDrawdown: number;
  maximumDrawdown: number;
}

export interface RiskLimitResult {
  balance: number;
  maxLossPercent: number;
  profitTargetPercent: number;
  maxLossAmount: number;
  profitTargetAmount: number;
  lossLimitBalance: number;
  profitTargetBalance: number;
}

export interface EquityPoint {
  index: number;
  balance: number;
}

export interface PairStatistic {
  pair: string;
  totalTrade: number;
  profit: number;
  totalWin: number;
  totalLoss: number;
}

export interface EmotionStatistic {
  emotion: string;
  totalTrade: number;
  profit: number;
  totalWin: number;
  totalLoss: number;
}

export interface AnalyticsResult {
  totalTrade: number;
  totalWin: number;
  totalLoss: number;
  grossProfit: number;
  grossLoss: number;
  netProfit: number;
  winRate: number;
  averageWin: number;
  averageLoss: number;
  profitFactor: number;
  totalDeposit: number;
  totalWithdraw: number;
  currentBalance: number;
  growth: number;
  equity: EquityPoint[];
  pairPerformance: PairStatistic[];
  emotionPerformance: EmotionStatistic[];
  drawdown: DrawdownResult;
  riskLimit: RiskLimitResult;
}

export type ReportPeriod = "day" | "week" | "month";

export interface PeriodReport {
  /** Awal periode (00:00 hari itu / Senin minggu itu / tanggal 1 bulan itu). */
  periodStart: Date;
  label: string;
  openingBalance: number;
  closingBalance: number;
  profit: number;
  profitPercent: number;
  totalTrade: number;
  totalWin: number;
  totalLoss: number;
  deposit: number;
  withdraw: number;
}
