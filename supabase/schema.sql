-- ocr_trading_jurnal — Supabase schema
-- Jalankan file ini sekali di SQL Editor project Supabase Anda.
-- Aman dijalankan ulang (idempotent) berkat IF NOT EXISTS / CREATE OR REPLACE.

-- ==========================================
-- TRIGGER FUNCTION: server-authoritative updated_at
-- ==========================================
-- updated_at di-set oleh server (bukan dikirim dari client) supaya
-- perbandingan last-write-wins saat sync tidak bergantung pada jam device
-- yang bisa salah/skew.
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- ==========================================
-- TABLE: trades
-- ==========================================
create table if not exists public.trades (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  ticket text,
  pair text,
  type text,
  lot text,
  profit text,
  open_time text,
  close_time text,
  sl text,
  tp text,
  open_price text,
  close_price text,
  emotion text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

alter table public.trades enable row level security;

drop policy if exists "trades_select_own" on public.trades;
create policy "trades_select_own" on public.trades
  for select using (auth.uid() = user_id);

drop policy if exists "trades_insert_own" on public.trades;
create policy "trades_insert_own" on public.trades
  for insert with check (auth.uid() = user_id);

drop policy if exists "trades_update_own" on public.trades;
create policy "trades_update_own" on public.trades
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "trades_delete_own" on public.trades;
create policy "trades_delete_own" on public.trades
  for delete using (auth.uid() = user_id);

drop trigger if exists trg_trades_updated_at on public.trades;
create trigger trg_trades_updated_at
  before update on public.trades
  for each row execute function set_updated_at();

create index if not exists idx_trades_user_updated
  on public.trades (user_id, updated_at);

-- ==========================================
-- TABLE: account_transactions
-- ==========================================
create table if not exists public.account_transactions (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  date text,
  type text,
  amount numeric,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

alter table public.account_transactions enable row level security;

drop policy if exists "account_transactions_select_own" on public.account_transactions;
create policy "account_transactions_select_own" on public.account_transactions
  for select using (auth.uid() = user_id);

drop policy if exists "account_transactions_insert_own" on public.account_transactions;
create policy "account_transactions_insert_own" on public.account_transactions
  for insert with check (auth.uid() = user_id);

drop policy if exists "account_transactions_update_own" on public.account_transactions;
create policy "account_transactions_update_own" on public.account_transactions
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "account_transactions_delete_own" on public.account_transactions;
create policy "account_transactions_delete_own" on public.account_transactions
  for delete using (auth.uid() = user_id);

drop trigger if exists trg_account_transactions_updated_at on public.account_transactions;
create trigger trg_account_transactions_updated_at
  before update on public.account_transactions
  for each row execute function set_updated_at();

create index if not exists idx_account_transactions_user_updated
  on public.account_transactions (user_id, updated_at);

-- ==========================================
-- TABLE: user_settings
-- ==========================================
create table if not exists public.user_settings (
  user_id uuid primary key references auth.users (id) on delete cascade,
  max_loss_percent numeric,
  profit_target_percent numeric,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.user_settings enable row level security;

drop policy if exists "user_settings_select_own" on public.user_settings;
create policy "user_settings_select_own" on public.user_settings
  for select using (auth.uid() = user_id);

drop policy if exists "user_settings_insert_own" on public.user_settings;
create policy "user_settings_insert_own" on public.user_settings
  for insert with check (auth.uid() = user_id);

drop policy if exists "user_settings_update_own" on public.user_settings;
create policy "user_settings_update_own" on public.user_settings
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop trigger if exists trg_user_settings_updated_at on public.user_settings;
create trigger trg_user_settings_updated_at
  before update on public.user_settings
  for each row execute function set_updated_at();

create index if not exists idx_user_settings_user_updated
  on public.user_settings (user_id, updated_at);
