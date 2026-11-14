-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  Ronda Tahiro — إدراج البوتات في لوحة الترتيب العالمية               ║
-- ║  يُنفَّذ مرة واحدة في: Supabase → SQL Editor → New query → Run        ║
-- ╚══════════════════════════════════════════════════════════════════════╝
--
-- لماذا دالة تجميع ولماذا لا يكفي مسار اللاعبين الحالي:
--   صفّ اللاعب يملكه هاتف واحد، فيُرسل إجماليه ويُكتب كما هو.
--   أما صفّ البوت فيشترك فيه كل اللاعبين في العالم، وكل هاتف لا يعرف إلا
--   مبارياته هو. لو أرسل كل هاتف إجماليه المحلي لدهس ما كتبه غيره وتذبذب
--   الرقم صعوداً وهبوطاً. لذلك يرسل التطبيق الفارق المستجدّ فقط، وهذه
--   الدالة تجمعه على المخزون في عملية ذرّية واحدة.
--
-- ⚠️ نفّذ 00_players.sql قبل هذا الملف: هو الذي يُنشئ جدول public.players،
--    وهذا الملف يضيف إليه عمود is_bot ودالة التجميع. وتنفيذه على جدول
--    غير موجود يفشل بـ«relation public.players does not exist».

-- ── 1) عمود يميّز البوتات عن اللاعبين ───────────────────────────────────
alter table public.players
  add column if not exists is_bot boolean not null default false;

create index if not exists players_is_bot_idx on public.players (is_bot);

-- ── 2) دالة التجميع الذرّية ─────────────────────────────────────────────
-- تضيف الفارق d (jsonb) إلى الصفّ، وتُنشئه إن لم يكن موجوداً.
-- best_pts يأخذ الأكبر لا المجموع، لأنه رقم قياسي لا عدّاد.
create or replace function public.bump_bot_stats(
  p_id        text,
  p_name      text,
  p_av        text,
  p_best_pts  int,
  p_last_seen bigint,
  d           jsonb
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  f text;
  -- كل الحقول التراكمية التي يرسلها التطبيق
  fields text[] := array[
    'wins','losses','ties','games','total_pts',
    'wins_1v1','games_1v1','wins_2v2','games_2v2','wins_4p','games_4p',
    'wins_classic','games_classic','wins_escoba','games_escoba',
    'wins_quick','games_quick',
    'total_missas','total_bumbas','total_rondas','total_tringas'
  ];
begin
  if p_id is null or p_id !~ '^bot_' then
    raise exception 'bump_bot_stats: المعرّف يجب أن يبدأ بـ bot_';
  end if;

  -- أنشئ الصفّ إن لم يكن موجوداً (بأصفار) ثم اجمع عليه
  insert into public.players (id, name, av, is_bot, best_pts, last_seen)
  values (p_id, coalesce(p_name,''), coalesce(p_av,'🤖'), true,
          coalesce(p_best_pts,0), coalesce(p_last_seen,0))
  on conflict (id) do nothing;

  -- اجمع كل حقل تراكمي ورد في d.
  -- نتخطّى أي عمود غير موجود في جدولك بدل أن تفشل الدالة كلها، فمخطّطات
  -- الجداول تختلف وقد لا تكون كل العدّادات مُعرَّفة عندك.
  foreach f in array fields loop
    if (d ? f) and exists (
      select 1 from information_schema.columns
       where table_schema = 'public' and table_name = 'players' and column_name = f
    ) then
      execute format(
        'update public.players set %I = coalesce(%I,0) + $1 where id = $2',
        f, f
      ) using greatest(0, coalesce((d->>f)::int, 0)), p_id;
    end if;
  end loop;

  -- الحقول غير التراكمية
  update public.players
     set name      = coalesce(nullif(p_name,''), name),
         av        = coalesce(nullif(p_av,''),   av),
         is_bot    = true,
         best_pts  = greatest(coalesce(best_pts,0),  coalesce(p_best_pts,0)),
         last_seen = greatest(coalesce(last_seen,0), coalesce(p_last_seen,0))
   where id = p_id;
end;
$$;

-- ── 3) الصلاحيات ───────────────────────────────────────────────────────
-- الدالة security definer وتُنادى من Edge Function بمفتاح service_role،
-- فلا نمنح anon حق النداء المباشر (حتى لا يُنفخ رقم بوت من خارج التطبيق).
revoke all on function public.bump_bot_stats(text,text,text,int,bigint,jsonb) from public, anon, authenticated;

-- ── 4) قراءة الترتيب تشمل البوتات ──────────────────────────────────────
-- دالة functions/get-leaderboard في هذا المشروع لا ترشّح البوتات بأي شرط،
-- فتظهر بمجرّد تسجيلها. ولو استبدلتها لاحقاً بنسخة من عندك، فاحذر أن
-- تضيف فيها .eq('is_bot', false) أو id not like 'bot_%' وإلا اختفت.
