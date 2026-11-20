#!/bin/bash
# Builds the screenshots' two larger files from AJ's PNG originals (WEB-ZOOM1).
#   _tools/make-shots.sh <dir holding T1.png to T5.png>
# Tn.png becomes assets/shots/shot-n-1080.jpg and shot-n-2950.jpg:
# - 1080 wide: the page's size for a 3x phone. sips, quality 60, baseline, the
#   same as the 400 and 720 files (WEB-SHOTS2).
# - 2950 wide: every pixel of the original, opened full size by assets/zoom.js.
#   cjpeg quality 80, no chroma subsampling (4:4:4, so coloured text stays
#   sharp), progressive and optimised: about 1 to 2 MB each.
# Then every APPn and COM segment is removed: no EXIF, no location, no ICC,
# Photoshop or JFIF block. The originals are only read. Needs sips, ffmpeg and
# cjpeg (libjpeg-turbo).
set -euo pipefail
SRC="${1:?usage: _tools/make-shots.sh <dir holding T1.png to T5.png>}"
OUT="$(cd "$(dirname "$0")/.." && pwd)/assets/shots"
TMP="$(mktemp -d)"; trap 'rm -rf "${TMP:?}"' EXIT
for n in 1 2 3 4 5; do
  png="$SRC/T$n.png"
  [ -f "$png" ] || { echo "missing $png" >&2; exit 1; }
  sips -s format jpeg -s formatOptions 60 --resampleWidth 1080 "$png" --out "$TMP/shot-$n-1080.jpg" >/dev/null
  ffmpeg -loglevel error -y -i "$png" -pix_fmt rgb24 -f image2 -c:v ppm "$TMP/T$n.ppm"
  cjpeg -quality 80 -sample 1x1 -optimize -progressive -outfile "$TMP/shot-$n-2950.jpg" "$TMP/T$n.ppm"
  for size in 1080 2950; do
    python3 - "$TMP/shot-$n-$size.jpg" "$OUT/shot-$n-$size.jpg" <<'PY'
import struct, sys
b = open(sys.argv[1], "rb").read()
assert b[:2] == b"\xff\xd8", "not a JPEG"
out, i = [b[:2]], 2
while True:
    assert b[i] == 0xFF, "bad marker at %d" % i
    m = b[i + 1]
    if m == 0xDA:  # start of scan: the rest is image data
        out.append(b[i:]); break
    n = struct.unpack(">H", b[i + 2:i + 4])[0]
    if not (0xE0 <= m <= 0xEF or m == 0xFE):  # drop APP0 to APP15 and comments
        out.append(b[i:i + 2 + n])
    i += 2 + n
open(sys.argv[2], "wb").write(b"".join(out))
PY
    printf '%s  %s x %s  %s bytes\n' "shot-$n-$size.jpg" \
      "$(sips -g pixelWidth "$OUT/shot-$n-$size.jpg" | awk '/pixelWidth/ {print $2}')" \
      "$(sips -g pixelHeight "$OUT/shot-$n-$size.jpg" | awk '/pixelHeight/ {print $2}')" \
      "$(stat -f %z "$OUT/shot-$n-$size.jpg")"
  done
  rm -f "$TMP/T$n.ppm"
done
