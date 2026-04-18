
(function() {
  var isHome = document.body.classList.contains('page-home');
  var isSlug = document.body.classList.contains('page-slug');

  /* Images — wait for load, then reveal */
  function revealImgs(selector) {
    document.querySelectorAll(selector).forEach(function(img) {
      var wrap = img.parentElement;
      if (!wrap) return;
      if (img.complete && img.naturalWidth > 0) {
        wrap.classList.add('img-ready');
      } else {
        img.addEventListener('load', function() {
          wrap.classList.add('img-ready');
        });
        img.addEventListener('error', function() {
          wrap.classList.add('img-ready'); // still show on error
        });
      }
    });
  }
  revealImgs('.works-img');
  revealImgs('.proj-img');
  revealImgs('.gallery-img');

  /* Generic fade-up observer */
  function fadeUp(selector, delay) {
    var els = document.querySelectorAll(selector);
    if (!els.length) return;
    var obs = new IntersectionObserver(function(entries) {
      entries.forEach(function(e) {
        if (!e.isIntersecting) return;
        var i = Array.from(els).indexOf(e.target);
        setTimeout(function() {
          e.target.classList.add('up');
        }, i * (delay || 0));
        obs.unobserve(e.target);
      });
    }, { threshold: 0.1 });
    els.forEach(function(el) { obs.observe(el); });
  }

  fadeUp('.pillar', 110);
  fadeUp('.statement-q', 0);

  if (isSlug) {
    fadeUp('.identity-title', 0);
    var rows = document.querySelectorAll('.spec-row');
    var rowObs = new IntersectionObserver(function(entries) {
      entries.forEach(function(e) {
        if (!e.isIntersecting) return;
        var i = Array.from(rows).indexOf(e.target);
        setTimeout(function() { e.target.classList.add('up'); }, i * 70);
        rowObs.unobserve(e.target);
      });
    }, { threshold: 0.1 });
    rows.forEach(function(el) { rowObs.observe(el); });
  }

  /* Kinetic tracking */
  var trackEls = document.querySelectorAll('.works-title, .ig-title, .news-title');
  if (trackEls.length) {
    var trackObs = new IntersectionObserver(function(entries) {
      entries.forEach(function(e) {
        e.target.classList.toggle('track', e.isIntersecting);
      });
    }, { threshold: 0.35 });
    trackEls.forEach(function(el) { trackObs.observe(el); });
  }

  /* Scroll letter-spacing on hero — home only */
  if (isHome) {
    var heroTitle = document.querySelector('.hero-title');
    var hero = document.querySelector('.hero');
    if (heroTitle && hero) {
      var ticking = false;
      window.addEventListener('scroll', function() {
        if (ticking) return;
        requestAnimationFrame(function() {
          var p = Math.min(window.scrollY / (hero.offsetHeight * 0.4), 1);
          heroTitle.style.letterSpacing = (0.03 + p * 0.15) + 'em';
          heroTitle.style.opacity = String(1 - p * 0.4);
          ticking = false;
        });
        ticking = true;
      }, { passive: true });
    }
  }
})();
