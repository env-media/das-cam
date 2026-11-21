#!/usr/bin/env python3
"""Draws the Focus and Exposure cards as an iPhone held upright and writes them into index.html.

    python3 _tools/draw-controls.py        (edits index.html beside this folder, in place)

The screen is drawn in the app's own points (393 x 852, an iPhone 15 or 16), and every focus and exposure
element copies the app's source, read from the DSC repo on 2026-11-20 (WEB-COPY2):
  - the reticles: DSC/Views/Camera/ReticleOutline.swift (2-pt outline; square corner radius 4) and
    FocusExposureOverlay.reticles in DSC/Views/Camera/FocusExposureControl.swift (focus = red 84-pt square tagged
    "AF", exposure = yellow 72-pt circle tagged "AE"; the tag is 10-pt bold white on a capsule of the tint at 60 %);
  - the panels: FocusExposureOverlay.panel, FocusWheel and ExposureWheel in the same file (black 50 % plate,
    corner 12; a 36-pt focus track with 21 ticks, red fill; ISO and shutter strips of 34 pt, yellow and orange
    fills; the AUTO | MAN chips below), bottom-anchored between the corner groups and the zoom row, focus on the
    left edge and exposure on the right;
  - the zoom row: FocusExposureEntryButton (44 x 38 tiles, "FOCUS" / "EXPOS" over the mode, the tint at 80 % when
    open, black 45 % when closed), WheelLockButton (34 x 30) and ZoomStopBar (36-pt stops, the active one yellow);
  - Record: DSC/Views/Camera/RecordButton.swift (72-pt white ring, 58-pt red disc).
The colours are SwiftUI's system colours in dark appearance, which the App Store shots show (sampled from
assets/shots/shot-1-2950.jpg: the AF square #FF4131, the AE circle #FFD700). Everything else on the screen (the
corner groups, the readout, the side buttons) is drawn as plain shapes, so the two subjects stand out.
"""
import importlib.util, math, os, re

SITE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RED, YELLOW, ORANGE, FIG = "#FF453A", "#FFD60A", "#FF9F0A", "#f1eee7"
W, H = 393, 852
GHOST = 'fill="rgb(10 12 16 / 0.5)" stroke="rgb(255 255 255 / 0.16)" stroke-width="1"'

spec = importlib.util.spec_from_file_location("strip", os.path.join(SITE, "_tools", "draw-strip.py"))
strip = importlib.util.module_from_spec(spec)
spec.loader.exec_module(strip)


def text(x, y, s, size, weight=400, fill="#ffffff", opacity=1.0, cls="", anchor="middle"):
    c = f' class="{cls}"' if cls else ""
    o = f' fill-opacity="{opacity}"' if opacity < 1 else ""
    return (f'<text x="{x}" y="{y}"{c} font-size="{size}" font-weight="{weight}" fill="{fill}"{o} '
            f'text-anchor="{anchor}" dominant-baseline="central">{s}</text>')


def rect(x, y, w, h, r, attrs):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" {attrs}/>'


def tag(cx, cy, label, tint):
    # The reticle's badge: offset(y: -(size / 2) - 10), padding 4 x 1, Capsule().fill(tint.opacity(0.6)).
    w = 21 if label == "AF" else 22
    return rect(cx - w / 2, cy - 7, w, 14, 7, f'fill="{tint}" fill-opacity="0.6"') + text(cx, cy, label, 10, 700)


def reticles():
    fx, fy, ex, ey = 228, 337, 148, 448
    focus = rect(fx - 42, fy - 42, 84, 84, 4, f'fill="none" stroke="{RED}" stroke-width="2"') + tag(fx, fy - 52, "AF", RED)
    exposure = (f'<circle cx="{ex}" cy="{ey}" r="36" fill="none" stroke="{YELLOW}" stroke-width="2"/>'
                + tag(ex, ey - 46, "AE", YELLOW))
    return focus + exposure


def chip(x, label, active, tint):
    # A mode chip: minWidth 34 + 4 each side, minHeight 30, corner 8; the active one in the tint, black words.
    fill = f'fill="{tint}"' if active else 'fill="rgb(255 255 255 / 0.15)"'
    return rect(x, 596, 42, 30, 8, fill) + text(x + 21, 611, label, 10, 800, "#000000" if active else "#ffffff")


def capsule_fill(x, top, bottom, width, fraction, colour):
    # The track: Capsule white 20 %; the value: Capsule of the tint at 80 %, rising from the bottom (8 pt at least).
    r = width / 2
    height = bottom - top
    filled = max(8, height * fraction)
    return (rect(x, top, width, height, r, 'fill="rgb(255 255 255 / 0.2)"')
            + rect(x, bottom - filled, width, filled, min(r, filled / 2), f'fill="{colour}" fill-opacity="0.8"'))


def focus_panel():
    # The band: below the corner groups (bottom 127 + 8) to above the zoom row (top 640 - 8). Padding 4 + 6.
    out = [rect(4, 135, 98, 497, 12, 'fill="#000000" fill-opacity="0.5"')]
    out.append(text(28, 147, "FOCUS", 10, 700, opacity=0.7))
    out.append(text(28, 167, "0.62", 13, 600, cls="fe-mono"))
    out.append(capsule_fill(10, 181, 590, 36, 0.62, RED))
    ticks = []
    for i in range(21):   # FocusWheelTickMarks: inset 2, a long tick every fifth.
        y = 588 - i / 20 * 405
        half = 32 * (0.32 if i % 5 == 0 else 0.18)
        ticks.append(f"M{28 - half:.2f} {y:.2f}H{28 + half:.2f}")
    out.append(f'<path d="{"".join(ticks)}" stroke="rgb(255 255 255 / 0.35)" stroke-width="1" fill="none"/>')
    out += [chip(10, "AUTO", True, RED), chip(54, "MAN", False, RED)]
    return "".join(out)


def exposure_panel():
    out = [rect(291, 135, 98, 497, 12, 'fill="#000000" fill-opacity="0.5"')]
    out.append(text(343, 147, "EXPOSURE", 10, 700, opacity=0.7))
    out.append(text(320, 164.5, "ISO", 9, 700, opacity=0.6))
    out.append(text(320, 181.5, "400", 12, 600, cls="fe-mono"))
    out.append(capsule_fill(303, 193, 590, 34, 0.28, YELLOW))
    out.append(text(366, 166, "180°", 11, 600))
    out.append(text(366, 184, "1/60", 11, 400, opacity=0.8, cls="fe-mono"))
    out.append(capsule_fill(349, 195, 590, 34, (180 - 1) / 359, ORANGE))
    out += [chip(297, "AUTO", True, YELLOW), chip(341, "MAN", False, YELLOW)]
    return "".join(out)


def tile(x, word, open_tint):
    fill = f'fill="{open_tint}" fill-opacity="0.8"' if open_tint else 'fill="#000000" fill-opacity="0.45"'
    return (rect(x, 647, 44, 38, 8, fill) + text(x + 22, 660, word, 8, 700, opacity=0.7)
            + text(x + 22, 671.5, "AUTO", 9, 800))


def lock(x):
    # WheelLockButton, not engaged: "lock.open" on white 15 %, corner 8. Shown only while its panel is open.
    # The open shackle rises from the body's right half and hangs free past its right edge.
    cx, cy = x + 17, 667
    return (rect(x, 651, 34, 30, 8, 'fill="rgb(255 255 255 / 0.15)"')
            + rect(cx - 7, cy - 1, 9, 7.5, 1.8, 'fill="#ffffff"')
            + f'<path d="M{cx + 0.5} {cy - 1}V{cy - 4.5}a2.75 2.75 0 0 1 5.5 0V{cy - 3.2}" fill="none" '
              'stroke="#ffffff" stroke-width="1.8" stroke-linecap="round"/>')


def zoom_row(open_axis):
    out = [tile(12, "FOCUS", RED if open_axis == "focus" else None),
           tile(337, "EXPOS", YELLOW if open_axis == "exposure" else None),
           lock(60) if open_axis == "focus" else lock(299)]
    out.append(rect(114.5, 640, 164, 52, 26, 'fill="#000000" fill-opacity="0.4"'))
    for cx, label, active in ((148.5, "0.5", False), (196.5, "1", True), (244.5, "2", False)):
        out.append(f'<circle cx="{cx}" cy="666" r="18" fill="{YELLOW if active else "rgb(255 255 255 / 0.2)"}"/>')
        out.append(text(cx, 666, label, 13, 700 if active else 400, "#000000" if active else "#ffffff", cls="fe-round"))
    return "".join(out)


def chrome():
    out = ['<rect x="134" y="11" width="125" height="37" rx="18.5" fill="#000000"/>']
    for cx in (29, 364):
        out.append(f'<circle cx="{cx}" cy="66" r="17" {GHOST}/>')
    for x, y, w in ((62, 49, 56), (12, 93, 58), (76, 93, 54), (275, 49, 56), (263, 93, 54), (323, 93, 58)):
        out.append(rect(x, y, w, 34, 17, GHOST))
    out += [rect(153, 54, 87, 28, 14, GHOST), rect(165, 88, 63, 26, 13, GHOST)]
    out.append(rect(12, 712, 56, 56, 10, GHOST))
    for cx in (98, 296, 350):
        out.append(f'<circle cx="{cx}" cy="740" r="22" {GHOST}/>')
    out.append(f'<circle cx="196.5" cy="740" r="36" fill="none" stroke="#ffffff" stroke-width="4"/>'
               f'<circle cx="196.5" cy="740" r="29" fill="{RED}"/>')
    out.append('<rect x="130" y="836" width="133" height="5" rx="2.5" fill="rgb(255 255 255 / 0.55)"/>')
    return "".join(out)


def standing(*args):
    """strip.person, with its side-view boots swapped for feet seen from the front (WEB-FEET1, AJ 11-21): each a short
    rounded shape whose heel sits under the ankle and whose toe points down the page and 25 degrees outward, the left
    foot to the left and the right to the right, so no toe rises above its sole."""
    ankles = []
    side_view = strip.capsule

    def capsule(p1, p2, w1, w2):
        if (w1, w2) == (3.8, 2.6):   # the boot: ankle to toe
            ankles.append(p1)
            return ""
        return side_view(p1, p2, w1, w2)

    strip.capsule = capsule
    try:
        body = strip.person(*args)
    finally:
        strip.capsule = side_view
    feet = []
    for ankle in ankles:
        out = -1 if ankle[0] < 0 else 1
        heel = (ankle[0], ankle[1] + 0.6)
        toe = (heel[0] + out * 3.0 * math.sin(math.radians(25)), heel[1] + 3.0 * math.cos(math.radians(25)))
        feet.append(side_view(heel, toe, 3.4, 4.0))
    return body + "".join(feet)


def scene(k):
    person = standing((0, 0), 180, False, 0, ((-10, -4), (10, 4)), ((-4, 0, 90), (4, 0, 90)))
    return (f'<rect width="{W}" height="{H}" fill="url(#fe-sky-{k})"/>'
            '<rect y="600" width="393" height="252" fill="#2a302a"/>'
            f'<g fill="{FIG}" transform="translate(228 470) scale(5)">{person}</g>')


def device(k, axis):
    panel = focus_panel() if axis == "focus" else exposure_panel()
    return (f'<svg viewBox="-12 -12 417 876" aria-hidden="true" focusable="false">'
            f'<defs><clipPath id="fe-screen-{k}"><rect width="{W}" height="{H}" rx="55"/></clipPath>'
            f'<linearGradient id="fe-sky-{k}" x1="0" y1="0" x2="0" y2="1">'
            '<stop offset="0" stop-color="#4c5462"/><stop offset="0.7" stop-color="#2c3037"/></linearGradient></defs>'
            '<rect class="device-edge" x="-10.5" y="-10.5" width="414" height="873" rx="64"/>'
            f'<g clip-path="url(#fe-screen-{k})">' + scene(k) + chrome() + reticles() + panel + zoom_row(axis)
            + "</g></svg>")


def main():
    path = os.path.join(SITE, "index.html")
    html = open(path, encoding="utf-8").read()
    for k, axis in (("f", "focus"), ("e", "exposure")):
        pat = re.compile(r'(<div class="device device-%s"[^>]*>)<svg.*?</svg>(</div>)' % axis, re.S)
        html, count = pat.subn(lambda m: m.group(1) + device(k, axis) + m.group(2), html)
        assert count == 1, f"{axis}: {count} matches"
    open(path, "w", encoding="utf-8").write(html)
    print("wrote the focus and exposure devices")


if __name__ == "__main__":
    main()
