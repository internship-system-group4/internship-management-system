# Three.js runtime

Pinned package: three@0.180.0, MIT (see THREE-LICENSE.txt).

Files downloaded unchanged from the package's published build:
https://cdn.jsdelivr.net/npm/three@0.180.0/build/three.module.min.js
https://cdn.jsdelivr.net/npm/three@0.180.0/build/three.core.min.js

The module imports its adjacent core. Both files must be published together.
Home (university story and computing symbol), Login (gate scene) and Powered by
(team lecture hall) load this runtime asynchronously; no other page does. The earlier
courtyard implementation remains as unused source.

GSAP and ScrollTrigger are pinned to 3.13.0, downloaded unchanged from
https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/gsap.min.js and
https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/ScrollTrigger.min.js.
Their original headers retain copyright/terms notices; see GSAP-NOTICE.txt and
https://gsap.com/standard-license/. The GSAP scripts are not covered by Three.js's
MIT license. Both scripts load only when Home's story approaches the viewport.

MapLibre GL JS is pinned to 6.13.0 (BSD-3-Clause, see maplibre/LICENSE.txt). Its files were downloaded unchanged from
https://cdn.jsdelivr.net/npm/maplibre-gl@6.13.0/dist/ (maplibre-gl.mjs, maplibre-gl-worker.mjs, maplibre-gl.css).
Only the public footer's campus map loads it, when the footer approaches the viewport. Map data and tiles come from
OpenFreeMap (OpenStreetMap data, ODbL; no key or account), and the map keeps their attribution visible.
