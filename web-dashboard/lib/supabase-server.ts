import "server-only";

import { createClient } from "@supabase/supabase-js";
import { generateTimeline } from "./account-timeline";
import type {
  AccountTransactionRow,
  TimelineItem,
  TradeRow,
  UserSettingsRow,
} from "./types";

// Service role key bypasses RLS — only ever imported from Server
// Components / Server Actions (the `server-only` import above makes any
// accidental import from a Client Component a build-time error). Filtered
// manually by TRADING_USER_ID on every query since RLS isn't enforced for
// this key.
function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(
      `${name} kosong. Isi web-dashboard/.env.local (lihat .env.example).`,
    );
  }
  return value;
}

function getClient() {
  const url = requireEnv("SUPABASE_URL");
  const serviceRoleKey = requireEnv("SUPABASE_SERVICE_ROLE_KEY");
  return createClient(url, serviceRoleKey, {
    auth: { persistSession: false },
  });
}

function getUserId(): string {
  return requireEnv("TRADING_USER_ID");
}

export async function fetchTrades(): Promise<TradeRow[]> {
  const { data, error } = await getClient()
    .from("trades")
    .select(
      "id, ticket, pair, type, lot, profit, open_time, close_time, sl, tp, open_price, close_price, emotion",
    )
    .eq("user_id", getUserId());

  if (error) throw new Error(`Gagal ambil data trades: ${error.message}`);
  return data ?? [];
}

export async function fetchAccountTransactions(): Promise<AccountTransactionRow[]> {
  const { data, error } = await getClient()
    .from("account_transactions")
    .select("id, date, type, amount, note")
    .eq("user_id", getUserId());

  if (error) {
    throw new Error(`Gagal ambil data account_transactions: ${error.message}`);
  }
  return data ?? [];
}

export async function fetchUserSettings(): Promise<UserSettingsRow | null> {
  const { data, error } = await getClient()
    .from("user_settings")
    .select("max_loss_percent, profit_target_percent")
    .eq("user_id", getUserId())
    .maybeSingle();

  if (error) throw new Error(`Gagal ambil user_settings: ${error.message}`);
  return data;
}

/** Ambil & gabungkan seluruh data jadi satu timeline siap pakai. */
export async function fetchTimeline(): Promise<TimelineItem[]> {
  const [trades, transactions] = await Promise.all([
    fetchTrades(),
    fetchAccountTransactions(),
  ]);
  return generateTimeline(transactions, trades);
}
