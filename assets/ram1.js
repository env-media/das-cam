// WEB-RAM1: the "Smart Buffering" picture in the Pre-Recording section of index.html.
// Waiting: the camera sends frames into a ring of eight places in memory; the ring turns one place per frame, so the
// place at the entry always holds the oldest frame, which the new one replaces. Record: the frames in memory move, oldest
// first, to the start of the saved video, and new frames follow them. It is a simplified picture (the app keeps and
// replaces groups of frames), and it runs only while its disclosure is open and on screen. With reduced motion it is a
// still picture of each state.
(function () {
  var root = document.querySelector(".ram");
  if (!root) return;
  var details = root.closest("details");
  var svg = root.querySelector(".ram-svg");
  var layer = svg.querySelector(".ram-frames");
  var marks = svg.querySelector(".ram-marks");
  var live = root.querySelector(".ram-live");
  var record = root.querySelector('[data-ram="record"]');
  var reset = root.querySelector('[data-ram="reset"]');
  var reduce = window.matchMedia ? matchMedia("(prefers-reduced-motion: reduce)") : { matches: false };
  var NS = "http://www.w3.org/2000/svg";
  var SLOTS = 8, CELLS = 12, CX = 235, CY = 74, R = 52, CAMERA = [99, 74], HEAD = [CX - R, CY];
  var EVERY = 650, FLY = 420, TURN = 380, FADE = 260, HANDOVER = 620, STAGGER = 70;
  var TEXT = {
    wait: root.querySelector(".ram-state-wait").textContent,
    rec: root.querySelector(".ram-state-rec").textContent,
    done: root.querySelector(".ram-state-done").textContent
  };

  function el(name, attrs, parent) {
    var e = document.createElementNS(NS, name);
    for (var k in attrs) e.setAttribute(k, attrs[k]);
    if (parent) parent.appendChild(e);
    return e;
  }
  function cell(i) { return [35.25 + i * 24.5, 179]; }
  function angle(slot, turn) { return (180 - 45 * slot + turn) * Math.PI / 180; }
  function onRing(slot, turn) { var a = angle(slot, turn); return [CX + R * Math.cos(a), CY + R * Math.sin(a)]; }
  function ease(t) { return t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2; }
  function lerp(a, b, t) { return [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t]; }
  function place(f, p) { f.el.setAttribute("transform", "translate(" + p[0].toFixed(2) + " " + p[1].toFixed(2) + ")"); }

  // The fixed guides: the ring's eight places and the saved video's twelve.
  var slots = svg.querySelector(".ram-slots"), cells = svg.querySelector(".ram-cells");
  for (var i = 0; i < SLOTS; i++) {
    var p = onRing(i, 0);
    el("rect", { class: "ram-slot", x: (p[0] - 10).toFixed(2), y: (p[1] - 7).toFixed(2), width: 20, height: 14, rx: 3 }, slots);
  }
  for (var j = 0; j < CELLS; j++) {
    var c = cell(j);
    el("rect", { class: "ram-cell", x: c[0] - 10, y: c[1] - 7, width: 20, height: 14, rx: 3 }, cells);
  }

  var state, clock, written, turn, turnFrom, turnTo, turnAt, ring, flying, saved, nextEmit, raf, last, running = false;

  function frame(isLive) {
    var g = el("g", { class: "ram-frame" + (isLive ? " is-live" : "") }, layer);
    el("rect", { x: -10, y: -7, width: 20, height: 14, rx: 3 }, g);
    el("path", { class: "ram-scene", d: "M-7 4.5l4.2-5 3 3.4 2.3-2.4 4.5 4z" }, g);
    return { el: g };
  }
  function ages() {
    for (var s = 0; s < SLOTS; s++) {
      var f = ring[s];
      if (f) f.el.setAttribute("opacity", (1 - 0.07 * (written - 1 - f.n)).toFixed(2));
    }
  }
  function announce(name) {
    root.setAttribute("data-state", name);
    live.textContent = TEXT[name];
    record.disabled = name !== "wait";
    reset.disabled = name === "wait";
  }
  function drawMarks(pre) {
    while (marks.firstChild) marks.removeChild(marks.firstChild);
    var x = pre === 0 ? cell(0)[0] - 12.25 : cell(pre - 1)[0] + 12.25;
    el("line", { class: "ram-tap", x1: x, y1: 158, x2: x, y2: 200 }, marks);
    if (pre > 0) {
      var t = el("text", { class: "ram-mark-label", x: (cell(0)[0] + cell(pre - 1)[0]) / 2, y: 214 }, marks);
      t.textContent = pre > 2 ? "Before the tap" : "Before";
    }
    var u = el("text", { class: "ram-mark-label", x: (cell(pre)[0] + cell(CELLS - 1)[0]) / 2, y: 214 }, marks);
    u.textContent = "After the tap";
  }

  function clear() {
    while (layer.firstChild) layer.removeChild(layer.firstChild);
    while (marks.firstChild) marks.removeChild(marks.firstChild);
    clock = 0; written = 0; turn = 0; turnFrom = 0; turnTo = 0; turnAt = -1;
    ring = []; flying = []; saved = 0; nextEmit = 0;
  }

  // Reduced motion: each state as a still picture.
  function still(name) {
    clear();
    if (name === "wait") {
      for (var k = 0; k < SLOTS; k++) { var f = frame(false); f.n = k; ring[k] = f; }
      written = SLOTS; turn = 45 * SLOTS;
      for (var s = 0; s < SLOTS; s++) place(ring[s], onRing(s, turn));
      ages();
    } else {
      for (var c = 0; c < CELLS; c++) place(frame(c >= SLOTS), cell(c));
      drawMarks(SLOTS);
      name = "done";
    }
    announce(name);
  }

  function emit() {
    var f = frame(state !== "wait");
    f.n = written;
    place(f, CAMERA);
    if (state === "wait") {
      f.path = [CAMERA, HEAD]; f.at = clock; f.dur = FLY;
      f.land = function () { land(f); };
    } else {
      var to = cell(saved++);
      f.path = [CAMERA, HEAD, to]; f.at = clock; f.dur = FLY + HANDOVER;
      f.land = function () { if (saved >= CELLS && !flying.length) finish(); };
    }
    written++;
    flying.push(f);
  }
  function land(f) {
    var s = f.n % SLOTS;
    var old = ring[s];
    if (old) {
      old.el.setAttribute("opacity", "0");
      setTimeout(function () { if (old.el.parentNode) old.el.parentNode.removeChild(old.el); }, FADE);
    }
    ring[s] = f;
    ages();
    turnFrom = turn; turnTo = 45 * (f.n + 1); turnAt = clock;
  }
  function finish() { state = "done"; announce("done"); }

  function startRecording() {
    if (state !== "wait") return;
    // Land anything still on its way, then hand the frames over, oldest first.
    var landing = flying; flying = [];
    landing.forEach(function (f) { place(f, f.path[f.path.length - 1]); if (f.land) f.land(); });
    for (var s = 0; s < SLOTS; s++) if (ring[s]) place(ring[s], onRing(s, turn));
    state = "rec";
    announce("rec");
    if (reduce.matches) { still("rec"); return; }
    var order = ring.filter(Boolean).sort(function (a, b) { return a.n - b.n; });
    ring = [];
    turnAt = -1;
    order.forEach(function (f, k) {
      var from = f.el.getAttribute("transform").match(/-?[\d.]+/g).map(Number);
      f.el.setAttribute("opacity", "1");
      f.path = [from, cell(k)]; f.at = clock + k * STAGGER; f.dur = HANDOVER; f.land = null;
      flying.push(f);
    });
    saved = order.length;
    drawMarks(saved);
    nextEmit = clock + order.length * STAGGER + HANDOVER;
    if (saved >= CELLS) nextEmit = Infinity;
  }

  function step(dt) {
    clock += dt;
    if (state !== "done" && saved < CELLS && clock >= nextEmit) { emit(); nextEmit = clock + EVERY; }
    if (state === "rec" && saved >= CELLS) nextEmit = Infinity;
    for (var k = flying.length - 1; k >= 0; k--) {
      var f = flying[k], t = (clock - f.at) / f.dur;
      if (t < 0) { if (f.path.length === 2 && f.land === null) continue; t = 0; }
      if (t >= 1) {
        place(f, f.path[f.path.length - 1]);
        flying.splice(k, 1);
        if (f.land) f.land();
        continue;
      }
      var e = ease(t), p;
      if (f.path.length === 2) p = lerp(f.path[0], f.path[1], e);
      else {
        var cut = FLY / f.dur;
        p = e < cut ? lerp(f.path[0], f.path[1], e / cut) : lerp(f.path[1], f.path[2], (e - cut) / (1 - cut));
      }
      place(f, p);
    }
    if (turnAt >= 0) {
      var u = Math.min(1, (clock - turnAt) / TURN);
      turn = turnFrom + (turnTo - turnFrom) * ease(u);
      if (u >= 1) turnAt = -1;
    }
    for (var s = 0; s < SLOTS; s++) if (ring[s]) place(ring[s], onRing(s, turn));
  }

  function loop(now) {
    raf = 0;
    if (!running) return;
    var dt = last == null ? 16 : Math.min(50, now - last);
    last = now;
    step(dt);
    if (state !== "done" || flying.length) raf = requestAnimationFrame(loop);
  }
  function wake() {
    if (running && !raf && !reduce.matches && (state !== "done" || flying.length)) { last = null; raf = requestAnimationFrame(loop); }
  }

  function begin() {
    state = "wait";
    if (reduce.matches) { still("wait"); return; }
    clear();
    announce("wait");
    wake();
  }

  var open = details ? details.open : true, visible = false;
  function update() {
    running = open && visible && !document.hidden;
    if (running) wake();
  }
  if (details) details.addEventListener("toggle", function () {
    open = details.open;
    if (open && state === "done" && !flying.length) begin();
    update();
  });
  if ("IntersectionObserver" in window) {
    new IntersectionObserver(function (entries) { visible = entries[0].isIntersecting; update(); }).observe(root);
  } else { visible = true; }
  document.addEventListener("visibilitychange", update);
  if (reduce.addEventListener) reduce.addEventListener("change", begin); else if (reduce.addListener) reduce.addListener(begin);

  record.addEventListener("click", function () { startRecording(); wake(); reset.focus(); });
  reset.addEventListener("click", function () { begin(); record.focus(); });
  root.querySelector(".ram-controls").hidden = false;
  begin();
  update();
})();
