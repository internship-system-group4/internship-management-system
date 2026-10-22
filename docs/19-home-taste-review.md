# Home design-taste refinement — 22 October 2026

Applied the explicitly requested `design-taste-frontend` skill to the existing Home
page. Retained **The printed annual / editorial-report**, seed **1444959711**, and
the existing local Switzer family. No direction or asset-slot redraw in this pass.

## Subject, argument and live interaction

GJU's Gate 1, timber courtyard wheel, stone supports, basin, horizontal windows,
glazed connector, original logo, university reference photographs, configured
computing programs and real internship workflow supply the subject inventory.

Idea: the university's recognizable entrance and courtyard become the architectural
masthead of the student's journey into internships. The live interaction is one
continuous scroll-controlled campus, with actual study-program disclosure and
landmark/section navigation. It works with touch scrolling, keyboard activation
and an ordinary static document when motion or WebGL is unavailable.

Page argument remains campus → system connection → configured study programs →
four actual workflow steps → published summaries. A new photographic section
connects that miniature to the real campus; the guide, public opportunities and
login close retain their actual functions.

## Concrete changes

- One ink color across both headline lines; neutral daylight ground `#f1f3f2`.
- Named navigation (Campus, Connect, Study, Journey, Explore) replaces visible
  index numbering. Full accessible chapter names and current-step semantics remain.
- Five type roles per viewport: display, section heading, subheading, body and
  supporting notes. Body copy is 16px in the university ink, including portrait.
- Three large actual reference photographs in an asymmetric gallery, with descriptive
  captions. This brings the page to four visible real photographs plus the loading
  photograph; there are no generic stock substitutes.
- Public previews use editorial rows, with readable responsive grouping rather than
  a row of identical outlined cards. Data filtering and protected links are unchanged.
- Removed Home-only resting outlines and header/footer separators. Shared public
  pages and authenticated portals retain their existing rules.
- Added one-time entrances for section headings, text and real photographs. Content
  remains visible without script; reduced motion drops travel. No extra animation
  loop or scrolling library is introduced.
- Added explicit native scrolling for Home's internal anchors. This resolves browser
  fragment navigation failing to scroll toward an inactive chapter's inert inner
  content. The existing ScrollTrigger remains the sole camera authority. Keyboard
  activation focuses the destination; history is retained and tested.
- The custom scene exposes real `is-live`/`is-rest` lifecycle classes and `data-scene`
  metadata for the skill's scene capture tools. Live means an actual rendered campus
  and active scroll timeline; failure/reduced-motion/disposal clears that state.

Files: `Default.aspx`, `Assets/css/home-experience.css`,
`Assets/js/home-experience.js`, `Assets/js/home-story.js`,
`Assets/js/home-story-scene.js`, the project publish manifest,
`tests/campus-redesign.browser.js`, and this report. The landmark mesh factories
are unchanged; earlier reconstruction fidelity limits still apply.

## Picture provenance

All pictures were already supplied in `Assets/images/university`; no external
photographs, clips, neural assets or invented opportunities were added.

| Visible picture | Local reference | Placement |
| --- | --- | --- |
| Courtyard wheel and basin | `b774db96-c900-40dc-b579-3fa681fb49ec.png` | Large gallery panel |
| Gate 1 university entrance | `b1138b1f-421a-4fb1-9003-2d233d57c05c.png` | Gallery panel |
| Glazed connector | `4a85f19e-09cd-47d5-b8de-a18f277616a7.png` | Gallery panel |
| Courtyard overview | `6753e8dc-1deb-4e1d-848c-79304737fb69.png` | Guide section |
| Aerial campus | `b270da86-de83-4a48-898d-7446958fbe45.png` | Loading/WebGL fallback |

Creator and license metadata were not supplied with these project references;
no attribution or ownership claim was invented. Captions identify the subjects.
The campus is a procedural drawing of those reference landmarks, with inferred
hidden dimensions and artistic adjacency. No authentic video or captions exist
in the project, so the explicit missing-video notice remains.

## Critique rounds

ROUND 1
Seen in one second: oversized two-color title and a campus miniature, with numbered controls.
Idea (one sentence): GJU's landmarks form the student's route from study to internships.
Live thing: scroll journey and configured college disclosure.
Layout words by section: hero=masthead / chapters=reading panels / guide=split / opportunities=cards / close=statement.
Scores: design 6.5 · usability 7.6 · creativity 7.5 · content 5 → overall 6.0 after cap.
Caps applied: two inspector FAILs (numbering and insufficient real pictures); explicit missing-video placeholder limits content to 5.
Top three problems (most visible first), each with the screenshot it shows in and the fix:
1. Numbered navigation duplicates the hierarchy in `taste-fix-before/desktop-fold.jpg`; replace it with plain named destinations.
2. The generated world lacks photographic context in `taste-fix-before/desktop-page-02.jpg`; use the actual gate, wheel and connector references as large pictures.
3. Mixed type sizes and headline colors dilute the hierarchy in the before fold captures; use one headline ink and a smaller set of type roles.

ROUND 2
Seen in one second: a clear navy title over a campus, followed by recognizably real university photographs.
Idea (one sentence): the architectural masthead continues into the actual campus's stone, timber and glazing.
Live thing: scroll journey and named landmark navigation.
Layout words by section: hero=masthead / chapters=reading panels / photographs=asymmetric folio / guide=split / opportunities=rows / close=statement.
Scores: design 7.7 · usability 7.9 · creativity 7.8 · content 5 → overall 7.5.
Caps applied: missing-video placeholder limits content to 5; inspector has zero FAIL.
Top three problems (most visible first), each with the screenshot it shows in and the fix:
1. Thirteen computed font sizes remain in `taste-fix-after` captures; consolidate into five roles and verify again.
2. Some portrait running text was smaller than the desired body role; unify body copy to 16px.
3. The official video is still absent in the guide capture; retain the honest photographic notice instead of inventing a player.

ROUND 3
Seen in one second: large single-ink title, recognizable university architecture and an obvious internship action.
Idea (one sentence): real GJU landmarks and photographs carry the same architectural narrative from the opening to the guide.
Live thing: continuous camera journey, keyboard/native chapter navigation and actual program disclosure.
Layout words by section: hero=masthead / chapters=reading panels / photographs=asymmetric folio / guide=split / opportunities=rows / close=statement.
Scores: design 7.9 · usability 8.2 · creativity 7.8 · content 5 → overall 7.7.
Caps applied: content remains capped at 5 for the explicit missing-video placeholder; no inspector FAIL remains.
Top three problems (most visible first), each with the screenshot it shows in and the fix:
1. `taste-fix-final/desktop-page-02.jpg`: the guide needs the university's real video/captions. This asset remains unavailable and is reported, not simulated.
2. Scene contact sheets: the procedural buildings retain approximate simplified edges and surfaces. A further modeling task is needed for measured architectural fidelity.
3. `taste-fix-final/tablet-page-01.jpg`: long specialization names wrap densely in the two program columns. Text is readable and complete; a future single-program selector could reduce that density.

These are subjective visual-review scores, not external jury ratings. Three visual
rounds were performed; no open-ended styling loop is claimed.

## Meter and browser evidence

- Before: **2 FAIL** (numbered navigation, insufficient pictures).
- Final `inspect.mjs`: **0 FAIL** at 1440, 768 and 390px; one warning for unavailable
  footage. No footage is added because the actual university video was not supplied.
- `scenes.mjs` on the final styling: the campus runs on desktop and phone, with
  before/after and 0–100% captures at ten-percent increments. Reduced-motion sheet
  contains normal document content. All three contact sheets were opened and reviewed.
- Final inspector screenshots reviewed: desktop fold and all three desktop sheets,
  tablet fold and both sheets, mobile fold and both sheets.
- Source lint covers the CSS and JavaScript. ASPX is not a supported static-lint
  extension; the rendered inspector and browser suites cover its HTML output.
- MSBuild and JavaScript syntax checks pass. Existing unrelated Contact files emit
  line-ending notices in `git diff --check`; no whitespace errors were introduced.
- Browser suites: 56 campus checks, 17 navigation checks (including browser Back
  and Forward), 32 public-flow checks against the local Firebase stand-in, and
  5 first-frame/touch-target checks: **110 assertions pass**. The Back/Forward
  checks exposed browser fragment restoration retaining the old scroll offset;
  `popstate`/`hashchange` now explicitly restore the native anchor destination.
  No competing camera animation is created. Expected WebGL/module failures are
  isolated from healthy-page console/request checks; healthy-page errors are zero.
- Source lint: 4 CSS/JavaScript files, **0 FAIL / 0 WARN**. No deployed Firebase
  rules, real sign-in/email delivery or physical-device performance is claimed.

Evidence: `tests/artifacts/taste-fix-before.json`, `taste-fix-final.json`,
`taste-fix-final-lint.txt`, `taste-fix-scenes-final.txt`,
`taste-fix-campus-tests.txt`, `taste-fix-navigation-tests.txt`,
`taste-fix-public-tests.txt`, and `taste-fix-loading-tests.txt`.
The visual artifacts live in `.taste-skill/taste-fix-final/` and
`.taste-skill/taste-fix-scenes-final/`.
