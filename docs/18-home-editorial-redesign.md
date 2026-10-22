# Home architectural editorial redesign

## User authorization and scope

On 22 October 2026 the user explicitly authorized a broader, larger and more
distinctive page, releasing earlier composition restrictions. This redesign keeps
the existing application, university identity, actual data and accessibility
requirements. It changes Home's composition, typography and normal-flow sections.
It does not replace the authenticated portals or alter Firebase authorization.

## Direction

On this page, GJU's recognizable entrance and courtyard wheel become an expansive
architectural masthead. A two-line statement leads into a continuously rendered
campus rather than a narrow copy column beside a miniature. Five named chapters
provide meaningful wayfinding; the same scroll position controls the camera.

Subject inventory: original GJU logo, Gate 1 bilingual lintel, two different gates
that must not be confused, timber courtyard wheel, stationary stone supports,
water basin, limestone facades, glazed connector, Jordanian/German identity,
configured computing programs, real internship workflow and protected opportunities.

Seven grounded systems considered: campus atlas, architectural exhibition,
university prospectus, architectural annual, student journey booklet, folded study
plan and courtyard photographic folio. Architectural annual is the selected system:
large type, warm stone-derived ground, navy ink, a strict reading axis and large
real imagery. The design-taste draw selected `editorial-report` with Switzer.
Its disconnected two-by-two hero and stock photo instructions were not adopted
because the deliverable continues one actual campus world. Impeccable's direction
seed was run after recording the product facts; the user had already delegated
the redesign decision, so no additional direction approval was requested.

Catalog challengers were assessed against the actual product: convention grids,
festival flyers, paper lantern sculpture, neon rainy-city imagery, drum-machine
controls and a shader portal. Dense grids, festival styling and instrument controls
weaken the campus's hierarchy; paper sculpture and a shader portal replace rather
than clarify the actual landmark evidence; neon conflicts with the university's
daylight setting. The selected direction takes their ambition in spatial scale,
clear state and navigation, not their motifs.

## Page argument and copy

- Campus today. Career tomorrow. — the actual recognizable campus introduces
  the internship system; a visible action leads to real opportunities.
- A shared starting point. — one system connects students, companies and supervisors.
- Your field. Your future. — actual Constants supply the college and specializations.
- Learn. Apply. Grow. — the existing four workflow steps remain readable in HTML.
- Make your next move. — public summaries lead to protected details and applications.
- See the path ahead. — a real courtyard photo accompanies the explicit missing-video
  notice; there is no fabricated player or footage.
- The next chapter is yours. — actual Firebase-backed previews, or honest empty/error
  states, receive a full-width navy field.
- Ready for your next chapter? — a large closing section leads into login.

## Implementation

- `Default.aspx`: new headline/copy hierarchy, five accessible chapter links,
  real courtyard photograph and redesigned normal-flow section composition.
- `Assets/css/home-experience.css`: Home-only Switzer typography, large opening,
  warm stone ground, compact story navigation, flat chapter reading surfaces,
  guide photography, navy opportunities section and full-width closing action.
- `Assets/fonts/`: original Switzer 400/600/700 WOFF2 from official Fontshare;
  source and license link in README. Served locally, no runtime font CDN request.
- `Assets/js/home-story-scene.js`: enlarged central opening, smoothly interpolated
  framing, copy-zone-aware hotspot avoidance and native-scroll-driven current chapter.
- `Assets/js/home-story.js`: progressive module URL updated to campus-6.
- `InternshipManagementSystem.csproj`: publish stylesheet, fonts and real photo.
- `PRODUCT.md`: existing confirmed product facts and explicit Home redesign scope.
- `tests/campus-redesign.browser.js`: named chapter links, pointer/keyboard access,
  native scroll, current-state announcement, guide photo and responsive navigation.

The first render revealed a real interaction defect: the full-width opening copy
container intercepted clicks in its otherwise empty area. It now ignores pointer
events while its heading and introduction retain their own interaction zones.
Meaningful text and actions remain HTML; the canvas remains decorative.

Native anchor targets also remain outside inert content. Only each invisible
chapter's inner copy is inert, and both failure recovery and disposal clear that
state. Normal-flow sections reset the old 32px scroll margin so entering the guide
fully releases the sticky scene. Browser tests cover both regressions.

## Final verification

Actual ASP.NET Web Forms application in the existing disposable IIS Express host
at localhost:57983, with the existing local Firebase stand-in at localhost:4903:

- Debug MSBuild, JavaScript syntax checks and `git diff --check`: pass. Existing
  Contact source files produce line-ending notices only.
- `tests/home-campus.browser.js`: 56 assertions pass, including all five chapters,
  reverse scroll, projected hotspot clicks, keyboard college controls, sticky exit,
  widths 320–1920, reduced motion, failed modules, WebGL/context loss and disposal.
  Inert assertions now inspect the actual inner copy after the anchor fix.
- `tests/campus-redesign.browser.js`: 15 assertions pass for chapter navigation,
  keyboard return to overview, current-step announcements, guide photography and
  navigation at 320, 390 and 768px.
- `tests/campus-loading.browser.js`: 5 assertions pass for delayed-frame photo,
  accessible first content, handoff to WebGL and mobile landmark target size.
- `tests/public-requirements.browser.js`: 32 assertions pass against local fixture
  data, including public summary filtering, private-data sentinels, protected detail
  and application routes, empty/error states and real configured specializations.
  These results do not establish production Firebase rules or real sign-in/email.
- Total: 108 passing browser assertions. Healthy-page errors and failed requests:
  zero. Explicit failure scenarios run in isolated contexts.
- Source design detector returned `[]`. Initial taste inspection identified the
  tablet college headline wrapping; the shorter final heading resolves it. Actual
  chapter numbering, the warm architectural ground and the live canvas counting
  limitation remain the intentional exceptions described below.
- Final desktop/portrait capture covers all five chapters. Latest portrait final
  view: 19,643 visible triangles and 141 draw calls, no overflow. Physical-device
  performance is not claimed from Chromium viewport emulation.

Evidence in `tests/artifacts/`: `campus-redesign-verification.txt`,
`campus-redesign-navigation.txt`, `campus-redesign-public.txt`,
`campus-redesign-loading.txt`, `campus-redesign-capture.txt`,
`campus-redesign-design-check.json`, `campus-redesign-inspection.json`,
`home-redesign-desktop.png`, `home-redesign-mobile.png`,
`redesign-guide-desktop.png`, `redesign-opportunities-desktop.png`, and
`campus-redesign-review.jpg`. Browser verification is complete for this local
presentation change; no deployment was requested or performed.

## Quality limits

The campus is still an architectural approximation; hidden geometry and adjacency
are unverified. This is a presentation redesign, not an approved new img2threejs
reconstruction pass. The Tier 1 limitation in docs/17 remains applicable.
No video, university policy, partner, opportunity or endorsement was invented.

Taste inspection sees numbered navigation as decorative numbering and does not
count the live Three.js world as an image. The numbers actually identify ordered
chapters and announce the current step. Warm limestone-derived ground, original
header chrome and local reference photography are deliberate choices. The video
warning remains open because the official video is missing. These heuristic
exceptions are not claimed as a blanket design-detector pass.
