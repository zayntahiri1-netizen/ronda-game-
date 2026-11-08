// ╔══════════════════════════════════════════════════════════════════════╗
// ║  Edge Function: update-bot-stats                                     ║
// ║  يستقبل فارق إحصائيات بوت من التطبيق ويجمعه عالمياً                  ║
// ║                                                                      ║
// ║  النشر:  supabase functions deploy update-bot-stats --no-verify-jwt  ║
// ║  (أو من لوحة Supabase → Edge Functions → Deploy a new function)      ║
// ╚══════════════════════════════════════════════════════════════════════╝
//
// لماذا منفصلة عن update-stats: مسار اللاعبين يكتب الإجمالي كما هو، وهذا
// صحيح لصفّ يملكه هاتف واحد. أما صفّ البوت فمشترك عالمياً، فيلزمه تجميع
// الفارق. وفصلها يعني أيضاً أن التطبيق يعمل طبيعياً قبل نشرها: النداء
// يفشل بهدوء فلا تظهر البوتات، ولا يتعطّل شيء آخر.

import { createClient } from 'jsr:@supabase/supabase-js@2';

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// الحقول التراكمية التي يرسلها التطبيق
const COUNTERS = [
  'wins', 'losses', 'ties', 'games',
  'wins_1v1', 'games_1v1', 'wins_2v2', 'games_2v2', 'wins_4p', 'games_4p',
  'wins_classic', 'games_classic', 'wins_escoba', 'games_escoba',
  'wins_quick', 'games_quick',
  'total_missas', 'total_bumbas', 'total_rondas', 'total_tringas',
];

// سقوف لكل نداء — تكبح أي محاولة لنفخ رقم بوت من خارج التطبيق.
// سخيّة بما يكفي لهاتف ظلّ بلا اتصال فترة ثم أرسل متراكمه دفعة واحدة.
const MAX_COUNTER = 500;
const MAX_POINTS  = 50_000;

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  });

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') return json({ ok: false, error: 'POST only' }, 405);

  try {
    const b = await req.json();

    const id = String(b?.id ?? '');
    // لا يُقبل هنا إلا معرّف بوت — صفوف اللاعبين تمرّ عبر update-stats
    if (!/^bot_[a-z0-9]{1,16}$/i.test(id)) {
      return json({ ok: false, error: 'invalid bot id' }, 400);
    }

    // اجمع الفارق الموجب فقط، مع تطبيق السقوف
    const d: Record<string, number> = {};
    for (const k of COUNTERS) {
      const v = Math.floor(Number(b?.[k] ?? 0));
      if (Number.isFinite(v) && v > 0) d[k] = Math.min(v, MAX_COUNTER);
    }
    const pts = Math.floor(Number(b?.total_pts ?? 0));
    if (Number.isFinite(pts) && pts > 0) d.total_pts = Math.min(pts, MAX_POINTS);

    if (Object.keys(d).length === 0) return json({ ok: true, skipped: 'no delta' });

    const sb = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    const { error } = await sb.rpc('bump_bot_stats', {
      p_id:        id,
      p_name:      String(b?.name ?? '').slice(0, 40),
      p_av:        String(b?.av ?? '🤖').slice(0, 8),
      p_best_pts:  Math.max(0, Math.min(999, Math.floor(Number(b?.best_pts ?? 0)))),
      p_last_seen: Math.max(0, Math.floor(Number(b?.last_seen ?? Date.now()))),
      d,
    });

    if (error) return json({ ok: false, error: error.message }, 500);
    return json({ ok: true, applied: d });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 400);
  }
});
