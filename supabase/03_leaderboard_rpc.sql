-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  Ronda Tahiro — الدوال الخمس التي ينقصها الترتيب العالمي             ║
-- ║  يُنفَّذ مرّة واحدة: Supabase → SQL Editor → New query → الصق → Run   ║
-- ╚══════════════════════════════════════════════════════════════════════╝
--
-- التشخيص الذي أدّى إلى هذا الملفّ:
--   جداولك موجودة كلّها (leaderboard, players, season_stats, seasons)،
--   ودوالك على Edge Functions منشورة كلّها (update-stats, get-leaderboard,
--   update-bot-stats). لكن الدوال الخمس التي تناديها داخل قاعدة البيانات
--   لم تكن موجودة أصلاً:
--
--     upsert_leaderboard   ← تناديها update-stats    (الكتابة)
--     upsert_player        ← تناديها update-stats
--     upsert_season_stats  ← تناديها update-stats
--     get_leaderboard      ← تناديها get-leaderboard (القراءة)
--     get_player_rank      ← تناديها get-leaderboard
--
--   فكانت السلسلة مقطوعة من طرفيها: لا كتابة ولا قراءة. والجدول
--   leaderboard بقي صِفر صفّ، فيعرض التطبيق ما عنده محلياً.
--
--   ولم يظهر خطأ قطّ لأن get-leaderboard تبتلع فشل النداء:
--     const rows = rowsRes.ok ? await rowsRes.json() : [];
--   فتُجيب «ok:true, rows:[]» — أي «نجحتُ ولا أحد هنا» وهي معطَّلة.
--
-- الملفّ آمن للتكرار: كلّه create or replace و add column if not exists،
-- ولا يحذف صفّاً ولا عموداً. وجدول players فيه 68 صفّاً — لا يُمسّ منها
-- شيء، ولا تُلمَس أعمدة gold و gems و level إطلاقاً.
--
-- وفي آخره اختبار ذاتيّ: يكتب صفّاً تجريبياً ويقرأه ثم يحذفه. فإن طُبع
-- «نجح كل شيء» فالمسار كامل من طرفه إلى طرفه. وإن فشل شيء رأيتَه فوراً
-- بدل أن يختفي بصمت كما كان.

-- ══ 1) عمودان ناقصان في leaderboard ══════════════════════════════════
-- التطبيق يقرأ r.av لعرض صورة اللاعب، و update-stats ترسل av و streak —
-- ولا عمود لهما في جدولك (فيه photo و best_streak فقط). فبدونهما تظهر
-- القائمة بلا صور، وتضيع السلسلة الجارية. الإضافة لا تمسّ أي صفّ قائم.
alter table public.leaderboard
  add column if not exists av     text    not null default '👤',
  add column if not exists streak integer not null default 0;

-- ══ 2) الكتابة: upsert_leaderboard ═══════════════════════════════════
-- تُنادى من update-stats بـ{ p_data: {...} }.
--
-- لماذا «تحديث ثم إدراج» ولا on conflict:
--   on conflict يحتاج قيداً فريداً على العمود، وأنا لا أعرف قيود جدولك.
--   هذا الأسلوب يعمل مهما كانت بنية مفاتيحك، ويلتقط تسابق نداءين.
--
-- ولماذا greatest ولا نكتب ما يصل كما هو:
--   العدّادات لا تنقص بطبيعتها. ولو كُتب ما يصل كما هو لمُحي تاريخ اللاعب
--   من الترتيب بمجرّد إعادة تنصيب التطبيق: الهاتف الجديد يبدأ بأصفار
--   فيرسلها، فتُكتب فوق سنوات من اللعب.
--   ويُستثنى streak — سلسلة جارية تنكسر بالخسارة فتُكتب كما تصل —
--   والاسم والصورة، فيغيّرهما اللاعب متى شاء.
create or replace function public.upsert_leaderboard(p_data jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id  text := nullif(p_data->>'id','');
  v_n   integer;
  v_try integer := 0;
  g     integer := greatest(coalesce((p_data->>'games')::int, 0), 0);
begin
  if v_id is null then
    raise exception 'upsert_leaderboard: معرّف اللاعب مفقود';
  end if;

  loop
    v_try := v_try + 1;

    update public.leaderboard set
      name          = coalesce(nullif(p_data->>'name',''), name),
      av            = coalesce(nullif(p_data->>'av',''),   av),
      wins          = greatest(coalesce(wins,0),          coalesce((p_data->>'wins')::int,0)),
      losses        = greatest(coalesce(losses,0),        coalesce((p_data->>'losses')::int,0)),
      ties          = greatest(coalesce(ties,0),          coalesce((p_data->>'ties')::int,0)),
      games         = greatest(coalesce(games,0),         g),
      total_games   = greatest(coalesce(total_games,0),   g),
      total_pts     = greatest(coalesce(total_pts,0),     coalesce((p_data->>'total_pts')::int,0)),
      best_pts      = greatest(coalesce(best_pts,0),      coalesce((p_data->>'best_pts')::int,0)),
      streak        = coalesce((p_data->>'streak')::int, 0),
      best_streak   = greatest(coalesce(best_streak,0),   coalesce((p_data->>'best_streak')::int,0)),
      wins_1v1      = greatest(coalesce(wins_1v1,0),      coalesce((p_data->>'wins_1v1')::int,0)),
      games_1v1     = greatest(coalesce(games_1v1,0),     coalesce((p_data->>'games_1v1')::int,0)),
      wins_2v2      = greatest(coalesce(wins_2v2,0),      coalesce((p_data->>'wins_2v2')::int,0)),
      games_2v2     = greatest(coalesce(games_2v2,0),     coalesce((p_data->>'games_2v2')::int,0)),
      wins_4p       = greatest(coalesce(wins_4p,0),       coalesce((p_data->>'wins_4p')::int,0)),
      games_4p      = greatest(coalesce(games_4p,0),      coalesce((p_data->>'games_4p')::int,0)),
      wins_classic  = greatest(coalesce(wins_classic,0),  coalesce((p_data->>'wins_classic')::int,0)),
      games_classic = greatest(coalesce(games_classic,0), coalesce((p_data->>'games_classic')::int,0)),
      wins_escoba   = greatest(coalesce(wins_escoba,0),   coalesce((p_data->>'wins_escoba')::int,0)),
      games_escoba  = greatest(coalesce(games_escoba,0),  coalesce((p_data->>'games_escoba')::int,0)),
      wins_quick    = greatest(coalesce(wins_quick,0),    coalesce((p_data->>'wins_quick')::int,0)),
      games_quick   = greatest(coalesce(games_quick,0),   coalesce((p_data->>'games_quick')::int,0)),
      total_missas  = greatest(coalesce(total_missas,0),  coalesce((p_data->>'total_missas')::int,0)),
      total_bumbas  = greatest(coalesce(total_bumbas,0),  coalesce((p_data->>'total_bumbas')::int,0)),
      total_rondas  = greatest(coalesce(total_rondas,0),  coalesce((p_data->>'total_rondas')::int,0)),
      total_tringas = greatest(coalesce(total_tringas,0), coalesce((p_data->>'total_tringas')::int,0)),
      last_seen     = greatest(coalesce(last_seen,0),     coalesce((p_data->>'last_seen')::bigint,0)),
      last_update   = now(),
      updated_at    = now()
    where id = v_id;

    get diagnostics v_n = row_count;
    exit when v_n > 0;

    begin
      insert into public.leaderboard (
        id, name, av, wins, losses, ties, games, total_games,
        total_pts, best_pts, streak, best_streak,
        wins_1v1, games_1v1, wins_2v2, games_2v2, wins_4p, games_4p,
        wins_classic, games_classic, wins_escoba, games_escoba,
        wins_quick, games_quick,
        total_missas, total_bumbas, total_rondas, total_tringas,
        last_seen, last_update, updated_at
      ) values (
        v_id,
        coalesce(p_data->>'name',''), coalesce(nullif(p_data->>'av',''),'👤'),
        coalesce((p_data->>'wins')::int,0),      coalesce((p_data->>'losses')::int,0),
        coalesce((p_data->>'ties')::int,0),      g, g,
        coalesce((p_data->>'total_pts')::int,0), coalesce((p_data->>'best_pts')::int,0),
        coalesce((p_data->>'streak')::int,0),    coalesce((p_data->>'best_streak')::int,0),
        coalesce((p_data->>'wins_1v1')::int,0),     coalesce((p_data->>'games_1v1')::int,0),
        coalesce((p_data->>'wins_2v2')::int,0),     coalesce((p_data->>'games_2v2')::int,0),
        coalesce((p_data->>'wins_4p')::int,0),      coalesce((p_data->>'games_4p')::int,0),
        coalesce((p_data->>'wins_classic')::int,0), coalesce((p_data->>'games_classic')::int,0),
        coalesce((p_data->>'wins_escoba')::int,0),  coalesce((p_data->>'games_escoba')::int,0),
        coalesce((p_data->>'wins_quick')::int,0),   coalesce((p_data->>'games_quick')::int,0),
        coalesce((p_data->>'total_missas')::int,0), coalesce((p_data->>'total_bumbas')::int,0),
        coalesce((p_data->>'total_rondas')::int,0), coalesce((p_data->>'total_tringas')::int,0),
        coalesce((p_data->>'last_seen')::bigint,0), now(), now()
      );
      return;
    exception when unique_violation then
      -- نداء آخر سبقنا بجزء من الثانية: عُد إلى التحديث
      if v_try >= 3 then raise; end if;
    end;
  end loop;
end;
$$;

-- ══ 3) ملفّ اللاعب: upsert_player ════════════════════════════════════
-- تُنادى من update-stats بـ{ p_data: {id,name,av,wins,losses,games,xp,
-- is_online,last_seen} }. جدول players فيه بيانات قائمة (68 صفّاً)،
-- ولا تُلمَس فيه أعمدة gold و gems و level و is_bot و photo إطلاقاً.
create or replace function public.upsert_player(p_data jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id  text := nullif(p_data->>'id','');
  v_n   integer;
  v_try integer := 0;
begin
  if v_id is null then
    raise exception 'upsert_player: معرّف اللاعب مفقود';
  end if;

  loop
    v_try := v_try + 1;

    update public.players set
      name      = coalesce(nullif(p_data->>'name',''), name),
      av        = coalesce(nullif(p_data->>'av',''),   av),
      wins      = greatest(coalesce(wins,0),      coalesce((p_data->>'wins')::int,0)),
      losses    = greatest(coalesce(losses,0),    coalesce((p_data->>'losses')::int,0)),
      games     = greatest(coalesce(games,0),     coalesce((p_data->>'games')::int,0)),
      xp        = greatest(coalesce(xp,0),        coalesce((p_data->>'xp')::int,0)),
      is_online = coalesce((p_data->>'is_online')::boolean, is_online),
      last_seen = greatest(coalesce(last_seen,0), coalesce((p_data->>'last_seen')::bigint,0))
    where id = v_id;

    get diagnostics v_n = row_count;
    exit when v_n > 0;

    begin
      insert into public.players (id, name, av, wins, losses, games, xp, is_online, last_seen)
      values (
        v_id, coalesce(p_data->>'name',''), coalesce(nullif(p_data->>'av',''),'👤'),
        coalesce((p_data->>'wins')::int,0),  coalesce((p_data->>'losses')::int,0),
        coalesce((p_data->>'games')::int,0), coalesce((p_data->>'xp')::int,0),
        coalesce((p_data->>'is_online')::boolean,false),
        coalesce((p_data->>'last_seen')::bigint,0)
      );
      return;
    exception when unique_violation then
      if v_try >= 3 then raise; end if;
    end;
  end loop;
end;
$$;

-- ══ 4) الموسم: upsert_season_stats ═══════════════════════════════════
-- تُنادى من update-stats بمعاملات مُسمّاة. تكتب في الموسم النشط وحده،
-- وتسكت بلا خطأ إن لم يكن هناك موسم نشط — فلا تُعطّل الكتابة الأساسية.
create or replace function public.upsert_season_stats(
  p_player_id text,
  p_name      text,
  p_av        text,
  p_wins      integer,
  p_games     integer,
  p_pts       integer
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_sid integer;
  v_n   integer;
begin
  if nullif(p_player_id,'') is null then return; end if;

  select id into v_sid from public.seasons
   where is_active is true
   order by coalesce(start_date, created_at) desc nulls last
   limit 1;

  if v_sid is null then return; end if;   -- لا موسم نشط: لا شيء يُكتب

  update public.season_stats set
    name       = coalesce(nullif(p_name,''), name),
    av         = coalesce(nullif(p_av,''),   av),
    wins       = greatest(coalesce(wins,0),      coalesce(p_wins,0)),
    games      = greatest(coalesce(games,0),     coalesce(p_games,0)),
    total_pts  = greatest(coalesce(total_pts,0), coalesce(p_pts,0)::bigint),
    updated_at = now()
  where season_id = v_sid and player_id = p_player_id;

  get diagnostics v_n = row_count;
  if v_n = 0 then
    begin
      -- id يُملأ صراحةً: عمود uuid قد لا يحمل قيمة افتراضية في جدولك،
      -- فإغفاله كان سيُفشل الإدراج بـ«null value in column id».
      insert into public.season_stats (id, season_id, player_id, name, av, wins, games, total_pts, updated_at)
      values (gen_random_uuid(), v_sid, p_player_id, coalesce(p_name,''), coalesce(nullif(p_av,''),'👤'),
              coalesce(p_wins,0), coalesce(p_games,0), coalesce(p_pts,0), now());
    exception when unique_violation then
      update public.season_stats set
        wins      = greatest(coalesce(wins,0),      coalesce(p_wins,0)),
        games     = greatest(coalesce(games,0),     coalesce(p_games,0)),
        total_pts = greatest(coalesce(total_pts,0), coalesce(p_pts,0)::bigint)
      where season_id = v_sid and player_id = p_player_id;
    end;
  end if;
end;
$$;

-- ══ 5) القراءة: get_leaderboard ══════════════════════════════════════
-- تُنادى من get-leaderboard بـ{ p_sort, p_limit, p_offset }.
--
-- ثلاثة أمور مقصودة هنا:
--
--  أ) أسماء الفرز: التطبيق يرسل rondas و missas مختصرَين ويقرأ
--     total_rondas و total_missas. الترجمة هنا، وبدونها يفشل الفرز
--     بعمود مجهول. وأي قيمة مجهولة تؤول إلى wins بدل أن تُسقط القائمة.
--
--  ب) البوتات: دالة bump_bot_stats عندك تكتب في جدول players لا في
--     leaderboard — فكانت البوتات تُسجَّل في جدول لا تقرأ منه اللوحة،
--     ولم يكن ممكناً أن تظهر أبداً. نضمّها هنا بـunion من players حيث
--     is_bot، فتظهر بأرقامها العالمية. وما لا عمود له فيها (أنظمة اللعب
--     والحركات) يخرج صفراً — وهذا متوقّع لأن جدول players لا يحملها.
--
--  ج) الترتيب حتميّ: العمود المطلوب ثم فواصل ثابتة تنتهي بالمعرّف
--     الفريد — وهي نفس سلسلة الفواصل في مقارنة التطبيق (_lbCmp)،
--     فتخرج القائمة واحدة على كل الأجهزة ولا يتحرّك متعادلان بين
--     فتحة وأخرى.
create or replace function public.get_leaderboard(
  p_sort   text    default 'wins',
  p_limit  integer default 50,
  p_offset integer default 0
) returns table (
  id            text,
  name          text,
  av            text,
  wins          integer,
  losses        integer,
  ties          integer,
  games         integer,
  total_pts     integer,
  best_pts      integer,
  streak        integer,
  best_streak   integer,
  wins_1v1      integer,
  games_1v1     integer,
  wins_2v2      integer,
  games_2v2     integer,
  wins_4p       integer,
  games_4p      integer,
  wins_classic  integer,
  games_classic integer,
  wins_escoba   integer,
  games_escoba  integer,
  wins_quick    integer,
  games_quick   integer,
  total_missas  integer,
  total_bumbas  integer,
  total_rondas  integer,
  total_tringas integer,
  last_seen     bigint,
  is_bot        boolean,
  rank          bigint
)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_col text;
  v_lim integer := least(greatest(coalesce(p_limit, 50), 1), 500);
  v_off integer := greatest(coalesce(p_offset, 0), 0);
begin
  v_col := case lower(coalesce(p_sort,'wins'))
             when 'games'        then 'games'
             when 'total_pts'    then 'total_pts'
             when 'best_pts'     then 'best_pts'
             when 'wins_1v1'     then 'wins_1v1'
             when 'wins_2v2'     then 'wins_2v2'
             when 'wins_4p'      then 'wins_4p'
             when 'wins_classic' then 'wins_classic'
             when 'wins_escoba'  then 'wins_escoba'
             when 'wins_quick'   then 'wins_quick'
             when 'streak'       then 'streak'
             when 'best_streak'  then 'best_streak'
             when 'rondas'       then 'total_rondas'
             when 'missas'       then 'total_missas'
             when 'bumbas'       then 'total_bumbas'
             when 'tringas'      then 'total_tringas'
             when 'losses'       then 'losses'
             when 'ties'         then 'ties'
             when 'last_seen'    then 'last_seen'
             else 'wins'
           end;

  return query execute format($q$
    with everyone (
      id, name, av, wins, losses, ties, games, total_pts, best_pts,
      streak, best_streak,
      wins_1v1, games_1v1, wins_2v2, games_2v2, wins_4p, games_4p,
      wins_classic, games_classic, wins_escoba, games_escoba,
      wins_quick, games_quick,
      total_missas, total_bumbas, total_rondas, total_tringas,
      last_seen, is_bot
    ) as (
      select l.id, l.name, coalesce(l.av,'👤'),
             coalesce(l.wins,0), coalesce(l.losses,0), coalesce(l.ties,0), coalesce(l.games,0),
             coalesce(l.total_pts,0), coalesce(l.best_pts,0),
             coalesce(l.streak,0), coalesce(l.best_streak,0),
             coalesce(l.wins_1v1,0), coalesce(l.games_1v1,0),
             coalesce(l.wins_2v2,0), coalesce(l.games_2v2,0),
             coalesce(l.wins_4p,0),  coalesce(l.games_4p,0),
             coalesce(l.wins_classic,0), coalesce(l.games_classic,0),
             coalesce(l.wins_escoba,0),  coalesce(l.games_escoba,0),
             coalesce(l.wins_quick,0),   coalesce(l.games_quick,0),
             coalesce(l.total_missas,0), coalesce(l.total_bumbas,0),
             coalesce(l.total_rondas,0), coalesce(l.total_tringas,0),
             coalesce(l.last_seen,0), false
        from public.leaderboard l
      union all
      select p.id, p.name, coalesce(p.av,'🤖'),
             coalesce(p.wins,0), coalesce(p.losses,0), coalesce(p.ties,0), coalesce(p.games,0),
             coalesce(p.total_pts,0), coalesce(p.best_pts,0),
             coalesce(p.streak,0), 0,
             0,0, 0,0, 0,0, 0,0, 0,0, 0,0,
             0,0,0,0,
             coalesce(p.last_seen,0), true
        from public.players p
       where p.is_bot is true
    )
    select e.*,
           row_number() over (order by e.%1$I desc, e.wins desc, e.total_pts desc,
                                       e.games desc, e.id asc)
      from everyone e
     order by e.%1$I desc, e.wins desc, e.total_pts desc, e.games desc, e.id asc
     limit %2$s offset %3$s
  $q$, v_col, v_lim, v_off);
end;
$$;

-- ══ 6) رتبة لاعب بعينه: get_player_rank ══════════════════════════════
-- تُنادى من get-leaderboard بـ{ p_id, p_sort }. تُرجع رتبة اللاعب بين
-- اللاعبين الحقيقيين، أو null إن لم يكن له صفّ بعد.
create or replace function public.get_player_rank(p_id text, p_sort text default 'wins')
returns integer
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_col  text;
  v_mine bigint;
  v_rank integer;
begin
  if nullif(p_id,'') is null then return null; end if;

  v_col := case lower(coalesce(p_sort,'wins'))
             when 'games'        then 'games'
             when 'total_pts'    then 'total_pts'
             when 'best_pts'     then 'best_pts'
             when 'wins_1v1'     then 'wins_1v1'
             when 'wins_2v2'     then 'wins_2v2'
             when 'wins_4p'      then 'wins_4p'
             when 'wins_classic' then 'wins_classic'
             when 'wins_escoba'  then 'wins_escoba'
             when 'wins_quick'   then 'wins_quick'
             when 'streak'       then 'streak'
             when 'best_streak'  then 'best_streak'
             when 'rondas'       then 'total_rondas'
             when 'missas'       then 'total_missas'
             else 'wins'
           end;

  execute format('select %I::bigint from public.leaderboard where id = $1', v_col)
     into v_mine using p_id;

  if v_mine is null then return null; end if;   -- لا صفّ لهذا اللاعب بعد

  execute format('select count(*)::int + 1 from public.leaderboard where %I::bigint > $1', v_col)
     into v_rank using v_mine;

  return v_rank;
end;
$$;

-- ══ 7) الصلاحيات ═════════════════════════════════════════════════════
-- الدوال تُنادى من Edge Functions بمفتاح service_role وحده — وهو مفتاح
-- لا يغادر الخادم. ومفتاح anon مضمَّن في ملفّ APK المنشور، فهو في حكم
-- المعلوم للجميع، ولا يُمنح حقّ نداء شيء من هذه.
--
-- ⚠️ المنح الصريح لـservice_role ضروري بعد السحب من public: service_role
--    عضو في public، فلولاه لفشل النداء بـ«permission denied» رغم صحّته.
--    (وهذا بالضبط ما ينقص دالة bump_bot_stats في 01_bot_stats.sql،
--     فنُصلحه هنا أيضاً إن كنتَ نفّذتَ ذلك الملفّ.)
do $$
declare f text;
begin
  foreach f in array array[
    'public.upsert_leaderboard(jsonb)',
    'public.upsert_player(jsonb)',
    'public.upsert_season_stats(text,text,text,integer,integer,integer)',
    'public.get_leaderboard(text,integer,integer)',
    'public.get_player_rank(text,text)'
  ] loop
    execute 'revoke all on function ' || f || ' from public, anon, authenticated';
    execute 'grant execute on function ' || f || ' to service_role';
  end loop;

  if exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
              where n.nspname='public' and p.proname='bump_bot_stats') then
    execute 'grant execute on function public.bump_bot_stats(text,text,text,int,bigint,jsonb) to service_role';
  end if;
end $$;

-- PostgREST يخزّن مخطّط الدوال في ذاكرته، فلا يرى الجديدة إلا بعد تنبيه.
-- بدون هذا السطر قد تبقى النداءات تُرجع 404 بضع دقائق.
notify pgrst, 'reload schema';

-- ══ 8) اختبار ذاتيّ ══════════════════════════════════════════════════
-- يمرّ على المسار كاملاً كما يمرّ التطبيق، ثم ينظّف أثره.
do $$
declare
  v_id   text := '__ronda_selftest__';
  v_rows integer;
  v_wins integer;
  v_rank integer;
begin
  -- الكتابة، كما ترسلها update-stats
  perform public.upsert_leaderboard(jsonb_build_object(
    'id', v_id, 'name', 'اختبار', 'av', '🧪',
    'wins', 7, 'losses', 2, 'ties', 1, 'games', 10,
    'total_pts', 850, 'best_pts', 33, 'streak', 3, 'best_streak', 5,
    'wins_1v1', 4, 'games_1v1', 6, 'wins_escoba', 2, 'games_escoba', 3,
    'total_rondas', 5, 'total_missas', 2,
    'last_seen', (extract(epoch from now())*1000)::bigint));
  perform public.upsert_player(jsonb_build_object(
    'id', v_id, 'name', 'اختبار', 'av', '🧪',
    'wins', 7, 'losses', 2, 'games', 10, 'xp', 850,
    'is_online', false, 'last_seen', (extract(epoch from now())*1000)::bigint));
  perform public.upsert_season_stats(v_id, 'اختبار', '🧪', 7, 10, 850);

  -- حماية التراجع: هاتف أُعيد تنصيبه يرسل أصفاراً
  perform public.upsert_leaderboard(jsonb_build_object(
    'id', v_id, 'name', 'اختبار', 'av', '🧪',
    'wins', 0, 'games', 0, 'total_pts', 0, 'streak', 0));

  -- القراءة، كما تناديها get-leaderboard
  select count(*), max(g.wins) into v_rows, v_wins
    from public.get_leaderboard('wins', 500, 0) g where g.id = v_id;

  if v_rows <> 1 then
    raise exception 'الاختبار فشل: الصفّ لم يظهر في get_leaderboard';
  end if;
  if v_wins <> 7 then
    raise exception 'الاختبار فشل: الأصفار دهست التاريخ (wins=%)', v_wins;
  end if;

  v_rank := public.get_player_rank(v_id, 'wins');
  if v_rank is null then
    raise exception 'الاختبار فشل: get_player_rank لم تُرجع رتبة';
  end if;

  -- كل تبويبات الواجهة
  perform public.get_leaderboard(s, 5, 0) from unnest(array[
    'wins','games','total_pts','best_pts','wins_1v1','wins_2v2','wins_4p',
    'wins_classic','wins_escoba','wins_quick','streak','rondas','missas'
  ]) s;

  -- تنظيف
  delete from public.season_stats where player_id = v_id;
  delete from public.leaderboard  where id = v_id;
  delete from public.players      where id = v_id;

  raise notice '════════════════════════════════════════════';
  raise notice '✓ نجح كل شيء: الكتابة والقراءة والرتبة وكل التبويبات.';
  raise notice '  افتح لوحة المتصدرين في التطبيق والعب مباراة.';
  raise notice '════════════════════════════════════════════';
end $$;
