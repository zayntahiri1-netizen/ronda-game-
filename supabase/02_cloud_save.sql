-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  Ronda Tahiro — الحفظ السحابي لتقدّم اللاعب                          ║
-- ║  يُنفَّذ مرة واحدة: Supabase → SQL Editor → New query → Run           ║
-- ║  يتطلّب أن يكون الدخول بحساب Google مفعَّلاً (GOOGLE_AUTH.md)        ║
-- ╚══════════════════════════════════════════════════════════════════════╝
--
-- صفّ واحد لكل مستخدم، يحمل تقدّمه كاملاً في عمود jsonb:
-- الذهب والجواهر والمستوى والخبرة والإحصائيات والتحديات والإنجازات.
-- الحجم النموذجي 2–5 كيلوبايت، فـ500 ميغابايت في الخطة المجانية تكفي
-- لأكثر من مئة ألف لاعب.

create table if not exists public.player_saves (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb       not null default '{}'::jsonb,
  games      int         not null default 0,   -- عدّاد تصاعدي لحسم التعارض
  updated_at timestamptz not null default now()
);

create index if not exists player_saves_updated_idx on public.player_saves (updated_at desc);

-- ── أمن الصفوف: كل لاعب يرى صفّه وحده ولا يمسّ صفّ غيره ───────────────
-- هذا ضروري: المفتاح anon مضمَّن في التطبيق، فبدون هذه السياسات يستطيع
-- أي شخص قراءة تقدّم كل اللاعبين أو تعديله.
alter table public.player_saves enable row level security;

drop policy if exists "own save read"   on public.player_saves;
drop policy if exists "own save insert" on public.player_saves;
drop policy if exists "own save update" on public.player_saves;

create policy "own save read"
  on public.player_saves for select
  using (auth.uid() = user_id);

create policy "own save insert"
  on public.player_saves for insert
  with check (auth.uid() = user_id);

create policy "own save update"
  on public.player_saves for update
  using      (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ── تحديث الطابع الزمني تلقائياً ──────────────────────────────────────
create or replace function public.touch_player_save()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end; $$;

drop trigger if exists player_saves_touch on public.player_saves;
create trigger player_saves_touch
  before update on public.player_saves
  for each row execute function public.touch_player_save();
