# Jisr: the 3D homepage (review build)

Page: `Pages/Public/Journey.aspx` (+ `.aspx.cs`). `Default.aspx` is unchanged. Code: `Assets/js/jisr/*.js`
(three.js r180 + GSAP ScrollTrigger, both already vendored), styles in `Assets/css/jisr.css`.

## The story

1. **Aerial opening (scroll 0 – 0.63, unchanged):** sunrise over the campus, the storks circling, the
   pergola flight. Copy: university identity, "A bridge, not a border", "One system for the whole journey"
   (the UIMS introduction with the three roles). The opening keeps its original scroll length.
2. **The student (0.63 – 0.86):** the camera blends from the aerial path down behind the shoulder of a
   rigged, motion-captured student (Rocketbox `Male_Adult_17`, MIT) walking through the courtyard. Head,
   neck and upper spine turn toward three reveals while the camera follows the gaze; English captions sit
   beside the architecture:
   - School of Computing (looks right, the east tower)
   - School of Architecture and Built Environment (looks left and up, a pergola crown)
   - School of Sustainable Systems Engineering (looks left, the solar field)
   Schools are introduced thematically. The 3D campus is an artistic interpretation, so no building is
   presented as a school's real location (the page says so under the directory).
3. **The climax (0.86 – 1):** he stops in an open plaza and looks up north-west. About 170 white storks in
   ten groups appear in the distance, gather and pass overhead toward the south-east (their real autumn
   route), some close to the camera. "Your Journey Begins Here."
4. **Below the scene:** open internships (Firebase), the academic directory (all eight GJU schools), how it
   works, the process video, and a login call to action.

## Opportunities from Firebase (no login to browse)

- `Journey.aspx.cs` reads `OpportunityRepository.GetPublicPreviews(6)`: the allowlisted public projection
  `publicOpportunityPreviews` (title, company, location, specialization, summary, seats, deadline).
- **Apply now** links to `~/Pages/Student/Apply.aspx?opportunityId=<id>`. Anonymous visitors are sent to Login
  by the existing student page guard with `returnUrl`; after sign-in, `Login.aspx.cs` returns an active
  student to that Apply page (only that page, only a valid key; everyone else goes to their dashboard).
- Publication: companies' create/edit/close actions now call `OpportunityRepository.SyncPublicPreview(id)`
  (best effort, never blocks the save). It writes the summary (from the description) and the
  specialization (eligible majors), or removes the preview when the opportunity closes.

**Needed before visitors see real cards:** publish `docs/public-opportunity-rules.fragment.json` (it now also
allows `Specialization`) in the Firebase console. Today anonymous reads of `publicOpportunityPreviews` are
denied, so the page shows a friendly notice instead of cards. Existing open opportunities get a preview the
next time their company edits them.

## Assets

| Asset | Source | Notes |
| --- | --- | --- |
| Student `Assets/models/people/Male_Adult_17_Animated.glb` | Microsoft Rocketbox, MIT | Walk, walk-stop and look-around mocap; built with `tools/rocketbox/convert-animated.html` |
| Storks, crowd, campus, land, sky | Procedural (this repo) | Hero storks: detailed model with shoulder/wrist wing flex in the vertex shader |
| Gate 1, waterwheel, stone photo, GJU logo | Already in the repo | Reused |
| School names and programmes | gju.edu.jo (checked 23 Oct 2026) | UIMS supports the School of Computing only (`Constants.CollegeName`) |

## Performance and fallbacks

- Quality tier from the GPU name (integrated/mobile: 1x resolution, 2048 shadows, lighter post). Force with
  `?q=low` or `?q=high`. Measured on Intel UHD at 1440x900, low tier: opening ~42 ms, walk ~38 ms,
  flock ~21 ms per frame. A discrete GPU should hold 60 fps.
- The student follows scroll at walking pace (legs are phase-locked to distance, so no foot sliding); a
  big jump (chapter links) cuts ahead like a film edit. Background walkers dissolve near the camera
  during the student sequence so only the detailed character is seen up close.
- No WebGL2 or a script error: a static photo version with the same copy. Reduced motion: ambient motion
  paused, no camera easing.

## Testing helpers (development only)

- `Journey.aspx?p=0.7` pins the story at a scroll position.
- Console: `__jisr.setProgress(0.7)`, `__jisr.advance(5)` (simulate seconds without rendering),
  `__jisr.info()`, `__jisr.capture('still.jpg')` (POSTs a frame to a local capture server on 127.0.0.1:8097).
