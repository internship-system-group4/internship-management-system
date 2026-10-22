# Home: Jordan/Germany to Gate 1

This supersedes the waterwheel hero described in document 15. Only Home and its
assets/project content entries changed for this feature. Default.aspx.cs, Firebase
repositories, authentication/authorization, shared role layouts and dashboards
retain their existing behavior. Older waterwheel source is retained but not loaded.

## Implemented experience

The opening has two national flags on fixed poles behind a procedural Gate 1.
Desktop native scrolling moves the camera from the upper poles down toward the
entrance. GSAP ScrollTrigger 3.13.0 scrubs this camera state with a short 0.35-second
catch-up. The scene uses native CSS sticky positioning alongside two meaningful
HTML chapters; there is no artificial pin spacer, wheel interception, snap,
scroll-smoothing plugin, long empty hold or dependency on canvas for page content.
Scroll in either direction, including after resizing, restores the correct view.

An accessible native button pauses/resumes continuous cloth movement independently
of the user's camera scrolling. Hoist vertices are fixed; free cloth vertices use
small phase-offset waves and updated normals. This is a lightweight visual cloth
approximation, not a physical wind/cloth solver.

At <=820px the scene uses a compact overview showing flags and gate together; it
does not pin or animate the camera. Reduced motion uses a static overview with
static cloth and no scroll tween. Live preference changes are supported, including
sampling while rendering when browsers coalesce media-query change events.

Direct HTML links reach colleges, process video and opportunities. The single
project-configured college, School of Computing, is a native details/summary
control. Opening it reveals Computer Engineering/Computer Science and the tracks
from Common/Constants.cs. It works with keyboard input and JavaScript disabled.
A small static Three.js microchip is its computing symbol; a native SVG remains
if the decorative enhancement cannot load. There are no invented extra colleges.

The existing four internship stages remain, followed by the dedicated video
section and server-rendered public opportunity summaries. The public projection,
encoding/filtering and authenticated Student details/application routes remain.
The video section has normal document flow, outside the camera transition range.

## References, fidelity and approximations

Gate 1 front reference: Assets/images/university/b1138b1f-421a-4fb1-9003-2d233d57c05c.png.
Cross-check: 4f98f98f-d0d8-4b5a-917e-0d37d8b2f5a5.png, the same gate from the side.
Gate 4 and campus renderings were not mixed into Gate 1. The supplied official
gju-logo.png is reused unchanged in HTML and on the sign. Sign text and gate number
come from the photographs; its typeface/spacing are approximate.

Jordan's cloth is 2:1 with the red hoist triangle, equal black/white/green bands
and seven-point white star. The star uses the triangle's angle-bisector incenter
and a circumscribing diameter L/14. Reference: [Article 4, Jordanian Constitution,
WIPO Lex](https://www.wipo.int/wipolex/en/legislation/details/22013).
Germany uses equal black/red/gold bands and a 3:5 height:length ratio: [Federal
flag order](https://www.gesetze-im-internet.de/flaggano_1996/i_.html).
RGB choices are conventional screen renderings, not a claim about fabric dyes.

The requested Jordan/Germany pairing and taller poles are an identity staging;
the reference photo itself shows two Jordanian flags. Pole positions/heights,
normalized portal dimensions, hidden rear surfaces, right return, masonry relief,
road extent and fence opening are simplified. This is a recognizable procedural
illustration, not a site survey or exact photogrammetric model. No extra campus
buildings, unverified academic programs, people or background partners are added.

img2threejs intake, local evidence search, assessment/spec, strict validation,
starter generation, stone PBR evidence and reference comparison are retained under
.img2threejs/gate-*. The served reconstruction is the plain JavaScript Group
factory, not a TypeScript build dependency. Stone reference extraction reported
0.831 confidence; that is an inference metric, not a visual-fidelity score.
The spec passes strict validation. Actual runtime part coverage reports 11
specified non-root parts, 55 named built nodes, zero errors/warnings.

The skill's aligned-photo diagnostic does not pass (IoU 0.207, aspect/scale deltas,
and absent map-stripped evidence). The reference mask excludes 28.5% of the photo
foreground. These failures are retained as failures; the full sequential skill
pipeline is not claimed as completed or photographically certified. Browser
behavior and independently sampled flag pixels have their own checks below.

## Missing video

No internship-process MP4 or captions were supplied/found. The page therefore
retains a clearly marked development placeholder. Add the approved files at
Assets/video/internship-process.mp4 and internship-process.en.vtt. Existing server
file checks then show native controls, a university poster and supplied captions.
No unrelated clip is substituted. Actual playback/caption timing could not be
tested without those assets.

## Runtime and performance

- Three.js r180 is reused; GSAP/ScrollTrigger 3.13.0 are vendored with notices.
  Browser requests are local. No framework migration, package-manager runtime or
  new build tool is introduced. See the vendor README for provenance/terms.
- Idle/near-viewport loading leaves the reference photograph and HTML available.
  The canvas is revealed after its first successful render. Dependency failure,
  unavailable/lost WebGL, shader failure or render failure restores the photograph.
- Continuous rendering caps at 30 fps, DPR <=1.5 and a <=1200x1000 backing buffer.
  The gate model has 3,278 triangles in total. The observed endpoint draws 2,942
  visible triangles in 46 calls; normal frustum culling changes visible counts.
  The computing symbol uses three draws and renders only on demand.
- Offscreen/hidden documents stop scene drawing. Geometry, textures, materials,
  shadow maps, renderers, listeners, observers and the page's own ScrollTrigger
  are released on disposal/context loss/non-BFCache pagehide. Canvas does not
  capture pointers or mobile scrolling. The video does not move with the camera.

## Verification

Debug MSBuild, JavaScript syntax checks and git diff --check passed.
Playwright CLI passed 255 local browser assertions:

- 65 in tests/home-story.browser.js: actual flag texture colors/proportions and
  seven star tips, cloth movement/pinned hoist, stationary architecture, camera
  descent/reverse, resize while at the gate, keyboard pause/college selection,
  anchors, college data, offscreen pause, reduced-motion updates, 320/390/768/
  1440/2560px layout, high-DPR cap, GPU disposal, context failure, failed dependency,
  no-JS fallbacks and server visitor restrictions. Hidden-document delivery uses
  a deterministic hidden getter/visibilitychange; OS tab suspension is not asserted.
- 32 public-requirement assertions, updated to open the college disclosure and
  inspect academic information in its new section. Privacy/error/role checks use
  the existing disposable Firebase stand-in and verified profile fixtures.
- 158 existing public UI regression assertions, with a disposable script copy
  selecting the current stand-in port 4903 instead of its default 4902.

No unexpected browser/console errors occurred in those checks. No live Firebase
sign-in, reset email, shared database writes, deployment or Git push is asserted.
The historical tests/home-courtyard.browser.js targets the replaced feature; use
tests/home-story.browser.js for the current Home experience.

Desktop/mobile screenshots were inspected against the local references.
Impeccable's detector returned no deterministic findings. Design-taste measured
no overflow, broken images or console errors at 1440/768/390px. Explicit exceptions:
approved quiet borders/outlined controls, a 3D story instead of four decorative
photos, restrained movement instead of eight moving DOM elements, and a false
eyebrow detection on an actual specialization list entry. These exceptions do
not waive usability, content accuracy or accessibility checks.

Screenshots: tests/artifacts/story-flags-final.png, story-gate-final.png,
story-mobile-final.png, story-colleges-final.png, story-colleges-mobile.png,
story-fallback-mobile.png and story-gate-reference.png.
