-- MYFINANCE 2.0 — Jalankan seluruh SQL ini di Supabase > SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  type text not null check (type in ('income','expense')),
  color text not null default '#6da987',
  created_at timestamptz not null default now(),
  unique(user_id,name,type)
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  description text not null,
  type text not null check (type in ('income','expense')),
  amount numeric(14,2) not null check (amount > 0),
  category_id uuid references public.categories(id) on delete set null,
  category_name text not null default 'Lainnya',
  transaction_date date not null default current_date,
  created_at timestamptz not null default now()
);

create table if not exists public.budgets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_name text not null,
  month date not null,
  amount numeric(14,2) not null check (amount > 0),
  created_at timestamptz not null default now(),
  unique(user_id,category_name,month)
);

create table if not exists public.savings_goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  target_amount numeric(14,2) not null check (target_amount > 0),
  current_amount numeric(14,2) not null default 0 check (current_amount >= 0),
  target_date date,
  note text,
  created_at timestamptz not null default now()
);

create table if not exists public.debts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  person text not null,
  description text not null,
  direction text not null check (direction in ('payable','receivable')),
  total_amount numeric(14,2) not null check (total_amount > 0),
  paid_amount numeric(14,2) not null default 0 check (paid_amount >= 0),
  due_date date,
  note text,
  created_at timestamptz not null default now(),
  check (paid_amount <= total_amount)
);

create table if not exists public.bills (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  amount numeric(14,2) not null check (amount > 0),
  due_date date not null,
  is_paid boolean not null default false,
  repeat_monthly boolean not null default false,
  note text,
  created_at timestamptz not null default now()
);

-- Aktifkan RLS dan kebijakan kepemilikan pada setiap tabel.
do $$
declare t text;
begin
  foreach t in array array['categories','transactions','budgets','savings_goals','debts','bills']
  loop
    execute format('alter table public.%I enable row level security',t);
    execute format('drop policy if exists %I on public.%I','Users manage own ' || t,t);
    execute format('create policy %I on public.%I for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id)','Users manage own ' || t,t);
    execute format('grant select, insert, update, delete on public.%I to authenticated',t);
  end loop;
end $$;

-- Index agar pencarian dan ringkasan tanggal lebih cepat.
create index if not exists transactions_user_date_idx on public.transactions(user_id,transaction_date desc);
create index if not exists budgets_user_month_idx on public.budgets(user_id,month);
create index if not exists bills_user_due_idx on public.bills(user_id,due_date);
create index if not exists debts_user_due_idx on public.debts(user_id,due_date);

-- Kategori default dibuat oleh aplikasi setelah akun pertama kali masuk.
