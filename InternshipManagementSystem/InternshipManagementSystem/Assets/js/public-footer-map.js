(function () {
 'use strict';
 // Footer campus map: "from the sky to campus". A real MapLibre camera flight (zoom, pitch and bearing)
 // over OpenFreeMap vector tiles (OpenStreetMap data, no key) to the verified GJU main campus.
 // Real map features: tiles, roads, labels, 3D building extrusions where OpenStreetMap has building outlines,
 // the camera flight and the marker position. Presentation only: the timing, easing and marker styling.
 // Without WebGL or if the map fails, the Google embed already in the markup is shown instead.
 var section = document.querySelector('[data-footer-map]');
 if (!section) return;
 var stage = section.querySelector('[data-footer-map-stage]'), canvas = section.querySelector('[data-footer-map-canvas]');
 var embed = section.querySelector('[data-footer-map-embed]'), loading = section.querySelector('[data-footer-map-loading]');
 var explore = section.querySelector('[data-footer-map-explore]'), replay = section.querySelector('[data-footer-map-replay]');
 var motion = matchMedia('(prefers-reduced-motion: reduce)');
 var campus = [parseFloat(section.dataset.lng), parseFloat(section.dataset.lat)];
 // Final view (280 x 180 frame): campus centred, nudged up for the label below the pin, with the
 // Amman-Madaba road and neighbouring streets for orientation.
 var FINAL = { center:[campus[0], campus[1] - .0005], zoom:14.8, pitch:48, bearing:-18 };
 // Opening view: the region between Amman and Madaba, flat and north-up.
 var START = { center:[35.87, 31.86], zoom:9.3, pitch:0, bearing:0 };
 var FLIGHT_MS = 4200;
 var map = null, marker = null, lib = null, state = 'idle', played = false, visible = false, flying = false;

 function setState(next) { state = next; section.dataset.footerMapState = next; }
 // Keep the embed out of the page while the enhanced map is in charge (it is lazy, so usually never loaded).
 var embedParent = embed.parentNode, embedNext = embed.nextSibling;
 setState('idle'); embed.remove();

 function fallback(reason) {
  if (state === 'fallback') return;
  if (reason) console.warn('Campus map: showing the standard map instead.', reason);
  try { if (map) map.remove(); } catch (e) { /* already gone */ }
  map = null; flying = false;
  embedParent.insertBefore(embed, embedNext);
  loading.hidden = true; explore.hidden = true; replay.hidden = true;
  setState('fallback');
 }
 function webglAvailable() {
  try { var probe = document.createElement('canvas'); return !!(probe.getContext('webgl2') || probe.getContext('webgl')); } catch (e) { return false; }
 }
 // Map style follows the site theme: OpenFreeMap "liberty" in Light, "dark" in Dark. The dark style has no 3D buildings,
 // so Liberty's building-3d layer (same OpenMapTiles source) is added to it with a dark fill.
 var STYLE = 'https://tiles.openfreemap.org/styles/', styles = {};
 function siteTheme() { return document.documentElement.getAttribute('data-theme') === 'dark' ? 'dark' : 'light'; }
 function getStyle(name) {
  if (!styles[name]) styles[name] = fetch(STYLE + name).then(function (r) { if (!r.ok) throw new Error('Map style ' + r.status); return r.json(); });
  return styles[name];
 }
 function styleFor(theme) {
  if (theme !== 'dark') return getStyle('liberty').then(function (liberty) { return clean(liberty); });
  return Promise.all([getStyle('dark'), getStyle('liberty')]).then(function (both) {
   var dark = clean(both[0]), buildings = both[1].layers.filter(function (layer) { return layer.id === 'building-3d'; })[0];
   if (buildings && !dark.layers.some(function (layer) { return layer.id === 'building-3d'; })) {
    var copy = JSON.parse(JSON.stringify(buildings));
    copy.paint = Object.assign({}, copy.paint, { 'fill-extrusion-color':'#34475b', 'fill-extrusion-opacity':.85 });
    var labels = dark.layers.findIndex(function (layer) { return layer.type === 'symbol'; });
    dark.layers.splice(labels < 0 ? dark.layers.length : labels, 0, copy);
   }
   return dark;
  });
 }
 // US route-shield layers are irrelevant here and use filters MapLibre 6 rejects; leave them out.
 function clean(style) {
  var copy = JSON.parse(JSON.stringify(style));
  copy.layers = copy.layers.filter(function (layer) { return !/shield/.test(layer.id); });
  return copy;
 }
 function once(eventName) { return new Promise(function (resolve) { map.once(eventName, resolve); }); }
 function view(v) { return { center:v.center, zoom:v.zoom, pitch:v.pitch, bearing:v.bearing }; }

 function showMarker() {
  if (marker || !map) return;
  var element = document.createElement('div');
  element.className = 'uims-campus-marker';
  element.innerHTML = '<i></i><span></span>'; element.lastChild.textContent = window.uimsT('MapMarker');
  // Pin on the official coordinate with the name centred below it, so it fits the narrow frame.
  marker = new lib.Marker({ element:element, anchor:'top', offset:[0, -9] }).setLngLat(campus).addTo(map);
  // Reveal once MapLibre has placed it, so it never flashes at the corner first.
  map.once('render', function () { element.classList.add('is-shown'); }); map.triggerRepaint();
 }
 function finish() {
  flying = false; played = true;
  showMarker();
  explore.hidden = true;
  replay.hidden = motion.matches;
  setState('done');
 }
 function play() {
  if (!map || flying) return;
  if (marker) { marker.remove(); marker = null; }
  explore.hidden = true;
  if (motion.matches) { map.jumpTo(view(FINAL)); finish(); return; }
  map.jumpTo(view(START));
  flying = true; setState('flying');
  // flyTo interpolates zoom, pitch and bearing together; tilt and rotation build up as the camera descends.
  map.flyTo(Object.assign(view(FINAL), { duration:FLIGHT_MS, curve:1.35, essential:true,
   easing:function (t) { return t < .5 ? 4*t*t*t : 1 - Math.pow(-2*t + 2, 3)/2; } }));
  map.once('moveend', function () { if (flying) finish(); });
 }
 // Leaving the viewport (or hiding the tab) mid-flight lands the camera instead of animating unseen.
 function land() { if (!flying) return; map.stop(); map.jumpTo(view(FINAL)); finish(); }

 async function load() {
  if (state !== 'idle') return;
  if (!webglAvailable()) { fallback('WebGL unavailable'); return; }
  setState('loading'); loading.hidden = false;
  var timer = setTimeout(function () { if (state === 'loading') fallback('timed out'); }, 20000);
  try {
   if (!document.querySelector('link[data-maplibre-css]')) {
    var link = document.createElement('link'); link.rel = 'stylesheet'; link.href = section.dataset.stylesheet; link.dataset.maplibreCss = '';
    document.head.appendChild(link);
   }
   var styleTheme = siteTheme();
   var loaded = await Promise.all([import(section.dataset.runtime), styleFor(styleTheme)]);
   lib = loaded[0];
   if (state !== 'loading') return;
   var style = loaded[1];
   map = new lib.Map({
    container:canvas, style:style,
    center:FINAL.center, zoom:FINAL.zoom, pitch:FINAL.pitch, bearing:FINAL.bearing, maxPitch:60,
    // Page scrolling stays natural: Ctrl/Cmd + wheel to zoom, two fingers to pan on touch screens.
    cooperativeGestures:true, attributionControl:{ compact:true }, fadeDuration:150
   });
   map.addControl(new lib.NavigationControl({ visualizePitch:true }), 'top-right');
   // MapLibre only tracks window resizes; follow the container too so the canvas size and camera aspect stay right.
   if ('ResizeObserver' in window) new ResizeObserver(function () { if (map) map.resize(); }).observe(canvas);
   // Keep attribution as the compact (i) toggle so it never sits under the map buttons.
   map.once('load', function () { var attribution = canvas.querySelector('.maplibregl-ctrl-attrib'); if (attribution) attribution.classList.remove('maplibregl-compact-show'); });
   map.on('error', function (event) { if (state === 'loading') fallback(event && event.error); });
   // A few point-of-interest icons are missing from the style's sprite; draw nothing for them.
   map.setMissingStyleImageResolver(function (id) { if (!map.hasImage(id)) map.addImage(id, { width:1, height:1, data:new Uint8Array(4) }); });
   // Warm the cache at both ends of the flight so no blank tiles show on arrival or departure.
   await once('load'); await once('idle');
   map.jumpTo(view(START)); await once('idle');
   clearTimeout(timer);
   if (state !== 'loading') return;
   loading.hidden = true; setState('ready');
   // Any direct interaction stops the flight where it is and hands the map over.
   ['mousedown', 'touchstart', 'wheel'].forEach(function (name) {
    map.getCanvasContainer().addEventListener(name, function () { if (flying) { map.stop(); finish(); } }, { passive:true });
   });
   // A click explicitly activates the map on desktop: plain wheel zoom until the pointer leaves.
   map.on('click', function () { if (matchMedia('(pointer: fine)').matches) map.cooperativeGestures.disable(); });
   stage.addEventListener('mouseleave', function () { if (map) map.cooperativeGestures.enable(); });
   if (motion.matches) { map.jumpTo(view(FINAL)); finish(); }
   else if (!('IntersectionObserver' in window)) explore.hidden = false;
   else if (visible && !played) play();
  } catch (error) {
   clearTimeout(timer); fallback(error);
  }
 }

 explore.addEventListener('click', play);
 replay.addEventListener('click', play);
 motion.addEventListener('change', function () { if (motion.matches) { land(); replay.hidden = true; } else if (played) replay.hidden = false; });
 document.addEventListener('visibilitychange', function () { if (document.hidden) land(); });
 // Theme change: swap the style in place. Camera, marker, flight state and controls stay as they are.
 document.addEventListener('uims:themechange', function () {
  if (!map || state === 'fallback') return;
  var wanted = siteTheme();
  styleFor(wanted).then(function (next) { if (map && siteTheme() === wanted) map.setStyle(next); }).catch(function () { /* keep the current style */ });
 });

 if (!('IntersectionObserver' in window)) { load(); return; }
 // Load shortly before the section arrives; play once when a meaningful part of it is in view.
 new IntersectionObserver(function (entries) { if (entries[0].isIntersecting) load(); }, { rootMargin:'600px 0px' }).observe(stage);
 new IntersectionObserver(function (entries) {
  visible = entries[0].isIntersecting;
  if (visible && state === 'ready' && !played) play();
  if (!visible) land();
 }, { threshold:.45 }).observe(stage);
}());
