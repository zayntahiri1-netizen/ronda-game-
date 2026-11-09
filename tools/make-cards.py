#!/usr/bin/env python3
# ╔══════════════════════════════════════════════════════════════╗
# ║  يُولّد www/cards/*.png من رزمة baraja_40 الأصلية.             ║
# ║                                                              ║
# ║  لماذا نتدخّل في الرقم: الرقم الأصلي ارتفاعه 10% من الورقة     ║
# ║  وبخطّ رفيع، فيصير 8 بكسل على الطاولة (52×78) ولا يُقرأ.       ║
# ║  نعالج الزاويتين: العليا اليسرى، والسفلى اليمنى المقلوبة —     ║
# ║  بتدوير الورقة 180° وتطبيق المنطق نفسه ثم إعادتها. التدوير     ║
# ║  بزاوية قائمة انعكاسُ بكسلات تامّ بلا فقدان، فتخرج الزاويتان   ║
# ║  متطابقتين حتماً ولا يحتاج القياس أن يُكرَّر يدوياً.            ║
# ║  والزاويتان العليا يتداخل معهما الرسم في بعض الأوراق (بياض     ║
# ║  30% فقط)، فالرقم العاري لا يُقرأ فوقه — لذلك نضع لوحة معتمة  ║
# ║  بلون ورق الورقة نفسه، تغطّي الرقم الأصلي ويُرسم فوقها رقم    ║
# ║  أكبر وأثخن. نرسم على مقاس الأصل 600×927 ثم نصغّر، فتخرج      ║
# ║  الحواف ناعمة.                                               ║
# ║                                                              ║
# ║  الاستعمال:  python3 tools/make-cards.py <مجلّد master>       ║
# ╚══════════════════════════════════════════════════════════════╝
import sys, os, glob
from PIL import Image, ImageDraw, ImageFont
import numpy as np

SRC  = sys.argv[1] if len(sys.argv) > 1 else 'baraja_40/master'
OUT  = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'www', 'cards')
FONT = '/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf'
H_OUT = 366          # 3× أكبر مقاس ظاهر (122 بكسل لصنف md)

os.makedirs(OUT, exist_ok=True)

def paper_color(a):
    """لون ورق الورقة: أشيع لون فاتح في الثلث الأعلى."""
    top = a[:a.shape[0]//3].reshape(-1, 3)
    light = top[top.sum(axis=1) > 700]
    if len(light) == 0: return (253, 251, 244)
    return tuple(int(v) for v in np.median(light, axis=0))

def index_box(a, H, W):
    """صندوق الرقم الأصلي أعلى اليسار، داخل الإطار."""
    y0, y1 = int(H*.045), int(H*.19)
    x0, x1 = int(W*.055), int(W*.38)
    reg = a[y0:y1, x0:x1]
    ys, xs = np.nonzero(reg.sum(axis=2) < 330)
    if len(xs) == 0: return None
    return (x0+int(xs.min()), y0+int(ys.min()), x0+int(xs.max()), y0+int(ys.max()))

def stamp(im, rank):
    """يغطّي الرقم الأصلي أعلى اليسار بلوحة بلون ورق الورقة، ويرسم فوقها
    رقماً أكبر وأثخن. يُنادى مرّتين: مرّة كما هي ومرّة على نسخة مقلوبة."""
    W, H = im.size
    rgb = np.asarray(im.convert('RGB')).astype(int)
    paper = paper_color(rgb)
    box = index_box(rgb, H, W)
    # اللوحة: تبدأ من موضع الرقم الأصلي وتتّسع بقدر عدد الخانات
    bx0 = box[0] - int(W*.015) if box else int(W*.05)
    by0 = box[1] - int(H*.012) if box else int(H*.045)
    bw  = int(W * (.30 if len(rank) > 1 else .21))
    bh  = int(H * .155)
    bx0 = max(int(W*.035), bx0); by0 = max(int(H*.030), by0)

    d = ImageDraw.Draw(im, 'RGBA')
    r = int(W*.035)
    d.rounded_rectangle([bx0, by0, bx0+bw, by0+bh], radius=r,
                        fill=paper + (255,), outline=(26,22,16,150), width=max(2, int(W*.005)))

    # الرقم: نكبّره حتى يملأ 72% من ارتفاع اللوحة
    size = int(bh*.78)
    while size > 8:
        fnt = ImageFont.truetype(FONT, size)
        l, t, rr, b = d.textbbox((0, 0), rank, font=fnt)
        if (rr-l) <= bw*.78 and (b-t) <= bh*.72: break
        size -= 2
    l, t, rr, b = d.textbbox((0, 0), rank, font=fnt)
    d.text((bx0 + (bw-(rr-l))/2 - l, by0 + (bh-(b-t))/2 - t), rank, font=fnt, fill=(20, 17, 12, 255))
    return im


n = 0
for f in sorted(glob.glob(os.path.join(SRC, '*.png'))):
    name = os.path.basename(f)
    rank = name.rsplit('.', 1)[0].split('_')[1]
    im = Image.open(f).convert('RGBA')
    W, H = im.size
    im = stamp(im, rank)                 # الزاوية العليا اليسرى
    im = stamp(im.rotate(180), rank).rotate(180)   # والسفلى اليمنى المقلوبة
    w_out = round(W * H_OUT / H)
    im = im.resize((w_out, H_OUT), Image.LANCZOS)
    im.quantize(colors=255, method=Image.FASTOCTREE, dither=Image.FLOYDSTEINBERG) \
      .save(os.path.join(OUT, name), optimize=True)
    n += 1

tot = sum(os.path.getsize(p) for p in glob.glob(os.path.join(OUT, '*.png')))
print(f'✓ {n} ورقة · {w_out}×{H_OUT} · {tot/1024/1024:.2f} ميجابايت · متوسّط {tot/n/1024:.0f} كيلوبايت')
