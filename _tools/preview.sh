#!/bin/bash
# Renders the site with headless Google Chrome for review, without Jekyll.
#   _tools/preview.sh <out-dir>
# index.html is served as it is. The Markdown pages (privacy/, pairing-protocol/)
# are rendered by wrapping the LIVE site's kramdown output in _layouts/default.html,
# so they show the published words: a local change to a .md file is not shown.
# It prints each page's width and height at each size: a width above the window's
# means the page scrolls sideways. Files beginning with "_" are not published.
set -euo pipefail
OUT="${1:?usage: _tools/preview.sh <out-dir>}"
SITE="$(cd "$(dirname "$0")/.." && pwd)"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
LIVE="https://env-media.github.io/das-cam"
PORT="${PREVIEW_PORT:-8137}"
mkdir -p "$OUT"
ROOT="$(mktemp -d)"
cp "$SITE/index.html" "$ROOT/"; cp -R "$SITE/assets" "$ROOT/"
for page in privacy pairing-protocol; do
  mkdir -p "$ROOT/$page"
  curl -fsS "$LIVE/$page/" -o "$ROOT/$page/live.html"
  python3 - "$SITE/_layouts/default.html" "$SITE/$page/index.md" "$ROOT/$page/live.html" "$ROOT/$page/index.html" <<'PY'
import re, sys
layout, md, live, out = sys.argv[1:]
title = re.search(r'^title:\s*(.+)$', open(md).read(), re.M).group(1).strip()
html = open(live).read()
m = re.search(r'<main id="main" class="prose">\s*<div class="wrap">\n(.*?)\n  </div>\s*</main>', html, re.S)
if m:  # the live site already uses this site's layout
    body = m.group(1)
else:  # the GitHub theme's layout (before 1267ffc); its site-title link is the theme's, not the page's
    body = re.search(r'<div class="container-lg px-3 my-5 markdown-body">(.*?)</div>\s*<script', html, re.S).group(1)
    body, n = re.subn(r'^\s*<h1><a href="[^"]*">[^<]*</a></h1>', '', body)
    assert n == 1, "the theme's title link was not found"
page = open(layout).read().replace('{{ page.title }}', title).replace('{{ content }}', body)
open(out, 'w').write(page)
PY
  rm "$ROOT/$page/live.html"
done
# measure.js records the page's size; it is added to the preview copy only.
cat > "$ROOT/measure.js" <<'JS'
addEventListener("load", function () {
  var d = document.documentElement;
  d.setAttribute("data-w", d.scrollWidth);
  d.setAttribute("data-h", d.scrollHeight);
  d.setAttribute("data-dark", matchMedia("(prefers-color-scheme: dark)").matches);
});
JS
# Chrome's window is at least 500 px wide, so every page is shown in an iframe of
# the exact width, centred, and the shot is cropped to it (sips crops from the centre).
cat > "$ROOT/frame.html" <<'HTML'
<!doctype html><html><head><style>html,body{margin:0;background:#808080}iframe{display:block;margin:0 auto;border:0}</style></head>
<body><iframe id="f"></iframe><script>
var q = new URLSearchParams(location.search), f = document.getElementById("f");
f.width = q.get("w"); f.height = q.get("h"); f.src = q.get("src");
f.onload = function () {
  var d = f.contentDocument.documentElement, r = document.documentElement;
  ["data-w", "data-h", "data-dark"].forEach(function (k) { r.setAttribute(k, d.getAttribute(k)); });
  var at = q.get("at") && f.contentDocument.getElementById(q.get("at"));
  if (at) f.contentWindow.scrollTo({ top: at.getBoundingClientRect().top - 16, behavior: "instant" });
};
</script></body></html>
HTML
for f in "$ROOT/index.html" "$ROOT"/*/index.html; do
  sed -i '' 's#</head>#<script src="/measure.js"></script></head>#' "$f"
done
python3 -m http.server "$PORT" --bind 127.0.0.1 -d "$ROOT" >/dev/null 2>&1 &
SERVER=$!
trap 'kill $SERVER 2>/dev/null; rm -rf "${ROOT:?}"' EXIT
sleep 1
U="http://127.0.0.1:$PORT"
scheme() { [ "$1" = dark ] && echo "--blink-settings=preferredColorScheme=0" || echo "--blink-settings=preferredColorScheme=1"; }
win() { [ "$1" -lt 500 ] && echo 500 || echo "$1"; }
measure() { # path width mode -> "w h dark"
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars "$(scheme "$3")" --window-size="$(win "$2")",900 \
    --virtual-time-budget=4000 --dump-dom "$U/frame.html?w=$2&h=900&src=$1" 2>/dev/null |
    python3 -c 'import re,sys; s=sys.stdin.read(); print(*[re.search(k+r"=\"([^\"]*)\"", s).group(1) for k in ("data-w","data-h","data-dark")])'
}
shot() { # name path width mode scale full|top
  read -r w h dk < <(measure "$2" "$3" "$4")
  local height=$h; [ "$6" = top ] && height=$(( h < 1100 ? h : 1100 ))
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars "$(scheme "$4")" --window-size="$(win "$3")","$height" \
    --force-device-scale-factor="$5" --virtual-time-budget=4000 --screenshot="$OUT/$1.png" \
    "$U/frame.html?w=$3&h=$height&src=$2" >/dev/null 2>&1
  sips -c $(( height * $5 )) $(( $3 * $5 )) "$OUT/$1.png" >/dev/null
  printf '%-22s width %4s  page width %4s  height %5s  dark %s\n' "$1" "$3" "$w" "$h" "$dk"
}
shot home-1440-light / 1440 light 1 full
shot home-1440-dark  / 1440 dark 1 full
shot home-390-light  / 390 light 2 full
shot home-390-dark   / 390 dark 2 full
shot home-390-light-top / 390 light 2 top
shot home-390-dark-top  / 390 dark 2 top
shot home-390-controls-light "/&at=controls" 390 light 2 top
shot home-390-devices-dark "/&at=devices" 390 dark 2 top
# The Pre-Recording section close up, both widths and both modes.
shot prerec-1440-light "/&at=features" 1440 light 1 top
shot prerec-1440-dark  "/&at=features" 1440 dark 1 top
shot prerec-390-light  "/&at=features" 390 light 2 top
shot prerec-390-dark   "/&at=features" 390 dark 2 top
# The maker section close up.
shot maker-1440-light "/&at=maker" 1440 light 1 top
shot maker-390-dark   "/&at=maker" 390 dark 2 top
shot privacy-1440-light /privacy/ 1440 light 1 top
shot privacy-390-dark   /privacy/ 390 dark 2 top
shot pairing-390-light  /pairing-protocol/ 390 light 2 top
# The policy's widest table, on a narrow screen ("&at=" scrolls the page to that heading).
shot privacy-table-390-light "/privacy/&at=who-receives-data" 390 light 2 top
# Checks with no picture kept: 320 px wide, and 720 px (a 1440 window at 200 % zoom).
for u in / /privacy/ /pairing-protocol/; do
  for wd in 320 720; do
    for m in light dark; do
      read -r w h dk < <(measure "$u" "$wd" "$m")
      printf 'check %-20s width %4s %-5s page width %4s %s\n' "$u" "$wd" "$m" "$w" "$([ "$w" -le "$wd" ] && echo ok || echo SIDEWAYS)"
    done
  done
done
