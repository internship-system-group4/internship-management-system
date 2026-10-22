# Home: immersive campus story

## Larger presentation and material refinement — 22 October 2026

Follow-up request: make the campus larger, more realistic and distinctive. The same continuous scene and scroll timeline remain in use.

- Desktop camera distances reduced to 88/94/93/91/92 percent of the previous chapter distances. Tablet multiplier reduced from 1.3 to 1.18. Portrait multiplier reduced from 1.57 to 1.4, with an additional 0.13 reduction around the entrance chapter. The desktop view offset is -0.16 viewport widths, and the opening copy has a narrower measure to reveal more of the entrance.
- Limestone uses a neutral photographic tint and reduced bump amplitude (0.024 to 0.014). Glazing now uses dielectric parameters (metalness 0, IOR 1.5, roughness 0.12), with the existing prefiltered daylight environment. Sky intensity 0.85, sun 3.4 and exposure 1.02 improve directional depth without bloom.
- Added five shared soft contact-occlusion patches beneath landmark/building footprints. They also work on phones with realtime shadows disabled. These are artistic ambient-occlusion approximations, not measured light transport.
- Leaf clusters use an elliptical alpha footprint and 155 deterministic leaf shapes, replacing the sparse square distribution. No external artwork or new dependencies were added.
- Changed `Default.aspx`, `home-story.js`, `home-story-scene.js`, `home-campus-model.js`, `home-campus-materials.js`, `home-story.css` and `.img2threejs/campus-assembly.json`. Versioned module URLs updated to `20261022-campus-5`; hierarchy, authentication and public-data access are preserved.
- Final verification: MSBuild and JavaScript syntax checks pass; 56 campus assertions and 5 loading/touch-target assertions pass. Healthy-page console errors and failed requests: zero. All five desktop and portrait chapter captures reviewed. Final portrait frame: 20,003 visible triangles, 150 draw calls, no horizontal overflow. Mechanical design detector returned `[]`.
- Evidence: `tests/artifacts/campus-larger-verification.txt`, `campus-larger-loading.txt`, `campus-larger-capture.txt`, `campus-larger-design-check.json`, and `campus-larger-review.jpg`. Supplied photographs still govern recognizable landmarks; hidden dimensions and artistic adjacency remain approximate. No new reconstruction fidelity pass is claimed, and the earlier Tier 1 limitation below still applies.

## Verification refresh — 22 October 2026

Reused the existing campus implementation and inspected its current source and all 17 references in the labeled reference sheet. The latest runtime includes photo-derived limestone maps, recessed framed glazing, coursing, water normals, a daylight environment and deterministic leaf clusters. These additions existed when this review began; they are not new reconstruction passes or certified geometry.

Changes in this refresh:
- `Assets/js/home-story-scene.js`: preserve the university loading photograph until the first successful WebGL draw; hide motion controls until that frame exists. Ignore queued state synchronization after disposal so it cannot replace the failure state.
- `Assets/css/home-story.css`: increase portrait hotspot targets from 38px to 44px minimum height.
- `Assets/js/home-story.js` and `Default.aspx`: update Home asset versions to `20261022-campus-4`.
- `tests/campus-loading.browser.js`: verify the loading photograph, heading and first action while animation frames are deliberately delayed, successful handoff to WebGL and mobile hotspot target size.

Actual ASP.NET/IIS Express verification at `http://localhost:57983`, using the existing local Firebase stand-in on port 4903:
- MSBuild Debug and JavaScript syntax checks: pass. `git diff --check`: pass, with existing Contact file line-ending notices.
- `tests/home-campus.browser.js`: 56 assertions pass after the changes. No healthy-page console errors or failed requests. All five desktop and mobile chapter screenshots regenerated and reviewed; tablet, fallback and reduced-motion captures retained. Viewport checks cover 320, 390, 768, 1440 and 1920px; these are Chromium viewport tests, not physical-device performance certification.
- `tests/campus-loading.browser.js`: 5 assertions pass, including a deliberately delayed first frame.
- `tests/public-requirements.browser.js`: 32 assertions pass against local fixture data. No real Firebase sign-in, production database rules or reset email delivery is asserted.
- An initial run in the previously open default browser timed out; a fresh named browser session completed the campus suite, and the suite passed again after the changes. The delayed-frame test initially stalled because Playwright's default polling itself used animation frames; fixed that test to poll its mount predicate on a timer.
- Current Impeccable source detector: `[]`. Taste inspection ran at 1440, 768 and 390px; its remaining heuristic findings are documented exceptions, not a full design-heuristic pass. User-specified headlines can occupy three lines, original shared header/footer styling remains, and generic demands for stock imagery or extra section animation do not override the campus brief.
- Current overview observed approximately 23,159 visible triangles and 186 draw calls. This supersedes the earlier 12.7k observation below and exceeds the original assembly's 18k target; it remains a modest scene, but weaker physical devices were not profiled.
- A final fresh-load capture with `tests/campus-capture.browser.js` confirmed all five desktop and portrait compositions. Separate camera snapshots progressed through 0, 0.257278, 0.514218, 0.771496 and 1 on portrait, including the lowered entrance view. The paused final portrait frame measured 20,943 visible triangles and 155 draw calls, with no overflow.

Evidence: `tests/artifacts/campus-current-verification.txt`, `campus-loading-verification.txt`, `campus-public-current-verification.txt`, `campus-impeccable-current.json`, `campus-taste-current.json`, and `campus-desktop-chapter-1.png` through `-5.png` plus their mobile counterparts.

**Reconstruction validation remains incomplete.** The img2threejs state router remains at `tier1-diagnostics`, blockout. Its prescribed diagnostic was rerun against the existing wheel evidence: silhouette IoU 0.3233, aspect delta 0.1429, scale delta 0.3898, plus missing map-stripped evidence. It did not pass; no AI fidelity score or later-pass approval was recorded. The skill's gate reference requires: “Tier 2 (AI-vision) never runs against a render that has not passed Tier 1.” Existing spec/manifest part coverage reports 17 specified and 18 built with no errors, which proves only manifest coverage, not current visual fidelity. This implementation is a working approximate campus experience, not completion of the skill's full reconstruction pipeline. Measured geometry, concealed elevations and actual landmark adjacency remain unverified. The real explanation video and captions are still missing.

The current Home composition supersedes docs/15 and docs/16. Scope is Default.aspx only; shared navigation/footer, authentication and Firebase repository code remain intact.

## Visual contract
The campus itself becomes the page-wide environment. One persistent Three.js canvas fills a native CSS-sticky viewport behind five semantic HTML chapters. GSAP ScrollTrigger drives a single normalized progress value, continuous camera/target interpolation, projected landmark controls and chapter visibility. Native scrolling and anchors work in either direction. CSS sticky containment releases directly into the stable video and opportunity sections without a generated pin spacer. Official branding remains in Public.master; public Home styles do not touch private portals.

## Reference evidence and approximations
All 17 PNG references in Assets/images/university were opened in a labeled contact sheet (tests/artifacts/campus-reference-sheet.jpg). Entrance photographs show two different gates. Gate 1 uses b1138b1f-421a-4fb1-9003-2d233d57c05c.png plus side view 4f98f98f-d0d8-4b5a-917e-0d37d8b2f5a5.png. Gate 4 (75b9d161...) is excluded. The courtyard views (0a1457e2...,12f978b4...,2215249b...,41811513...,4892847c...,6753e8dc...,6ba2998a...,8ce94153...,a2ffd44c...) corroborate the wheel, stone piers, glazing and strip windows. Primary close-up remains b774db96-c900-40dc-b579-3fa681fb49ec.png. Aerial photograph b270da86... is the loading/failure fallback. Campus renderings are secondary only.

Reuses img2threejs gate/wheel specs, generated stage factories and existing procedural meshes. The state router was rerun and its next gate-blockout factory emitted as .img2threejs/campus-gate-blockout.ts. Runtime assembly is plain JavaScript. This is an architectural approximation, not certified photogrammetry or a completed skill fidelity pipeline. Earlier photo-alignment diagnostic failures remain documented in docs/16; no passing score is invented.

| Element | Evidence and limit |
| --- | --- |
| Gate 1 | Bilingual beam, piers, metal gate, right return, original university logo; inferred normalized thickness and depth. |
| Courtyard wheel | Double timber rings, radial spokes, paddles, axle, stationary piers/bearings, water basin and glazed background; unseen joinery simplified. Only the wheel group rotates about its local Z axle. |
| Selected buildings | Beige stone masses, horizontal window bands, glazed connector, roof louvers follow courtyard photographs. Depth, hidden elevations, window counts and campus-wide dimensions are simplified. |
| Campus grouping | Gate, courtyard and wings are deliberately regrouped for storytelling. Positions, paths, trees and planters are NOT a verified map or claimed real adjacency. |
| College symbol | One symbolic computing chip assigned to a selected roof for navigation; no claim that this is the real School of Computing building. College/program/track names come from Constants. |
| Flags | Existing Jordan seven-point-star and Germany textures/proportions retained. Pairing is identity staging; the primary gate photo has Jordanian flags. Cloth is a pinned analytical wave, not a cloth-physics simulation. |
| Opportunities marker | Plain directional arrow; no invented company, partner logo or university partnership. |

## Implementation files
- Default.aspx: full-width story, five HTML chapters, four projected HTML hotspots, retained video and server-rendered opportunity preview loops.
- Assets/css/home-story.css: Home-only viewport/sticky layout, safe text contrast, responsive overlays, native college disclosure and static flow.
- Assets/js/home-campus-model.js: campusRoot with entranceGroup, waterwheelGroup, buildingsGroup, landscapeGroup, opportunityMarkerGroup; shared materials and instanced repeated features.
- Assets/js/home-story-scene.js: coordinated scroll camera/visibility, resize, raycast/viewport/collision hotspot filtering, wheel/flag/water motion, pause, reduced motion, visibility suspension, context-loss fallback, disposal.
- Assets/js/home-story.js: guarded progressive initialization and dependency loading; restores all semantic chapters on failure.
- Assets/js/courtyard-model.js: optional textureSize parameter; campus uses 256px maps, old default behavior preserved.
- InternshipManagementSystem.csproj: publish entries for assembly module and actual aerial fallback photo.
- tests/home-campus.browser.js, tests/campus-capture.browser.js: browser verification and five-chapter evidence; public-requirements suite updated for college disclosure in a chapter.

## Accessibility and performance
HTML retains all content/links independent of canvas. Invisible chapters are inert; projected links hide if occluded, offscreen or colliding with readable copy/other labels. Equivalent normal links always remain in the document. Reduced motion kills camera scrub and restores static normal-flow chapters. The native details/summary works with Enter/Space. No wheel/touch interception or scroll library is added.

One render loop is capped at 30fps. DPR <=1.5 desktop, <=1.25 mobile; backbuffer <=1800x1200. Shadows disable on mobile. Repeated windows, foliage and existing wheel details are instanced; texture budget is reduced. Observed overview ~12.7k visible triangles, ~156 draw calls; frustum-dependent. Offscreen/hidden tabs suspend. Disposal releases geometries, materials, textures, observers, listeners, renderer and the sole ScrollTrigger. Repeated bootstrap execution is guarded.

## Missing assets and verification limits
No real internship video, captions or MP4/WebM/VTT was found. The existing explicit development placeholder is retained; there is no fake play button. On supply of internship-process.mp4 and captions, existing codebehind enables the native video control without scrolling its playback.

Verification uses actual ASP.NET pages in disposable IIS Express at localhost:57983 with the existing local Firebase stand-in on 4903. Production Firebase credentials, deployed database rules and live email authentication are not verified here. No private opportunity details are fetched into the public page. No commit, push or deployment is performed.

## Design review
The user-pinned full-scene architectural miniature overrides generated taste templates (split-card hero, stock photographs, testimonials/pricing and footage suggestions). None of that unsupported content is added. Approved system font/palette remain. Impeccable review found copy/model overlap on process chapter; a local pale contrast field and portrait reframe fixed it. Taste inspection identified borderline college-list contrast and small mobile text; these were corrected. Metadata, original header/footer tokens, native disclosure outlines, the honest missing-video placeholder and a three-line user-required headline are deliberate exceptions to generic marketing heuristics, not evidence that the detector fully passed. Refer to saved inspection report rather than claiming all heuristic checks passed.


## Final browser results
- Debug MSBuild: PASS. Node syntax checks for loader, scene, assembly and courtyard: PASS. git diff --check: PASS (existing Contact CRLF notices only).
- playwright-cli tests/home-campus.browser.js: 56 assertions PASS, including all five forward/reverse camera chapters, full-viewport canvas, landmarks, native anchors, keyboard college selection, sticky release, widths 320/390/768/1440/1920, hidden/offscreen suspension, reduced motion while offscreen, duplicate-init guard, resolution caps, module/WebGL/context-loss fallbacks and GPU disposal.
- playwright-cli tests/public-requirements.browser.js: 32 assertions PASS against the existing local Firebase stand-in. Published-preview filtering/encoding, no private sentinels in HTML, empty/error states, protected details/apply redirects and verified fixture roles are retained. Contact regressions also passed in the local disposable host.
- Healthy-page console errors: 0; failed requests: 0. Intentional failure cases were isolated in separate browser contexts.
- Screenshots: tests/artifacts/campus-desktop-chapter-1.png through -5.png, campus-mobile-chapter-1.png through -5.png, campus-tablet.png, campus-reduced-motion.png, campus-fallback.png. Overview sheet: campus-five-chapters.jpg. Reviewed against the original contact sheet; stone piers, dark wheel rings/spokes, basin and glazed bands preserved. Hidden dimensions/adjacency remain the explicit approximations above.
- Taste heuristic report is retained with its exceptions described above; it is not advertised as a full heuristic pass. Source-only Impeccable scan found no regex issues, but the tool notes parsed-page rules were not run; browser contrast/layout/interaction review supplied the primary evidence.


## 2026-10-22: larger framing and material refinement
Osama requested a larger and more realistic animation. The opening camera moves from [34,31,47] to [28,24,39], approximately 20% larger projected landmark framing, with separate portrait compensation. Gate and wheel close-ups are also nearer; camera positions remain above/outside the architecture. Public HTML, private authorization and Firebase paths are unchanged.

- New home-campus-materials.js loads local stone albedo/height/roughness maps from the previous img2threejs reference-pixel extraction. Published maps live in Assets/images/university/materials and derive from the primary courtyard photograph's stone crop. They are inferred maps, not measured scans. Box UVs use model-unit spacing to avoid stretching the stone across entire walls.
- Building windows gain instanced recesses, physical trim/sills, side-facing windows and course joints. The glazing uses a static, procedurally authored sky environment with clearcoat, not expensive realtime reflections or invented adjacent buildings.
- Existing wheel stays on its real axle. Timber is darker/matte; stationary bearing piers gain width and a small louver feature grounded in the primary reference. Water uses a lightweight animated normal map and static environment reflection. Pause/reduced motion stops all ambient updates.
- Uniform solid tree crowns are replaced by static instanced alpha-tested leaf cards, irregular branches and varied olive tones. These are attached foliage, not particle effects. Slightly varied positions remain an artistic landscape approximation. Shared procedural paving follows the tiled paths visible in courtyard references.
- Daylight uses a lower fill-to-sun ratio, 2048px desktop contact shadows (disabled on mobile). The PMREM target and generator are explicitly owned/disposed; verification caught and fixed a one-texture environment allocation retained by the earlier automatic conversion.
- Observed desktop overview: about 23,159 visible triangles and 186 draw calls; mobile wheel framing around 18,873 triangles and 119 calls. DPR/backbuffer caps remain unchanged. These counts depend on camera/frustum.
- Changed: Default.aspx and home-story.js entry versions; home-campus-model.js; home-story-scene.js; new home-campus-materials.js and three PNG texture assets; csproj publish entries. No shared layouts, private pages or C# integrations were edited for this refinement.
- Browser evidence: tests/artifacts/realism-desktop-0.png, realism-desktop-1.png, realism-desktop-3.png and corresponding mobile captures; baseline campus-realism-before.png. Main verification transcript: home-campus-realism-verification.txt. Local IIS/Firebase test limits above continue to apply.

Final refinement verification: Debug build and JavaScript syntax checks PASS; all 56 Home browser assertions PASS after explicit environment-target disposal. Healthy path had zero console errors and zero failed asset requests. Desktop, tablet and phone screenshots were inspected.
