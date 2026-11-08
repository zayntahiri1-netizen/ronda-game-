#!/usr/bin/env python3
# ╔══════════════════════════════════════════════════════════════╗
# ║  خادم معاينة يحاكي cleanUrls في Firebase Hosting             ║
# ║  بلا هذا تختلف المعاينة عن الإنتاج: python -m http.server     ║
# ║  يردّ 404 على /terms بينما Firebase يخدمها من terms.html.      ║
# ║                                                              ║
# ║  القاعدتان كما في Firebase حرفياً:                            ║
# ║    /terms       → يخدم terms.html                            ║
# ║    /terms.html  → إعادة توجيه 301 إلى /terms                  ║
# ║                                                              ║
# ║  يناديه preview.sh — لا تشغّله مباشرة.                        ║
# ╚══════════════════════════════════════════════════════════════╝
import os
import sys
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer


class CleanUrls(SimpleHTTPRequestHandler):
    def send_head(self):
        path = self.path.split('?', 1)[0].split('#', 1)[0]

        # /terms.html → 301 → /terms   (index.html استثناء: جذر المجلّد)
        if path.endswith('.html') and not path.endswith('/index.html'):
            dest = path[:-5]
            tail = self.path[len(path):]
            self.send_response(301)
            self.send_header('Location', dest + tail)
            self.end_headers()
            return None

        # /terms → terms.html إن وُجد
        if not path.endswith('/') and not os.path.splitext(path)[1]:
            cand = self.translate_path(path) + '.html'
            if os.path.isfile(cand):
                self.path = path + '.html' + self.path[len(path):]

        return super().send_head()

    def log_message(self, fmt, *args):
        sys.stderr.write('  %s\n' % (fmt % args))


if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    root = sys.argv[2] if len(sys.argv) > 2 else '.'
    handler = partial(CleanUrls, directory=root)
    ThreadingHTTPServer(('', port), handler).serve_forever()
