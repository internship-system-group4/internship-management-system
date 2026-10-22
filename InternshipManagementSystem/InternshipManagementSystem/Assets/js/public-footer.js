(function () {
 'use strict';
 // Pause control for the decorative footer waves. Reduced-motion users never see motion,
 // so the control stays hidden for them; off-screen waves also stop to save work.
 var footer = document.querySelector('[data-public-footer]');
 if (!footer) return;
 var button = footer.querySelector('[data-footer-wave-pause]');
 var motion = matchMedia('(prefers-reduced-motion: reduce)');
 var paused = false, visible = true;
 try { paused = localStorage.getItem('uimsFooterWavesPaused') === 'true'; } catch (e) {}
 function render() {
  if (paused || !visible) footer.setAttribute('data-waves-paused', ''); else footer.removeAttribute('data-waves-paused');
  button.hidden = motion.matches;
  button.textContent = paused ? 'Play waves' : 'Pause waves';
  button.setAttribute('aria-pressed', String(paused));
 }
 button.addEventListener('click', function () {
  paused = !paused;
  try { localStorage.setItem('uimsFooterWavesPaused', String(paused)); } catch (e) {}
  render();
 });
 if (motion.addEventListener) motion.addEventListener('change', render);
 if ('IntersectionObserver' in window) new IntersectionObserver(function (entries) { visible = entries[0].isIntersecting; render(); }).observe(footer);
 render();
}());
