# Home courtyard waterwheel

Historical implementation: superseded by docs/16-home-scroll-story.md. The current
Home uses the flag-to-Gate-1 sequence and tests/home-story.browser.js.

This change affects Home's hero only. Its text, links, server-side opportunity
previews, configured academic data and dedicated internship video section remain.
No authentication, Firebase repository, role master or private-page code changed
for this feature. Earlier public-page work is already present in this checkout.

## Reference and reconstruction

All 17 supplied PNGs in Assets/images/university were visually opened at intake.
Primary detail reference: b774db96-c900-40dc-b579-3fa681fb49ec.png. Courtyard photos
8ce94153, a2ffd44c, 6753e8dc and 4892847c cross-check wheel depth, spokes, masonry
and timber. The campus rendering is secondary; it does not override the photos.

The procedural Group factory constructs two flat-section annular rims, radial
timber spokes, transverse paddles, hub/axle, bearing seats and stone supports,
four arcade columns and lintel, a blue basin, static water and a small facade
fragment with gridded glazing. No downloaded model or photo-covered flat plane
is used. Only the wheel subtree rotates, around its central horizontal Z axle,
at 0.055 radians/second (about 114 seconds per revolution).

The installed img2threejs intake, assessment, strict spec validation, initial
TypeScript generation, reference PBR extraction and diagnostic tools were used.
The served factory is plain JavaScript, adapted for the existing Web Forms build.
The spec, generated starter, reference crops and diagnostic evidence are retained
under .img2threejs. The starter is not a runtime dependency.

**Quality limit:** this is an approximate procedural reconstruction, not a measured
campus model or exact photographic reproduction. The skill's aligned-photo Tier 1
gate did not pass: final silhouette IoU 0.323 against its 0.85 threshold, aspect
delta 0.143 and scale delta 0.390. Its reference mask also excluded 19.8% of the
photographic foreground. The primary photo is a close, low-angle view, whereas
the hero shows an elevated complete fragment. These results are retained as
failures; they are not relabeled as passes. The strict sequential skill pipeline
therefore is **not certified complete**. A stop review records this limit.

Known approximations: normalized dimensions (wheel radius 3.15, rim separation
0.92), 32 inferred paddle stations, 12 spokes per face, simplified hidden bearings
and water feed, generic surrounding window placement, and procedural grain/stone
courses instead of the exact photographed surface. The water is a static surface
with restrained glints, without spray, caustics or fluid simulation. The rear wall
is intentionally simple. A reference photo/render comparison is in test artifacts.

## Integration and lifecycle

- Default.aspx owns the figure, meaningful image alternative, caption and native
  type=button pause/resume control; all title/call-to-action text remains HTML.
- home-courtyard.js defers imports until the hero approaches the viewport and an
  idle callback runs. It leaves the real reference photograph visible until the
  first successful render. JavaScript, module or WebGL failure retains the photo.
- courtyard-scene.js owns renderer/camera/lights/lifecycle; courtyard-model.js owns
  the reconstruction. Three.js 0.180.0 is vendored locally with its MIT license;
  browser requests need no CDN and no new build tool/framework is introduced.
- DPR <=1.5, backing buffer <=1200x1000 and animation capped at 30 fps. The sampled
  scene uses 5,336 triangles and 32 draw calls. Repeated geometry is instanced.
- Offscreen and hidden-document states stop rendering. Reduced motion starts
  static and changes pause it; frame sampling also handles coalesced media events.
  Explicit Resume is an intentional opt-in. Canvas does not capture scroll/pointers.
- Scene disposal removes listeners/observers/canvas and releases instancing,
  geometry, material, texture, shadow and renderer resources. Context loss restores
  the photo. Non-BFCache pagehide disposes; the host's courtyardScene.dispose()
  also supports an explicit future route lifecycle.
- Named parts expose pivot, socket, collider-intent and non-breakable metadata.
  Picking/exploded inspection share those parts; these are development APIs, not
  additional public interactions. Explosion is off in the hero.

## Verification

Debug MSBuild and JavaScript syntax checks passed. Playwright CLI passed:

- 46 dedicated scene checks: actual rotation, static architecture, keyboard pause,
  offscreen pause, reduced motion/change/explicit resume, 320/390/768/1440/2560px
  overflow and buffer caps, DPR=3 phone capped at 1.5, disposal with zero retained
  GPU geometries/textures, WebGL unavailable/context loss, failed module and no-JS
  photo fallback, Home links, opportunity/video preservation and visitor denials.
  Hidden-document handling uses a deterministic hidden getter + visibilitychange;
  offscreen behavior uses real scrolling. This is not a claim about OS tab suspension.
- 32 existing public-requirement assertions, including protected visitor routes
  and preview privacy; uses disposable IIS/Firebase stand-in and session fixtures.
- 158 existing public regression assertions on six routes. A disposable copy points
  the suite to the current stand-in port 4903 instead of its default 4902.

Total: 236 passing browser assertions, no unexpected browser/console errors.
No live Firebase writes, emails, deployment or Git push were performed.
Part coverage reported 17 specified non-root parts, 18 built including root,
zero errors/warnings. Four actual 90-degree orbit captures passed turntable coverage
and non-collapse; through-holes are intentional for the wheel/arcade. These checks
prove structural presence/self-consistency, not photographic fidelity. The back
of the context wall naturally occludes the landmark from the rear.

Impeccable's detector returned no deterministic findings; desktop/tablet/mobile
screenshots were inspected. Design-taste inspection found no overflow, broken
images or console errors. Its generic hairline/four-photo/eight-moving-element
rules were explicitly allowed: approved branding retains quiet borders, this is
a hero-only change with one live model, and additional motion/imagery would exceed
the brief. These exceptions do not waive functional or accessibility checks.

Screenshots: tests/artifacts/courtyard-home-{1440,768,390}.png,
courtyard-fallback-mobile.png and wheel-reference-comparison.png.
Run the targeted checks with playwright-cli run-code
--filename=tests/home-courtyard.browser.js against disposable IIS on 57983.
