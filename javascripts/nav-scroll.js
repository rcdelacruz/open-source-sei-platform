// Accessibility-first nav scroll: respects prefers-reduced-motion
(function() {
  // Check if user prefers reduced motion (accessibility)
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function scrollActiveIntoView() {
    const activeLink = document.querySelector('.md-sidebar--primary .md-nav__link--active');
    if (!activeLink) return;

    const scrollWrap = activeLink.closest('.md-sidebar__scrollwrap');
    if (!scrollWrap) return;

    // Check if active item is already visible in viewport
    const rect = activeLink.getBoundingClientRect();
    const scrollWrapRect = scrollWrap.getBoundingClientRect();

    // If already fully visible, don't scroll (prevents unnecessary jittering)
    if (rect.top >= scrollWrapRect.top && rect.bottom <= scrollWrapRect.bottom) {
      return;
    }

    // Only scroll if item is off-screen - position at 20% from top
    const linkTop = activeLink.offsetTop;
    const scrollWrapHeight = scrollWrap.clientHeight;
    const targetScroll = linkTop - (scrollWrapHeight * 0.2);

    // ALWAYS use instant scroll to prevent motion sickness/vertigo
    scrollWrap.scrollTo({
      top: targetScroll,
      behavior: 'instant'  // No animation - accessibility best practice
    });
  }

  // Initial page load
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => setTimeout(scrollActiveIntoView, 100));
  } else {
    setTimeout(scrollActiveIntoView, 100);
  }

  // On navigation - wait for Material's instant loading to complete
  if (typeof document$ !== 'undefined') {
    document$.subscribe(() => {
      setTimeout(scrollActiveIntoView, 100);
    });
  }
})();
