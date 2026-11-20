#!/bin/bash
# Renders the site with headless Google Chrome for review, without Jekyll.
#   _tools/preview.sh <out-dir>          the full set of review shots
#   _tools/preview.sh <out-dir> theme    the light/dark sheets only
#   _tools/preview.sh <out-dir> dark     the dark-mode sheets (the top at 1280 and 390, the whole page at 1280)
# index.html is served as it is. The Markdown pages (privacy/, pairing-protocol/)
# are rendered by wrapping the LIVE site's kramdown output in _layouts/default.html,
# so they show the published words: a local change to a .md file is not shown.
# It prints each page's width and height at each size: a width above the window's
# means the page scrolls sideways. Files beginning with "_" are not published.
# A shot's mode is the device's setting (light or dark). "&theme=light|dark" in a
# path stores that choice first, as the header's switch does, so the page's own
# script applies it; "&pv=..." turns on a preview-only look from preview.css
# below, which is never part of the site.
set -euo pipefail
OUT="${1:?usage: _tools/preview.sh <out-dir> [theme]}"
SET="${2:-all}"
SITE="$(cd "$(dirname "$0")/.." && pwd)"
# Two checks before any picture. Each page's inline script must match the hash in
# its Content-Security-Policy, or the browser refuses to run it; and site.css's two
# dark blocks (the device's setting, the switch's choice) must hold the same colours.
python3 - "$SITE/index.html" "$SITE/_layouts/default.html" "$SITE/assets/site.css" <<'PY'
import base64, hashlib, re, sys
for f in sys.argv[1:3]:
    s = open(f).read()
    scripts = re.findall(r"<script>(.*?)</script>", s, re.S)
    assert len(scripts) == 1, f + ": expected one inline script"
    h = "'sha256-" + base64.b64encode(hashlib.sha256(scripts[0].encode()).digest()).decode() + "'"
    csp = re.search(r'http-equiv="Content-Security-Policy" content="([^"]*)"', s).group(1)
    assert h in csp, f + ": the inline script's hash " + h + " is not in the Content-Security-Policy"
    print("check csp-hash", f.split("/")[-1], "ok", h)
css = open(sys.argv[3]).read()
def decls(sel):
    i = css.index(sel); body = css[css.index("{", i + len(sel) - 1) + 1:css.index("}", i)]
    return sorted(d.strip() for d in body.split(";") if d.strip().startswith("--"))
a = decls(':root:not([data-theme="light"]) {'); b = decls(':root[data-theme="dark"] {')
assert a == b and a, "site.css: the two dark blocks differ"
print("check dark-blocks identical,", len(a), "colours")
# The script's browser-bar colours must be the page colours.
bar = re.search(r'bar = \{ light: "(#[0-9a-f]{6})", dark: "(#[0-9a-f]{6})" \}', open(sys.argv[1]).read()).groups()
paper = (re.search(r"--paper: (#[0-9a-f]{6})", css).group(1), dict(d.split(": ") for d in a)["--paper"])
assert bar == paper, "the script's theme-color %s differs from site.css's --paper %s" % (bar, paper)
print("check theme-color = --paper", bar)
PY
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
  d.setAttribute("data-dark", (d.getAttribute("data-theme") || (matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")) === "dark");
  // Each place holds two icons, one hidden; measure the one shown.
  function shown(sel) { var all = document.querySelectorAll(sel); for (var i = 0; i < all.length; i++) if (all[i].getBoundingClientRect().width) return all[i]; return all[0]; }
  var sw = document.querySelectorAll(".theme-switch button"), sws = [];
  for (var k = 0; k < sw.length; k++) { var q = sw[k].getBoundingClientRect(); sws.push(sw[k].getAttribute("data-theme-choice") + ":" + q.width.toFixed(0) + "x" + q.height.toFixed(0) + ":" + sw[k].getAttribute("aria-pressed")); }
  d.setAttribute("data-switch", sws.join(",") || "none");
  var img = shown(".site-header .brand img"), links = document.querySelectorAll(".site-header .site-nav a");
  var r = img.getBoundingClientRect(), name = document.querySelector(".site-header .brand span").getBoundingClientRect();
  var last = links[links.length - 1].getBoundingClientRect(), first = null;
  for (var i = 0; i < links.length; i++) { var b = links[i].getBoundingClientRect(); if (b.width) { first = b; break; } }
  var fi = shown(".site-footer .brand img").getBoundingClientRect(), fn = document.querySelector(".site-footer .brand span").getBoundingClientRect();
  d.setAttribute("data-hdr", ["icon", r.left, r.top, r.width, r.height, "iconmid", r.top + r.height / 2, "namemid", name.top + name.height / 2,
    "links", first.left, last.right, last.top + last.height / 2,
    "footer-iconmid", fi.top + fi.height / 2, "footer-namemid", fn.top + fn.height / 2, "footer-icon", fi.width].map(function (x) { return typeof x === "number" ? x.toFixed(1) : x; }).join(" "));
});
JS
# Chrome's window is at least 500 px wide, so every page is shown in an iframe of
# the exact width, centred, and the shot is cropped to it (sips crops from the centre).
cat > "$ROOT/frame.html" <<'HTML'
<!doctype html><html><head><style>html,body{margin:0;background:#808080}iframe{display:block;margin:0 auto;border:0}</style></head>
<body><iframe id="f"></iframe><script>
var q = new URLSearchParams(location.search), f = document.getElementById("f");
// The switch's stored choice, set before the page loads (same origin as the page).
if (q.get("theme")) localStorage.setItem("das-cam-theme", q.get("theme")); else localStorage.removeItem("das-cam-theme");
f.width = q.get("w"); f.height = q.get("h"); f.src = q.get("src");
f.onload = function () {
  var d = f.contentDocument.documentElement, r = document.documentElement, pv = q.get("pv") || "";
  if (pv) d.classList.add("pv-" + pv);
  if (pv === "hover" || pv === "focus") { // the switch's button that is not pressed, hovered or keyboard-focused
    var b = f.contentDocument.querySelector('.theme-switch button[aria-pressed="false"]');
    if (pv === "hover") { // copy the stylesheet's own :hover rules for the switch onto a class
      [].forEach.call(f.contentDocument.styleSheets, function (sh) { var rs; try { rs = sh.cssRules; } catch (e) { return; }
        [].slice.call(rs).forEach(function (rule) { if (rule.selectorText && rule.selectorText.indexOf("theme-switch") >= 0 && rule.selectorText.indexOf(":hover") >= 0)
          sh.insertRule(rule.cssText.replace(/:hover/g, ".pv-hover"), sh.cssRules.length); }); });
      b.classList.add("pv-hover");
    } else { f.contentWindow.focus(); b.focus(); }
    d.setAttribute("data-switch", d.getAttribute("data-switch") + " focus-visible:" + b.matches(":focus-visible"));
  }
  ["data-w", "data-h", "data-dark", "data-hdr", "data-switch"].forEach(function (k) { r.setAttribute(k, d.getAttribute(k) || ""); });
  var at = q.get("at") && f.contentDocument.getElementById(q.get("at"));
  if (at) f.contentWindow.scrollTo({ top: at.getBoundingClientRect().top - 16, behavior: "instant" });
};
</script></body></html>
HTML
# preview.css: looks shown only in previews, for AJ to compare. "pv-hero-dark" keeps
# the header and the hero dark gray (the dark page's colours) whatever the theme.
cat > "$ROOT/preview.css" <<'CSS'
.pv-hero-dark .site-header, .pv-hero-dark .hero {
  color-scheme: dark; --paper: #1a1b1f; --paper-2: #202125; --ink: #ece9e2; --ink-2: #a9a59c;
  --rule: rgb(236 233 226 / 0.14); --rule-strong: rgb(236 233 226 / 0.5); --frame: rgb(236 233 226 / 0.7);
  --grid: rgb(236 233 226 / 0.06); --mark: #ffd60a; --red-text: #ff7469; --btn-rec-hover: #ffffff;
  --shot-shadow: 0 14px 34px rgb(0 0 0 / 0.45); background-color: var(--paper); color: var(--ink);
}
.pv-hero-dark .site-header .icon-light, .pv-hero-dark .hero .icon-light { display: none !important; }
.pv-hero-dark .site-header .icon-dark, .pv-hero-dark .hero .icon-dark { display: block !important; }
CSS
for f in "$ROOT/index.html" "$ROOT"/*/index.html; do
  # Every image loads and decodes at once in a preview: a shot can end before a lazy or
  # async one is drawn, and then shows an empty box where the image belongs.
  sed -i '' -e 's#</head>#<link rel="stylesheet" href="/preview.css"><script src="/measure.js"></script></head>#' -e 's# loading="lazy"##g' -e 's# decoding="async"##g' "$f"
done
python3 -m http.server "$PORT" --bind 127.0.0.1 -d "$ROOT" >/dev/null 2>&1 &
SERVER=$!
trap 'kill $SERVER 2>/dev/null; rm -rf "${ROOT:?}"' EXIT
sleep 1
U="http://127.0.0.1:$PORT"
scheme() { [ "$1" = dark ] && echo "--blink-settings=preferredColorScheme=0" || echo "--blink-settings=preferredColorScheme=1"; }
win() { [ "$1" -lt 500 ] && echo 500 || echo "$1"; }
measure() { # path width mode -> "w h dark switch"
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars "$(scheme "$3")" --window-size="$(win "$2")",900 \
    --virtual-time-budget=4000 --dump-dom "$U/frame.html?w=$2&h=900&src=$1" 2>/dev/null |
    python3 -c 'import re,sys; s=sys.stdin.read(); print(*[re.search(k+r"=\"([^\"]*)\"", s).group(1).replace(" ","_") for k in ("data-w","data-h","data-dark","data-switch")])'
}
header() { # path width -> the header's icon box and link positions, for comparing pages
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars "$(scheme light)" --window-size="$(win "$2")",900 \
    --virtual-time-budget=4000 --dump-dom "$U/frame.html?w=$2&h=900&src=$1" 2>/dev/null |
    python3 -c 'import re,sys; s=sys.stdin.read(); m=re.search(r"data-hdr=\"([^\"]*)\"", s); print(m.group(1) if m else "none")'
}
MOTION="" # set to --force-prefers-reduced-motion for still, repeatable shots
shot() { # name path width mode scale full|top|<height>
  read -r w h dk swt < <(measure "$2" "$3" "$4")
  local height=$h; [ "$6" = top ] && height=$(( h < 1100 ? h : 1100 ))
  case "$6" in [0-9]*) height=$6 ;; esac   # a number: exactly one screen of that height
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars "$(scheme "$4")" --window-size="$(win "$3")","$height" ${MOTION:+"$MOTION"} \
    --force-device-scale-factor="$5" --virtual-time-budget=4000 --screenshot="$OUT/$1.png" \
    "$U/frame.html?w=$3&h=$height&src=$2" >/dev/null 2>&1
  sips -c $(( height * $5 )) $(( $3 * $5 )) "$OUT/$1.png" >/dev/null
  printf '%-30s width %4s  page width %4s %-8s height %5s  dark %-5s  switch %s\n' "$1" "$3" "$w" "$([ "$w" -le "$3" ] && echo ok || echo SIDEWAYS)" "$h" "$dk" "$swt"
}
if [ "$SET" = dark ]; then
  MOTION=--force-prefers-reduced-motion
  shot index-dark-top-1280x900         / 1280 dark 1 900
  shot index-dark-top-390x844          / 390 dark 2 844
  shot index-dark-1280                 / 1280 dark 1 full
  for u in / /privacy/ /pairing-protocol/; do
    for wd in 320 375 390; do
      read -r w h dk swt < <(measure "$u" "$wd" dark)
      printf 'check %-20s width %4s dark  page width %4s %s\n' "$u" "$wd" "$w" "$([ "$w" -le "$wd" ] && echo ok || echo SIDEWAYS)"
    done
  done
  exit 0
fi
if [ "$SET" = theme ]; then
  # Reduced motion stops the record dot's pulse, so two shots of the same page are byte-identical.
  MOTION=--force-prefers-reduced-motion
  # The whole home page in each mode (the device's setting, nothing stored).
  shot index-dark-390    / 390 dark 2 full
  shot index-light-390   / 390 light 2 full
  shot index-dark-1280   / 1280 dark 1 full
  shot index-light-1280  / 1280 light 1 full
  # The switch's choice over the device's setting: each must match the shot above it.
  shot forced-dark-on-light-device-390 "/&theme=dark" 390 light 2 full
  shot forced-light-on-dark-device-390 "/&theme=light" 390 dark 2 full
  cmp -s "$OUT/forced-dark-on-light-device-390.png" "$OUT/index-dark-390.png" && echo "check forced dark = device dark: identical" || echo "check forced dark = device dark: DIFFERENT"
  cmp -s "$OUT/forced-light-on-dark-device-390.png" "$OUT/index-light-390.png" && echo "check forced light = device light: identical" || echo "check forced light = device light: DIFFERENT"
  # The privacy page's top, in each mode.
  shot privacy-top-dark-390  /privacy/ 390 dark 2 844
  shot privacy-top-light-390 /privacy/ 390 light 2 844
  # The switch, hovered and keyboard-focused (the button that is not pressed).
  shot switch-hover-1280-dark  "/&pv=hover" 1280 dark 2 150
  shot switch-focus-1280-dark  "/&pv=focus" 1280 dark 2 150
  shot switch-hover-1280-light "/&pv=hover" 1280 light 2 150
  shot switch-focus-1280-light "/&pv=focus" 1280 light 2 150
  # The comparison: light mode with the header and hero kept dark gray, beside light mode as built.
  shot hero-light-as-built-1280  / 1280 light 1 900
  shot hero-light-kept-dark-1280 "/&pv=hero-dark" 1280 light 1 900
  shot hero-light-as-built-390   / 390 light 2 844
  shot hero-light-kept-dark-390  "/&pv=hero-dark" 390 light 2 844
  # No sideways scroll at 320, 375 and 390, either theme, every page.
  for u in / /privacy/ /pairing-protocol/; do
    for wd in 320 375 390; do
      for m in light dark; do
        read -r w h dk swt < <(measure "$u" "$wd" "$m")
        printf 'check %-20s width %4s %-5s page width %4s %-8s switch %s\n' "$u" "$wd" "$m" "$w" "$([ "$w" -le "$wd" ] && echo ok || echo SIDEWAYS)" "$swt"
      done
    done
  done
  exit 0
fi
shot home-1440-light / 1440 light 1 full
shot home-1440-dark  / 1440 dark 1 full
shot home-390-light  / 390 light 2 full
shot home-390-dark   / 390 dark 2 full
shot home-390-light-top / 390 light 2 top
shot home-390-dark-top  / 390 dark 2 top
shot home-390-controls-light "/&at=controls" 390 light 2 top
shot home-390-devices-dark "/&at=devices" 390 dark 2 top
shot sec-devices-1440-light "/&at=devices" 1440 light 1 top
# The hero as one screen at common sizes, the closing call and the footer.
shot hero-1440x900-light / 1440 light 1 900
shot hero-1440x900-dark  / 1440 dark 1 900
shot hero-390x844-light  / 390 light 2 844
shot hero-390x844-dark   / 390 dark 2 844
shot join-1440-light "/&at=join" 1440 light 1 top
shot join-390-dark   "/&at=join" 390 dark 2 top
shot join-320-light  "/&at=join" 320 light 2 top
shot footer-1440-dark "/&at=footer" 1440 dark 2 top
# The header on each page, for comparing them.
shot hdr-home-1440-light / 1440 light 2 top
shot hdr-privacy-1440-light /privacy/ 1440 light 2 top
shot hdr-pairing-1440-dark /pairing-protocol/ 1440 dark 2 top
shot hdr-home-390-dark / 390 dark 2 top
shot hdr-privacy-390-dark /privacy/ 390 dark 2 top
shot hdr-pairing-390-light /pairing-protocol/ 390 light 2 top
# The Pre-Recording section close up, both widths and both modes.
shot prerec-1440-light "/&at=features" 1440 light 1 top
shot prerec-1440-dark  "/&at=features" 1440 dark 1 top
shot prerec-390-light  "/&at=features" 390 light 2 top
shot prerec-390-dark   "/&at=features" 390 dark 2 top
# The Pre-Recording film strip close up.
shot strip-1440-light "/&at=clip-diagram" 1440 light 1 top
shot strip-1440-dark "/&at=clip-diagram" 1440 dark 1 top
shot strip-390-light "/&at=clip-diagram" 390 light 2 top
shot strip-390-dark "/&at=clip-diagram" 390 dark 2 top
# The maker section close up.
shot maker-1440-light "/&at=maker" 1440 light 1 top
shot maker-390-dark   "/&at=maker" 390 dark 2 top
# The Pairing and Camera controls sections close up (each beside its App Store image).
shot sec-pairing-1440-light "/&at=pairing" 1440 light 1 top
shot sec-pairing-390-dark   "/&at=pairing" 390 dark 2 top
shot sec-controls-1440-dark "/&at=controls" 1440 dark 1 top
shot sec-controls-1440-light "/&at=controls" 1440 light 1 top
shot sec-controls-390-light "/&at=controls" 390 light 2 top
shot sec-controls-320-dark "/&at=controls" 320 dark 2 top
shot sec-controls-390-dark "/&at=controls" 390 dark 2 top
# A section label close up (01 Pre-Recording), and the hero image on a desktop.
shot label-1440-light "/&at=features" 1440 light 2 top
shot hero-1440-dark "/" 1440 dark 1 top
# The beta section (what you need, feedback) close up.
shot beta-1440-light "/&at=requirements" 1440 light 1 top
shot beta-390-dark   "/&at=feedback" 390 dark 2 top
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
# The header must sit identically on every page.
for wd in 1440 390; do
  for u in / /privacy/ /pairing-protocol/; do
    printf 'header %-20s width %4s  %s\n' "$u" "$wd" "$(header "$u" "$wd")"
  done
done
