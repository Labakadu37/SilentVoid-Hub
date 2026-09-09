/* ==========================================================================
   Claude — Site vitrine
   Vanilla JS, aucune dépendance.
   ========================================================================== */
(function () {
  "use strict";

  var $  = function (s, c) { return (c || document).querySelector(s); };
  var $$ = function (s, c) { return Array.prototype.slice.call((c || document).querySelectorAll(s)); };

  var reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var fine    = window.matchMedia("(hover: hover) and (pointer: fine)").matches;

  /* ------------------------------------------------------------------ *
   * 1. Préchargeur
   * ------------------------------------------------------------------ */
  function initLoader() {
    var loader = $("#loader");
    var fill   = $("#loaderFill");
    var pct    = $("#loaderPct");
    if (!loader) return;

    var value = 0;
    var loaded = false;
    var pad = function (n) { return String(Math.round(n)).padStart(3, "0"); };

    function done() {
      loader.classList.add("is-done");
      document.body.classList.remove("is-locked");
      window.setTimeout(function () { loader.setAttribute("aria-hidden", "true"); }, 700);
      startHeroSequence();
    }

    if (reduced) { done(); return; }

    document.body.classList.add("is-locked");
    window.addEventListener("load", function () { loaded = true; });

    var timer = window.setInterval(function () {
      // Progression rapide au début, ralentie ensuite : impression de charge réelle.
      var ceiling = loaded ? 100 : 92;
      value += Math.max(0.6, (ceiling - value) * 0.09);
      if (value >= ceiling) value = ceiling;

      fill.style.width = value + "%";
      pct.textContent = pad(value);

      if (value >= 99.4) {
        fill.style.width = "100%";
        pct.textContent = "100";
        window.clearInterval(timer);
        window.setTimeout(done, 320);
      }
    }, 45);

    // Filet de sécurité : on ne bloque jamais la page plus de 4 s.
    window.setTimeout(function () {
      if (!loader.classList.contains("is-done")) { window.clearInterval(timer); done(); }
    }, 4000);
  }

  /* ------------------------------------------------------------------ *
   * 2. Curseur personnalisé
   * ------------------------------------------------------------------ */
  function initCursor() {
    if (!fine || reduced) return;

    var dot  = $(".cursor");
    var ring = $(".cursor-ring");
    if (!dot || !ring) return;

    var mx = window.innerWidth / 2, my = window.innerHeight / 2;
    var rx = mx, ry = my;

    document.addEventListener("mousemove", function (e) {
      mx = e.clientX; my = e.clientY;
      document.body.classList.add("cursor-ready");
    }, { passive: true });

    document.addEventListener("mouseleave", function () {
      document.body.classList.remove("cursor-ready");
    });

    (function loop() {
      // Le point colle au pointeur, l'anneau suit avec de l'inertie.
      rx += (mx - rx) * 0.16;
      ry += (my - ry) * 0.16;
      dot.style.transform  = "translate3d(" + (mx - 3.5) + "px," + (my - 3.5) + "px,0)";
      ring.style.transform = "translate3d(" + (rx - 19) + "px," + (ry - 19) + "px,0)";
      window.requestAnimationFrame(loop);
    })();

    var hot = "a, button, [data-magnetic], .card, .work-card, .stack-item, .stat";
    document.addEventListener("mouseover", function (e) {
      if (e.target.closest && e.target.closest(hot)) document.body.classList.add("cursor-hot");
    }, { passive: true });
    document.addEventListener("mouseout", function (e) {
      if (e.target.closest && e.target.closest(hot)) document.body.classList.remove("cursor-hot");
    }, { passive: true });
  }

  /* ------------------------------------------------------------------ *
   * 3. Navigation : état collé, progression, lien actif
   * ------------------------------------------------------------------ */
  function initNav() {
    var nav      = $("#nav");
    var progress = $("#progress");
    var links    = $$(".nav__link");
    var ticking  = false;

    function onScroll() {
      var y = window.scrollY || window.pageYOffset;
      if (nav) nav.classList.toggle("is-stuck", y > 24);

      if (progress) {
        var max = document.documentElement.scrollHeight - window.innerHeight;
        progress.style.transform = "scaleX(" + (max > 0 ? Math.min(y / max, 1) : 0) + ")";
      }
      ticking = false;
    }

    window.addEventListener("scroll", function () {
      if (!ticking) { window.requestAnimationFrame(onScroll); ticking = true; }
    }, { passive: true });
    onScroll();

    // Lien actif : la section qui occupe le haut de l'écran gagne.
    var sections = links
      .map(function (l) { return $(l.getAttribute("href")); })
      .filter(Boolean);

    if (!sections.length || !("IntersectionObserver" in window)) return;

    var spy = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        links.forEach(function (l) {
          l.classList.toggle("is-active", l.getAttribute("href") === "#" + entry.target.id);
        });
      });
    }, { rootMargin: "-45% 0px -50% 0px", threshold: 0 });

    sections.forEach(function (s) { spy.observe(s); });
  }

  /* ------------------------------------------------------------------ *
   * 4. Menu mobile
   * ------------------------------------------------------------------ */
  function initDrawer() {
    var burger = $("#burger");
    var drawer = $("#drawer");
    if (!burger || !drawer) return;

    drawer.hidden = false; // sans JS, le tiroir reste inerte

    function setOpen(open) {
      burger.setAttribute("aria-expanded", String(open));
      burger.setAttribute("aria-label", open ? "Fermer le menu" : "Ouvrir le menu");
      drawer.classList.toggle("is-open", open);
      document.body.classList.toggle("is-locked", open);
    }

    burger.addEventListener("click", function () {
      setOpen(burger.getAttribute("aria-expanded") !== "true");
    });

    $$("a", drawer).forEach(function (a) {
      a.addEventListener("click", function () { setOpen(false); });
    });

    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && drawer.classList.contains("is-open")) setOpen(false);
    });
  }

  /* ------------------------------------------------------------------ *
   * 5. Apparition au défilement
   * ------------------------------------------------------------------ */
  function initReveal() {
    var items = $$("[data-reveal], .split-line");

    if (!("IntersectionObserver" in window) || reduced) {
      items.forEach(function (el) { el.classList.add("is-in"); });
      return;
    }

    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        entry.target.classList.add("is-in");
        io.unobserve(entry.target);
      });
    }, { rootMargin: "0px 0px -8% 0px", threshold: 0.12 });

    items.forEach(function (el) { io.observe(el); });
  }

  /* ------------------------------------------------------------------ *
   * 6. Compteurs animés
   * ------------------------------------------------------------------ */
  function initCounters() {
    var nums = $$("[data-count]");
    if (!nums.length) return;

    function run(el) {
      var target = parseFloat(el.getAttribute("data-count")) || 0;
      var suffix = el.getAttribute("data-suffix") || "";

      if (reduced || target === 0) { el.textContent = target + suffix; return; }

      var duration = 1500;
      var start = null;

      (function tick(now) {
        if (start === null) start = now;
        var p = Math.min((now - start) / duration, 1);
        var eased = 1 - Math.pow(1 - p, 3); // easeOutCubic
        el.textContent = Math.round(target * eased) + suffix;
        if (p < 1) window.requestAnimationFrame(tick);
      })(performance.now());
    }

    if (!("IntersectionObserver" in window)) { nums.forEach(run); return; }

    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        run(entry.target);
        io.unobserve(entry.target);
      });
    }, { threshold: 0.55 });

    nums.forEach(function (n) { io.observe(n); });
  }

  /* ------------------------------------------------------------------ *
   * 7. Projecteur sur les cartes
   * ------------------------------------------------------------------ */
  function initSpotlight() {
    if (!fine) return;
    $$("[data-spotlight]").forEach(function (card) {
      card.addEventListener("mousemove", function (e) {
        var r = card.getBoundingClientRect();
        card.style.setProperty("--mx", (e.clientX - r.left) + "px");
        card.style.setProperty("--my", (e.clientY - r.top) + "px");
      }, { passive: true });
    });
  }

  /* ------------------------------------------------------------------ *
   * 8. Boutons magnétiques
   * ------------------------------------------------------------------ */
  function initMagnetic() {
    if (!fine || reduced) return;

    $$("[data-magnetic]").forEach(function (el) {
      el.addEventListener("mousemove", function (e) {
        var r = el.getBoundingClientRect();
        var x = (e.clientX - r.left - r.width / 2) * 0.28;
        var y = (e.clientY - r.top - r.height / 2) * 0.42;
        el.style.transform = "translate(" + x + "px," + y + "px)";
      }, { passive: true });

      el.addEventListener("mouseleave", function () { el.style.transform = ""; });
    });
  }

  /* ------------------------------------------------------------------ *
   * 9. Inclinaison du terminal
   * ------------------------------------------------------------------ */
  function initTilt() {
    var el = $("#tilt");
    if (!el || !fine || reduced) return;

    var zone = el.parentElement;

    zone.addEventListener("mousemove", function (e) {
      var r = zone.getBoundingClientRect();
      var px = (e.clientX - r.left) / r.width - 0.5;
      var py = (e.clientY - r.top) / r.height - 0.5;
      el.style.transform =
        "perspective(1100px) rotateY(" + (px * 7).toFixed(2) + "deg) rotateX(" +
        (-py * 7).toFixed(2) + "deg) translateZ(0)";
    }, { passive: true });

    zone.addEventListener("mouseleave", function () {
      el.style.transform = "perspective(1100px) rotateY(0) rotateX(0)";
    });
  }

  /* ------------------------------------------------------------------ *
   * 10. Terminal : frappe simulée
   * ------------------------------------------------------------------ */
  var heroStarted = false;

  var SCRIPT = [
    { cls: "t-prompt", text: "$ ", type: false },
    { cls: "t-cmd",    text: "claude \"ajoute l'export CSV au dashboard\"", type: true, br: true },
    { cls: "t-dim",    text: "", type: false, br: true },
    { cls: "t-dim",    text: "  Lecture du projet…", type: false, br: true, wait: 380 },
    { cls: "t-dim",    text: "  12 fichiers analysés · React + TypeScript détecté", type: false, br: true, wait: 320 },
    { cls: "t-dim",    text: "", type: false, br: true },
    { cls: "t-key",    text: "  Plan", type: false, br: true, wait: 220 },
    { cls: "t-dim",    text: "  1. utils/exportCsv.ts      · sérialisation", type: false, br: true, wait: 180 },
    { cls: "t-dim",    text: "  2. Dashboard.tsx           · bouton + état", type: false, br: true, wait: 180 },
    { cls: "t-dim",    text: "  3. exportCsv.test.ts       · cas limites", type: false, br: true, wait: 180 },
    { cls: "t-dim",    text: "", type: false, br: true },
    { cls: "t-ok",     text: "  ✓ 3 fichiers écrits", type: false, br: true, wait: 420 },
    { cls: "t-ok",     text: "  ✓ 24 tests passés en 1.8 s", type: false, br: true, wait: 380 },
    { cls: "t-warn",   text: "  ! virgules dans les libellés → champs échappés", type: false, br: true, wait: 340 },
    { cls: "t-dim",    text: "", type: false, br: true },
    { cls: "t-prompt", text: "$ ", type: false },
    { cls: "t-cmd",    text: "git commit -m \"feat: export CSV du dashboard\"", type: true, br: true, wait: 260 },
    { cls: "t-ok",     text: "  3 files changed, 118 insertions(+)", type: false, br: true, wait: 300 }
  ];

  function startHeroSequence() {
    if (heroStarted) return;
    heroStarted = true;

    var term = $("#term");
    if (!term) return;

    // Sans animation : on affiche la session complète d'un coup.
    if (reduced) {
      SCRIPT.forEach(function (l) {
        var s = document.createElement("span");
        s.className = l.cls;
        s.textContent = l.text;
        term.appendChild(s);
        if (l.br) term.appendChild(document.createElement("br"));
      });
      return;
    }

    var caret = document.createElement("span");
    caret.className = "caret";

    var i = 0;

    function nextLine() {
      if (i >= SCRIPT.length) {
        term.appendChild(caret);
        return;
      }

      var line = SCRIPT[i++];
      var span = document.createElement("span");
      span.className = line.cls;
      term.appendChild(span);
      if (caret.parentNode) caret.parentNode.removeChild(caret);
      term.appendChild(caret);

      function finish() {
        if (line.br) term.insertBefore(document.createElement("br"), caret);
        window.setTimeout(nextLine, line.wait || 90);
      }

      if (!line.type) {
        span.textContent = line.text;
        finish();
        return;
      }

      var c = 0;
      (function typeChar() {
        span.textContent = line.text.slice(0, ++c);
        if (c < line.text.length) {
          window.setTimeout(typeChar, 24 + Math.random() * 34);
        } else {
          window.setTimeout(finish, 260);
        }
      })();
    }

    window.setTimeout(nextLine, 700);
  }

  /* ------------------------------------------------------------------ *
   * 11. FAQ
   * ------------------------------------------------------------------ */
  function initFaq() {
    var buttons = $$(".faq__q");

    buttons.forEach(function (btn) {
      btn.addEventListener("click", function () {
        var open = btn.getAttribute("aria-expanded") === "true";

        // Accordéon : une seule réponse ouverte à la fois.
        buttons.forEach(function (other) {
          other.setAttribute("aria-expanded", "false");
          var p = document.getElementById(other.getAttribute("aria-controls"));
          if (p) p.setAttribute("data-open", "false");
        });

        if (!open) {
          btn.setAttribute("aria-expanded", "true");
          var panel = document.getElementById(btn.getAttribute("aria-controls"));
          if (panel) panel.setAttribute("data-open", "true");
        }
      });
    });
  }

  /* ------------------------------------------------------------------ *
   * 12. Braises en arrière-plan
   * ------------------------------------------------------------------ */
  function initEmbers() {
    var canvas = $("#embers");
    if (!canvas || reduced) return;

    var ctx = canvas.getContext("2d");
    if (!ctx) return;

    var w = 0, h = 0, dpr = 1;
    var particles = [];
    var raf = null;

    function count() {
      // Densité proportionnelle à la surface, plafonnée sur petits écrans.
      return Math.min(90, Math.max(26, Math.round(window.innerWidth / 18)));
    }

    function spawn(seed) {
      return {
        x: Math.random() * w,
        y: seed ? Math.random() * h : h + Math.random() * 60,
        r: 0.6 + Math.random() * 1.9,
        vy: 0.12 + Math.random() * 0.55,
        vx: (Math.random() - 0.5) * 0.22,
        life: 0,
        max: 400 + Math.random() * 700,
        hue: 18 + Math.random() * 26,
        drift: Math.random() * Math.PI * 2
      };
    }

    function resize() {
      dpr = Math.min(window.devicePixelRatio || 1, 2);
      w = canvas.clientWidth;
      h = canvas.clientHeight;
      canvas.width  = Math.round(w * dpr);
      canvas.height = Math.round(h * dpr);
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);

      var target = count();
      particles = [];
      for (var i = 0; i < target; i++) particles.push(spawn(true));
    }

    function frame() {
      ctx.clearRect(0, 0, w, h);

      for (var i = 0; i < particles.length; i++) {
        var p = particles[i];

        p.life++;
        p.drift += 0.012;
        p.y -= p.vy;
        p.x += p.vx + Math.sin(p.drift) * 0.28;

        // Apparition et extinction douces sur la durée de vie.
        var t = p.life / p.max;
        var alpha = t < 0.15 ? t / 0.15 : (1 - t) / 0.85;
        alpha = Math.max(0, Math.min(1, alpha)) * 0.62;

        if (p.life > p.max || p.y < -20) {
          particles[i] = spawn(false);
          continue;
        }

        var g = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, p.r * 5);
        g.addColorStop(0, "hsla(" + p.hue + ", 100%, 66%, " + alpha + ")");
        g.addColorStop(1, "hsla(" + p.hue + ", 100%, 50%, 0)");

        ctx.fillStyle = g;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r * 5, 0, Math.PI * 2);
        ctx.fill();
      }

      raf = window.requestAnimationFrame(frame);
    }

    function play() { if (raf === null) raf = window.requestAnimationFrame(frame); }
    function pause() {
      if (raf !== null) { window.cancelAnimationFrame(raf); raf = null; }
    }

    var resizeTimer;
    window.addEventListener("resize", function () {
      window.clearTimeout(resizeTimer);
      resizeTimer = window.setTimeout(resize, 180);
    }, { passive: true });

    // On n'anime pas dans un onglet en arrière-plan.
    document.addEventListener("visibilitychange", function () {
      if (document.hidden) pause(); else play();
    });

    resize();
    play();
  }

  /* ------------------------------------------------------------------ *
   * 13. Divers
   * ------------------------------------------------------------------ */
  function initMisc() {
    var year = $("#year");
    if (year) year.textContent = new Date().getFullYear();
  }

  /* ------------------------------------------------------------------ *
   * Démarrage
   * ------------------------------------------------------------------ */
  function boot() {
    initLoader();
    initCursor();
    initNav();
    initDrawer();
    initReveal();
    initCounters();
    initSpotlight();
    initMagnetic();
    initTilt();
    initFaq();
    initEmbers();
    initMisc();

    // Si le préchargeur a déjà disparu (cache chaud), on lance la séquence.
    window.setTimeout(startHeroSequence, 3200);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
