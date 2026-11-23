(function () {
  'use strict';

  // ── 1. Theme Toggle ──
  var themeToggle = document.getElementById('theme-toggle');
  var themeLabel = themeToggle ? themeToggle.querySelector('[data-theme-label]') : null;

  function syncThemeLabel() {
    if (!themeLabel) return;
    var isDark = document.documentElement.classList.contains('dark');
    themeLabel.textContent = isDark ? 'Light' : 'Dark';
  }

  syncThemeLabel();

  if (themeToggle) {
    themeToggle.addEventListener('click', function () {
      var isDark = document.documentElement.classList.toggle('dark');
      localStorage.setItem('portfolio-theme', isDark ? 'dark' : 'light');
      syncThemeLabel();
    });
  }

  // ── 2. Scroll Progress Bar ──
  var progressBar = document.getElementById('scroll-progress');
  function updateScrollProgress() {
    if (!progressBar) return;
    var docHeight = document.documentElement.scrollHeight - window.innerHeight;
    if (docHeight <= 0) {
      progressBar.style.transform = 'scaleX(0)';
      return;
    }
    var ratio = Math.min(1, Math.max(0, window.scrollY / docHeight));
    progressBar.style.transform = 'scaleX(' + ratio.toFixed(4) + ')';
  }

  window.addEventListener('scroll', updateScrollProgress, { passive: true });
  window.addEventListener('resize', updateScrollProgress, { passive: true });
  updateScrollProgress();

  // ── 3. Blur + Spring Scroll Reveal (IntersectionObserver) ──
  var revealElements = Array.prototype.slice.call(document.querySelectorAll('[data-reveal]'));
  var prefersReduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function showElement(el) {
    var delay = el.getAttribute('data-delay');
    if (delay) {
      el.style.transitionDelay = delay + 'ms';
    }
    el.classList.add('is-revealed');
  }

  if (prefersReduced || !('IntersectionObserver' in window)) {
    revealElements.forEach(showElement);
  } else {
    var observer = new IntersectionObserver(
      function (entries, obs) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            showElement(entry.target);
            obs.unobserve(entry.target);
          }
        });
      },
      {
        threshold: 0.06,
        rootMargin: '0px 0px -24px 0px',
      }
    );

    revealElements.forEach(function (el) {
      observer.observe(el);
    });
  }

  // ── 4. Cursor-tracking Spotlight on Cards ──
  var spotlightCards = Array.prototype.slice.call(
    document.querySelectorAll('.wip-card, .tool-group, .contact-card, .readme-block')
  );

  if (!prefersReduced && spotlightCards.length > 0) {
    spotlightCards.forEach(function (card) {
      card.addEventListener('mousemove', function (e) {
        var rect = card.getBoundingClientRect();
        var x = e.clientX - rect.left;
        var y = e.clientY - rect.top;
        card.style.setProperty('--mouse-x', x + 'px');
        card.style.setProperty('--mouse-y', y + 'px');
      });
    });
  }

  // ── 5. Projects Page Animated Filter ──
  var filterButtons = Array.prototype.slice.call(document.querySelectorAll('.filter-btn'));
  var projectEntries = Array.prototype.slice.call(document.querySelectorAll('.project-entry'));

  if (filterButtons.length > 0 && projectEntries.length > 0) {
    filterButtons.forEach(function (btn) {
      btn.addEventListener('click', function () {
        var targetFilter = btn.getAttribute('data-filter') || 'all';

        filterButtons.forEach(function (item) {
          item.classList.toggle('is-active', item === btn);
        });

        var visibleIndex = 0;
        projectEntries.forEach(function (entry) {
          var status = entry.getAttribute('data-status');
          var visible = targetFilter === 'all' || status === targetFilter;
          entry.classList.remove('is-filtering-enter');
          entry.classList.toggle('is-filtered-out', !visible);

          if (visible) {
            entry.classList.add('is-revealed');
            if (!prefersReduced) {
              void entry.offsetWidth; // trigger reflow for staggered animation
              entry.style.animationDelay = visibleIndex * 55 + 'ms';
              entry.classList.add('is-filtering-enter');
              visibleIndex++;
            }
          }
        });

        updateScrollProgress();
      });
    });
  }
})();
