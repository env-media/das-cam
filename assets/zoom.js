// Tap or click a screenshot to see it full size (WEB-ZOOM1, AJ 11-20).
// Each screenshot is a link to its full-size file (2950 pixels wide), so
// without this script the browser opens that file by itself. With it, the
// file opens over the page instead, and it is loaded only then. The page's
// zoom is never blocked, so on a phone the enlarged image can be pinched.
// Close: the Close button, a tap on the dark area, or Escape.
(function () {
  "use strict";
  var links = Array.prototype.slice.call(document.querySelectorAll("a.zoom[href]"));
  if (!links.length || typeof HTMLDialogElement !== "function" || !("showModal" in HTMLDialogElement.prototype)) return;

  var icon = 'viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"';
  var box = document.createElement("dialog");
  box.className = "lightbox";
  box.setAttribute("aria-label", "Enlarged image");
  box.innerHTML =
    '<div class="lb-bar">' +
      '<p class="lb-count" aria-live="polite"></p>' +
      '<button type="button" class="lb-btn lb-close"><svg ' + icon + '><path d="M4 4l8 8M12 4l-8 8"/></svg>Close</button>' +
    '</div>' +
    '<div class="lb-stage"><img class="lb-img" alt=""><p class="lb-status" hidden></p></div>' +
    '<div class="lb-bar lb-nav">' +
      '<button type="button" class="lb-btn lb-prev"><svg ' + icon + '><path d="M10 3 5 8l5 5"/></svg>Previous</button>' +
      '<button type="button" class="lb-btn lb-next">Next<svg ' + icon + '><path d="m6 3 5 5-5 5"/></svg></button>' +
    '</div>';
  document.body.appendChild(box);
  var big = box.querySelector(".lb-img"), count = box.querySelector(".lb-count"), status = box.querySelector(".lb-status");
  var closeButton = box.querySelector(".lb-close");
  if (links.length < 2) box.querySelector(".lb-nav").hidden = true;

  var items = links.map(function (a) {
    return { link: a, img: a.querySelector("img"), full: a.getAttribute("href"),
             w: Number(a.getAttribute("data-width")) || 0, h: Number(a.getAttribute("data-height")) || 0 };
  });
  var current = 0, opener = null, token = 0;

  // The cached page image shows at once; the full-size file replaces it when it has loaded.
  function show(i) {
    var n = items.length, it, mine = ++token;
    current = ((i % n) + n) % n;
    it = items[current];
    if (it.w && it.h) big.style.setProperty("--lb-ratio", String(it.w / it.h));
    big.alt = it.img ? it.img.alt : "";
    count.textContent = "Image " + (current + 1) + " of " + n;
    if (it.img && it.img.complete && it.img.naturalWidth > 0) {
      big.src = it.img.currentSrc || it.img.src;
      big.hidden = false;
    } else {
      big.removeAttribute("src");
      big.hidden = true;
    }
    status.textContent = "Loading the full-size image";
    status.hidden = false;
    var pre = new Image();
    pre.src = it.full;
    var loaded = pre.decode ? pre.decode() : new Promise(function (ok, no) { pre.onload = ok; pre.onerror = no; });
    function put() {
      if (mine !== token) return;
      big.src = it.full;
      big.hidden = false;
      status.hidden = true;
    }
    loaded.then(put, function () {
      if (pre.complete && pre.naturalWidth > 0) { put(); return; }
      if (mine === token) status.textContent = "The full-size image did not load.";
    });
  }

  function open(i) {
    opener = items[i].link;
    show(i);
    document.documentElement.classList.add("lb-open");
    box.showModal();
    closeButton.focus();
  }

  links.forEach(function (a, i) {
    var img = items[i].img;
    a.setAttribute("role", "button");
    a.setAttribute("aria-haspopup", "dialog");
    a.setAttribute("aria-label", "Enlarge: " + (img && img.alt ? img.alt : "image"));
    a.insertAdjacentHTML("beforeend", '<span class="zoom-hint" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" focusable="false"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m15.5 15.5 5 5M10.5 7.5v6M7.5 10.5h6"/></svg></span>');
    a.addEventListener("click", function (e) {
      // A new tab or window (a modifier key, the middle button): the browser opens the file.
      if (e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
      e.preventDefault();
      open(i);
    });
    // Space works as on a button: on release, so the key is not then read by the Close button.
    a.addEventListener("keydown", function (e) {
      if (e.key === " " || e.key === "Spacebar") e.preventDefault();
    });
    a.addEventListener("keyup", function (e) {
      if (e.key === " " || e.key === "Spacebar") { e.preventDefault(); open(i); }
    });
  });

  closeButton.addEventListener("click", function () { box.close(); });
  box.querySelector(".lb-prev").addEventListener("click", function () { show(current - 1); });
  box.querySelector(".lb-next").addEventListener("click", function () { show(current + 1); });
  // A tap anywhere outside the image and the buttons closes the view.
  box.addEventListener("click", function (e) {
    if (e.target === big || (e.target.closest && e.target.closest("button"))) return;
    box.close();
  });
  box.addEventListener("keydown", function (e) {
    if (e.key === "ArrowLeft") { e.preventDefault(); show(current - 1); }
    else if (e.key === "ArrowRight") { e.preventDefault(); show(current + 1); }
  });
  // Escape closes the dialog by itself; every way out ends here.
  box.addEventListener("close", function () {
    token++;
    big.removeAttribute("src");
    document.documentElement.classList.remove("lb-open");
    if (opener) {
      try { opener.focus({ preventScroll: true }); } catch (e) { opener.focus(); }
    }
  });
})();
