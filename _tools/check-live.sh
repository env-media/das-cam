#!/bin/bash
# After a publish: checks the live site.
#   _tools/check-live.sh <expected-short-sha> <baseline-privacy.html>
# 1. GitHub Pages' latest build is "built" at the expected commit.
# 2. index, privacy/ and pairing-protocol/ read 200; no page loads anything from
#    another host (no "cdnjs", no outside src, no outside <link href>). Outside <a href>
#    links are listed: they are followed only when tapped.
# 3. The privacy policy's words match the baseline (a saved copy of the live page
#    before the change), byte for byte and as text.
# Exit 0 only when every check passes.
set -uo pipefail
SHA="${1:?usage: check-live.sh <sha> <baseline-privacy.html>}"
BASE="${2:?usage: check-live.sh <sha> <baseline-privacy.html>}"
LIVE="https://env-media.github.io/das-cam"
TMP="$(mktemp -d)"; trap 'rm -rf "${TMP:?}"' EXIT
fail=0
build="$(gh api repos/env-media/das-cam/pages/builds/latest --jq '.status + " " + .commit[0:7]' 2>&1)"
if [ "$build" = "built $SHA" ]; then echo "ok    build: $build"; else echo "FAIL  build: $build (want built $SHA)"; fail=1; fi
for page in "" privacy/ pairing-protocol/; do
  f="$TMP/$(echo "${page:-index}" | tr -d /).html"
  code="$(curl -s -H 'Cache-Control: no-cache' -o "$f" -w '%{http_code}' "$LIVE/$page?nocache=$RANDOM")"
  python3 - "$f" "/${page}" "$code" <<'PY' || fail=1
import re, sys
f, name, code = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(f, encoding="utf-8").read()
bad = []
if code != "200": bad.append(f"status {code}")
if "cdnjs" in s: bad.append('"cdnjs" present')
for m in re.finditer(r'<(script|img|iframe|source|video|audio|embed|object)\b[^>]*\b(?:src|srcset|data)="(https?:)?//[^"]*"', s, re.I):
    bad.append("outside load: " + m.group(0)[:120])
for m in re.finditer(r'<link\b[^>]*\bhref="(https?:)?//[^"]*"[^>]*>', s, re.I):
    bad.append("outside link: " + m.group(0)[:120])
for m in re.finditer(r'url\(\s*["\']?(https?:)?//', s, re.I):
    bad.append("outside url(): " + s[m.start():m.start()+80])
links = sorted(set(re.findall(r'<a\b[^>]*\bhref="(https?://[^"]*)"', s, re.I)))
print(("ok   " if not bad else "FAIL ") + f" {name:20} status {code}; outside <a> links: {len(links)}")
for b in bad: print("        " + b)
for l in links: print("        link " + l)
sys.exit(1 if bad else 0)
PY
done
python3 - "$BASE" "$TMP/privacy.html" <<'PY' || fail=1
import re, sys, html
def body(s):
    m = re.search(r'<main id="main" class="prose">\s*<div class="wrap">\n(.*?)\n  </div>\s*</main>', s, re.S)   # this site's layout
    if m: return m.group(1)
    m = re.search(r'<div class="container-lg px-3 my-5 markdown-body">(.*?)</div>\s*<script', s, re.S)     # the GitHub theme's
    b = m.group(1)
    return re.sub(r'^\s*<h1><a href="[^"]*">[^<]*</a></h1>', '', b)
text = lambda b: re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]+>', ' ', b))).strip()
a, b = body(open(sys.argv[1], encoding="utf-8").read()), body(open(sys.argv[2], encoding="utf-8").read())
same_bytes, same_text = a.strip() == b.strip(), text(a) == text(b)
print(("ok   " if same_bytes and same_text else "FAIL ") + f" policy words: kramdown output identical {same_bytes}; text identical {same_text}; {len(text(a).split())} words")
sys.exit(0 if same_bytes and same_text else 1)
PY
[ "$fail" = 0 ] && echo "ALL CHECKS PASS" || echo "SOME CHECKS FAILED"
exit "$fail"
