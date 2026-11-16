-- MyFinance: pemisahan saldo Cash, SeaBank, Mandiri, Superbank
-- Jalankan SEKALI di Supabase > SQL Editor. Tidak menghapus transaksi lama.
create table if not exists public.wallets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  kind text not null check (kind in ('cash','bank')),
  opening_balance numeric(14,2) not null default 0 check (opening_balance >= 0),
  created_at timestamptz not null default now(),
  unique(user_id,name)
);

alter table public.transactions
  add column if not exists wallet_id uuid references public.wallets(id) on delete set null,
  add column if not exists wallet_name text not null default 'Transaksi lama';

alter table public.wallets enable row level security;
drop policy if exists "Users manage own wallets" on public.wallets;
create policy "Users manage own wallets" on public.wallets
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
grant select, insert, update, delete on public.wallets to authenticated;
create index if not exists wallets_user_idx on public.wallets(user_id);
create index if not exists transactions_wallet_idx on public.transactions(wallet_id);
