#!/usr/bin/env python3
"""Draws the Pre-Recording film strip's eight frames as flat silhouettes and writes them into index.html.

    python3 _tools/draw-strip.py        (edits index.html beside this folder, in place)

Each figure is built from a skeleton: joint angles per pose, limbs drawn as tapered shapes, so the
proportions stay real (about eight heads tall) and the kit shows in the outline (sleeves, shorts, boots).
Drawn for this site from scratch; nothing is traced from any image.
Angles: 0 points straight down, 90 to the right, -90 to the left, 180 straight up.
The frame is 90 x 120 units (3:4), the ground at y = 100.
"""
import math, os, re

FIG = "#f1eee7"
SITE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def v(theta, length):
    r = math.radians(theta)
    return (math.sin(r) * length, math.cos(r) * length)

def add(p, q):
    return (p[0] + q[0], p[1] + q[1])

def lerp(p, q, t):
    return (p[0] + (q[0] - p[0]) * t, p[1] + (q[1] - p[1]) * t)

def capsule(p1, p2, w1, w2):
    dx, dy = p2[0] - p1[0], p2[1] - p1[1]
    length = math.hypot(dx, dy) or 1e-6
    nx, ny = -dy / length, dx / length
    pts = [(p1[0] + nx * w1 / 2, p1[1] + ny * w1 / 2), (p2[0] + nx * w2 / 2, p2[1] + ny * w2 / 2),
           (p2[0] - nx * w2 / 2, p2[1] - ny * w2 / 2), (p1[0] - nx * w1 / 2, p1[1] - ny * w1 / 2)]
    poly = " ".join(f"{x:.1f},{y:.1f}" for x, y in pts)
    return (f'<polygon points="{poly}"/><circle cx="{p1[0]:.1f}" cy="{p1[1]:.1f}" r="{w1 / 2:.2f}"/>'
            f'<circle cx="{p2[0]:.1f}" cy="{p2[1]:.1f}" r="{w2 / 2:.2f}"/>')

def person(hip, torso=180, profile=False, head_tilt=0, arms=((-8, -4), (8, 4)), legs=((-4, 0, 90), (4, 0, 90))):
    """hip: centre of the hips. torso: angle from hips to neck. arms: (upper, fore) for the left or back
    arm, then the right or front one. legs: (thigh, shin, foot) in the same order."""
    d = v(torso, 1)
    p = (-d[1], d[0])
    neck = add(hip, v(torso, 21))
    sw, hw = (2.2, 1.6) if profile else (6.8, 4.2)
    shoulders = [add(add(neck, v(torso, -2.2)), (p[0] * s * sw, p[1] * s * sw)) for s in (-1, 1)]
    hips = [(hip[0] + p[0] * s * hw, hip[1] + p[1] * s * hw) for s in (-1, 1)]
    out = []
    for (thigh, shin, foot), h in zip(legs, hips):
        knee = add(h, v(thigh, 14.5))
        ankle = add(knee, v(shin, 14))
        toe = add(ankle, v(foot, 4.6))
        out += [capsule(h, knee, 7.4, 5.4), capsule(h, lerp(h, knee, 0.5), 9.0, 8.2),   # thigh, shorts
                capsule(knee, ankle, 5.4, 3.3), capsule(knee, lerp(knee, ankle, 0.45), 5.6, 5.2),  # shin, calf
                capsule(ankle, toe, 3.8, 2.6)]                                           # boot
    if profile:
        out.append(capsule(hip, add(neck, v(torso, -1.5)), 9.6, 10.4))
    else:
        hem = [(hips[0][0] - p[0] * 1.2, hips[0][1] - p[1] * 1.2), (hips[1][0] + p[0] * 1.2, hips[1][1] + p[1] * 1.2)]
        out.append('<polygon points="%s"/>' % " ".join(f"{x:.1f},{y:.1f}" for x, y in (shoulders[0], shoulders[1], hem[1], hem[0])))
        out += [f'<circle cx="{s[0]:.1f}" cy="{s[1]:.1f}" r="3.2"/>' for s in shoulders]
    head = add(neck, v(torso + head_tilt, 5.6))
    out.append(capsule(neck, head, 3.8, 3.8))
    hd = v(torso + head_tilt, 1)
    turn = math.degrees(math.atan2(hd[0], -hd[1]))
    out.append(f'<ellipse cx="{head[0]:.1f}" cy="{head[1]:.1f}" rx="3.5" ry="4.2" transform="rotate({turn:.1f} {head[0]:.1f} {head[1]:.1f})"/>')
    for (upper, fore), s in zip(arms, shoulders):
        elbow = add(s, v(upper, 11))
        wrist = add(elbow, v(fore, 9.6))
        hand = add(wrist, v(fore, 1.4))
        out += [capsule(s, elbow, 4.8, 3.9), capsule(s, lerp(s, elbow, 0.42), 6.4, 6.0),    # upper arm, sleeve
                capsule(elbow, wrist, 3.9, 3.0), f'<circle cx="{hand[0]:.1f}" cy="{hand[1]:.1f}" r="2.1"/>']
    return "".join(out)

def ball(x, y):
    return (f'<circle cx="{x}" cy="{y}" r="3.6" fill="#ffffff" stroke="#23262d" stroke-width="0.8"/>'
            f'<circle cx="{x}" cy="{y}" r="1.2" fill="#23262d"/>')

def goal(n):
    # Seen from the side: the post on the goal line, the top bar, and the back of the net sloping to the
    # ground, with a diamond mesh clipped to the net's outline (n keeps each frame's clip id unique).
    mesh = []
    for i in range(-12, 14):
        x = 66 + i * 4
        mesh.append(f"M{x} 22L{x + 39} 100M{x + 39} 22L{x} 100")
    return (f'<defs><clipPath id="net{n}"><path d="M66 22H76L88 100H66Z"/></clipPath></defs>'
            '<g fill="none" stroke-linecap="round">'
            f'<path d="{" ".join(mesh)}" clip-path="url(#net{n})" stroke="rgb(241 238 231 / 0.3)" stroke-width="0.7"/>'
            '<path d="M66 100V22H76L88 100" stroke="#d9d6cf" stroke-width="2.4"/></g>')

def frame(body):
    return ('<svg class="scene-svg" viewBox="0 0 90 120" preserveAspectRatio="xMidYMax meet" aria-hidden="true" focusable="false">'
            '<rect x="0" y="100" width="90" height="20" fill="#1e231e"/>' + body + "</svg>")

def g(*figures):
    return f'<g fill="{FIG}">' + "".join(figures) + "</g>"

FRAMES = {
    # Kept by Pre-Recording: line up, run up, kick, the ball in the net.
    1: frame(goal(1) + g(person((22, 69), 174, True, 8, ((-6, -2), (14, 22)), ((-2, 1, 90), (6, 2, 90)))) + ball(32, 96.4)),
    2: frame(goal(2) + g(person((28, 70), 164, True, 10, ((-45, -15), (55, 115)), ((28, -6, 95), (-35, -100, -130)))) + ball(43, 96.4)),
    3: frame(goal(3) + g(person((24, 69), 192, True, -6, ((-70, -20), (95, 120)), ((-6, 6, 90), (62, 82, 100))))
             + '<g stroke="rgb(241 238 231 / 0.5)" stroke-width="1.2" stroke-linecap="round"><path d="M52 66.5H57M53 70.5L57 69"/></g>'
             + ball(61, 65)),
    4: frame(goal(4) + g(person((26, 69), 180, True, -14, ((-155, -170), (150, 165)), ((-3, 0, 90), (5, 1, 90))))
             + ball(78, 90) + '<rect x="70.5" y="82.5" width="15" height="15" fill="none" stroke="#ffd60a" stroke-width="1.4"/>'),
    # Recorded after the tap: the celebration and the lift.
    5: frame(g(person((45, 69), 180, False, 0, ((-148, -162), (148, 162)), ((-7, -2, -80), (12, -22, 80))))),
    6: frame(g(person((22, 71), 165, True, 6, ((-40, -10), (80, 95)), ((25, -5, 95), (-18, -55, -110))),
               person((45, 69), 180, False, 0, ((-152, -170), (152, 170)), ((-5, 0, -80), (5, 0, 80))),
               person((68, 71), 195, True, -6, ((40, 10), (-80, -95)), ((-25, 5, -95), (18, 55, 110))))),
    7: frame(g(person((31, 69), 180, False, -6, ((-150, -170), (168, -175)), ((-4, 0, -80), (4, 0, 80))),
               person((59, 69), 180, False, 6, ((-168, 175), (150, 170)), ((-4, 0, -80), (4, 0, 80))),
               person((45, 41), 180, False, 0, ((-140, -155), (140, 155)), ((-28, -6, -80), (28, 6, 80))))),
    8: frame(g(person((31, 69), 180, False, -6, ((-160, -178), (168, -175)), ((-4, 0, -80), (4, 0, 80))),
               person((59, 69), 180, False, 6, ((-168, 175), (160, 178)), ((-4, 0, -80), (4, 0, 80))),
               person((45, 41), 180, False, 4, ((-140, -155), (160, 180)), ((-28, -6, -80), (28, 6, 80))))),
}

def main():
    path = os.path.join(SITE, "index.html")
    html = open(path, encoding="utf-8").read()
    for n, svg in FRAMES.items():
        pat = re.compile(r'(<div class="frame[^"]* f%d">)<svg class="scene-svg".*?</svg>(</div>)' % n, re.S)
        html, count = pat.subn(lambda m: m.group(1) + svg + m.group(2), html)
        assert count == 1, f"frame {n}: {count} matches"
    open(path, "w", encoding="utf-8").write(html)
    print("wrote 8 frames")

if __name__ == "__main__":
    main()
