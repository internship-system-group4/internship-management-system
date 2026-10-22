// Meet the Team page controller. The lecture hall (powered-by-hall.js) is an enhancement:
// every name, role, photo and link lives in the server-rendered roster, which this script
// shows inside the profile panel, and which stays visible as a plain list if anything fails.
const root = document.querySelector('[data-team-experience]');
if (root && root.dataset.mode === 'loading') start();

function start() {
 const members = JSON.parse(document.getElementById('teamHallData').textContent || '[]');
 const keys = members.map(member => member.key);
 const byKey = new Map(members.map(member => [member.key, member]));
 const motion = matchMedia('(prefers-reduced-motion: reduce)');
 const narrow = matchMedia('(max-width: 700px)');
 const $ = selector => root.querySelector(selector);
 const finder = $('[data-team-finder]'), toggle = finder.querySelector('.team-finder-toggle'), list = finder.querySelector('.team-finder-list');
 const overviewButton = $('[data-team-overview]'), hover = $('[data-team-hover]');
 const profile = $('[data-team-profile]'), profileBody = $('[data-team-profile-body]'), profileCount = $('[data-team-profile-count]');
 const progress = $('[data-team-progress]'), loadingText = $('[data-team-loading-text]');
 let hall = null, current = null, opener = null, disposed = false;

 function fail() {
  hall?.dispose(); hall = null;
  root.dataset.mode = 'fallback'; root.setAttribute('data-failed', '');
 }

 // ---- Finder -------------------------------------------------------------------------
 function setFinder(open, focusToggle) {
  toggle.setAttribute('aria-expanded', String(open)); list.hidden = !open;
  if (open) (list.querySelector('[aria-current="true"]') || list.querySelector('button')).focus();
  else if (focusToggle) toggle.focus();
 }
 toggle.addEventListener('click', () => setFinder(list.hidden));
 list.addEventListener('click', event => {
  const button = event.target.closest('button[data-member-key]'); if (!button) return;
  setFinder(false);
  openProfile(button.dataset.memberKey, toggle);
 });
 list.addEventListener('keydown', event => {
  const buttons = [...list.querySelectorAll('button')], index = buttons.indexOf(document.activeElement);
  if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
   event.preventDefault();
   buttons[(index + (event.key === 'ArrowDown' ? 1 : buttons.length - 1)) % buttons.length].focus();
  }
 });
 document.addEventListener('pointerdown', event => { if (!list.hidden && !finder.contains(event.target)) setFinder(false); });

 // ---- Profile ------------------------------------------------------------------------
 function insets() {
  if (profile.hidden) return { right:0, bottom:0 };
  const box = profile.getBoundingClientRect(), stage = root.getBoundingClientRect();
  return narrow.matches ? { right:0, bottom:stage.bottom - box.top } : { right:stage.right - box.left, bottom:0 };
 }
 function openProfile(key, from) {
  const source = document.getElementById('member-' + key); if (!source) return;
  if (profile.hidden) opener = from || opener || toggle;
  current = key;
  const card = source.querySelector('article').cloneNode(true), name = card.querySelector('.team-member-name');
  name.id = 'teamProfileName'; name.tabIndex = -1;
  profileBody.replaceChildren(card);
  profileCount.textContent = 'Team member ' + (keys.indexOf(key) + 1) + ' of ' + keys.length;
  list.querySelectorAll('button').forEach(button => button.setAttribute('aria-current', String(button.dataset.memberKey === key)));
  profile.hidden = false; root.dataset.profileOpen = ''; profile.scrollTop = 0;
  overviewButton.hidden = false;
  name.focus({ preventScroll:true });
  hall?.focus(key, insets());
 }
 function closeProfile() {
  if (profile.hidden) return;
  profile.hidden = true; delete root.dataset.profileOpen;
  hall?.setInsets(insets());
  const target = opener && opener.isConnected && !opener.closest('[hidden]') ? opener : toggle;
  opener = null; target.focus();
 }
 function step(delta) { openProfile(keys[(keys.indexOf(current) + delta + keys.length) % keys.length]); }
 $('[data-team-prev]').addEventListener('click', () => step(-1));
 $('[data-team-next]').addEventListener('click', () => step(1));
 $('[data-team-close]').addEventListener('click', closeProfile);
 overviewButton.addEventListener('click', () => {
  const wasOpen = !profile.hidden;
  profile.hidden = true; delete root.dataset.profileOpen; current = null; opener = null;
  list.querySelectorAll('button').forEach(button => button.setAttribute('aria-current', 'false'));
  overviewButton.hidden = true; toggle.focus();
  hall?.overview({ right:0, bottom:0 });
  if (!wasOpen) hall?.setInsets({ right:0, bottom:0 });
 });
 root.addEventListener('keydown', event => {
  if (event.key !== 'Escape') return;
  if (!list.hidden) { event.preventDefault(); setFinder(false, true); }
  else if (!profile.hidden) { event.preventDefault(); closeProfile(); }
 });

 // ---- Hover label --------------------------------------------------------------------
 function showHover(key, point) {
  if (!key || !point) { hover.hidden = true; return; }
  const member = byKey.get(key);
  hover.querySelector('strong').textContent = member.name;
  hover.querySelector('span').textContent = member.role;
  hover.style.left = point.x + 'px'; hover.style.top = point.y + 'px'; hover.hidden = false;
 }

 // ---- Scene lifecycle ----------------------------------------------------------------
 async function load() {
  disposed = false; root.dataset.mode = 'loading';
  try {
   // Carry this script's cache-busting query to the scene module.
   const { createLectureHall } = await import('./powered-by-hall.js' + new URL(import.meta.url).search);
   if (disposed) return;
   hall = await createLectureHall({
    container: $('[data-hall-canvas]'), members, logo: root.dataset.logo,
    reducedMotion: motion.matches,
    onProgress(value, label) { progress.style.width = Math.round(value * 100) + '%'; if (label) loadingText.textContent = label; },
    onHover: showHover,
    onSelect: key => openProfile(key, toggle),
    onLost: fail,
    onCamera: state => { root.dataset.camera = state; }
   });
   if (disposed) { hall.dispose(); hall = null; return; }
   root.dataset.mode = 'ready';
   hall.intro();
  } catch (error) {
   console.warn('Lecture hall unavailable; showing the team list.', error);
   fail();
  }
 }
 motion.addEventListener('change', () => hall?.setReducedMotion(motion.matches));
 addEventListener('resize', () => { if (!profile.hidden) hall?.setInsets(insets()); });
 addEventListener('pagehide', () => { disposed = true; hall?.dispose(); hall = null; });
 addEventListener('pageshow', event => { if (event.persisted && root.dataset.mode !== 'fallback') load(); });
 load();
}
