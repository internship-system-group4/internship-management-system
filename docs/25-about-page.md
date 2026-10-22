# About Us page

`Pages/Public/About.aspx` introduces German Jordanian University and the UIMS student project. Files:
- `Assets/css/about.css`: all styles, scoped to `.about-page`.
- `Assets/js/about.js`: the film controls, reveals and scroll motion.
- GSAP 3.13 and ScrollTrigger, already vendored for Home. No new dependencies.

## Sections

Opening (the university film) - The university - What makes GJU distinctive - The university's vision and mission -
Academic schools - About UIMS (opened by a navy "From the university to our project" band) - The journey through UIMS -
Take the next step.

## Opening film

- **Wide landscape screens** (`min-width:761px` and an aspect ratio of at least 5:4): the film fills the viewport under the
  navbar, cropped to fill (`object-fit: cover`). The text sits at the lower left on a contrast gradient. Pause and sound controls
  are at the top right.
- **Narrow and portrait screens:** the film keeps its own 2.38:1 frame, uncropped, with the text on a navy panel below.
- **Preview:** a muted, looping, inline preview starts only on wide screens, when motion is welcome and the browser hasn't asked
  to save data. If the browser refuses autoplay, the poster stays. Phones and reduced motion never autoplay.
- **Pausing:** a visitor's pause is never overridden. The script pauses the preview itself when it leaves the screen, the tab is
  hidden, the page is left, or the full film is open, and it resumes only those script-initiated pauses.
- **Full film:** "Play university film" opens a `<dialog>` with the full film: uncropped, native controls, with sound because the
  visitor asked for it. Escape or Close stops it and returns focus. Without JavaScript the same button is a link to the MP4 file.
- **Loading and errors:** a loading status appears while the film buffers. If the file fails, the page says so and disables the
  preview controls.

## Opening scroll transition (wide screens, motion welcome)

- The opening gets a 75vh sticky runway (`.is-sequenced`). The stage stays stuck under the 96px navbar.
- One scrubbed ScrollTrigger timeline runs the transition:
  - for the first 30% the film holds still;
  - the text and the scroll cue then lift and fade;
  - the contrast gradient fades with the text;
  - the frame eases to 0.9 scale with a 16px radius.
- The stage then releases into normal flow with no gap, and scrolling up reverses everything.
- Playback and scroll are independent: there is no scrubbing or seeking of the video.
- Arriving through an anchor (for example `#about-uims`) lands below the navbar after the runway is applied.
- Narrow screens and reduced motion use normal flow with no pinning.

## Section motion

- **Reveals:** `[data-reveal]` elements rise 20px over 600ms, once per visit, with an 80ms stagger inside
  `[data-reveal-group]`. The schools list reveals in groups of three.
- **Variations:**
  - campus pictures use a clip reveal;
  - vision and mission use a slower fade;
  - the objectives' rules draw in;
  - the UIMS chapter band wipes in.
- **Parallax and the journey line (961px and wider):**
  - the gate picture moves ±3% inside a frame it overfills by 8%;
  - the journey's line scrubs from step 1 to step 5, and each step appears as the line reaches it.
- **Pre-hiding and fallbacks:**
  - content is pre-hidden only under `html.about-motion`, set by an inline script;
  - that class is dropped if `about.js` hasn't started within 3 seconds;
  - with reduced motion or no JavaScript, everything is static and visible.

## Verified facts (gju.edu.jo, checked 22 October 2026)

- About the University: founded in 2005 by Royal Decree following a memorandum of understanding between the Jordanian and German
  ministries; modelled on the German applied-sciences concept; the German Year combines a study semester at a German partner
  university with an internship semester in Germany; strong links with German and Jordanian industry.
- University Identity: vision "Inspiring innovation through applied education" (verbatim); mission paraphrased in English.
  Values shown are four of the six published ones. "Social Responsibility" from the brief is not a published GJU value and is
  omitted.
- Programs page: the eight school names exactly as listed. The page gives no school-to-program mapping, so the About page links
  to it instead of listing majors. UIMS itself is configured only for `Constants.CollegeName` (School of Computing).

No student counts, rankings, leaders' names or partner counts are published on the page.

## Campus film

- File: `Assets/images/university/materials/-578791943103387727.mp4`, the only video in the project. It is served in place, not
  copied.
- Format: H.264 High@3.1 with AAC audio, 1280 x 538 (about 2.38:1), 1 min 48 s. The `moov` index comes before the media data,
  so `preload="metadata"` reads only the start of the file.
- Content (sampled frames): GJU campus (courtyard waterwheel, main building with the Jordanian, German and GJU flags, lecture
  hall, library) and German Year scenes in Germany. It is a university introduction, not the internship-process video that Home
  expects at `~/Assets/video/internship-process.mp4`. That file is still absent and Home's own fallback is unchanged.
- Presentation: a 16:9 stage with `object-fit: contain`, so the full wide frame shows with letterbox bands and nothing is cropped.
- Poster: `Assets/images/about/about-film-poster.jpg`, a real frame at 1:10 rendered in the browser.
- Captions: none exist, and the page says so. If playback fails, a direct link to the file is offered.
- Limitation: the disposable IIS Express test host answers HTTP range requests with 200 (the whole file) for all static files.
  Chrome still plays and seeks correctly. Range support on the production IIS server has not been verified.

## Images

Optimised JPEG copies in `Assets/images/about/`, made from the existing university photos (the originals are unchanged):
- `about-gate-1.jpg` from `b1138b1f...png`
- `about-campus-aerial.jpg` from `b270da86...png`
- `about-students.jpg` from `home-students.jpg`

## Test

`tests/about-page.browser.js` (66 checks), run against `tests/Start-LoginTestHost.ps1` on port 57992.
