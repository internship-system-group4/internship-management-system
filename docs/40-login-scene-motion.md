# Login scene: realism and motion contract

This refinement keeps the existing Gate 1 reconstruction and server authentication. It does not reconstruct a new likeness or claim a surveyed digital twin of the campus.

## Runtime quality targets

- Replace primitive human figures with the existing licensed Rocketbox skinned avatar, retaining its color/normal maps and skeleton.
- Give the fictional guard a distinct navy uniform treatment and security accessories; preserve skin tones. Neither character represents a real person.
- Use motion-capture idle/walk poses, distance-driven gait, restrained gaze and two-bone arm posing for the ID-reader interaction.
- Keep feet on the ground, the card attached to the hand, the architecture stationary, and the gate mechanism independent of the characters.
- Use softer daylight, directional/contact shadows and material reflections with the existing stone surface maps.
- Use a restrained dolly at human eye height instead of a rapid FOV zoom through the gate.
- Preserve immediate form availability, failed-login behavior, server-only success, the existing navigation safety cap, pause/reduced-motion behavior, mobile framing and resource cleanup.

The `img2threejs` gate references remain evidence for the existing architecture. Its unfinished waterwheel/gate reconstruction states are not advanced by this runtime-only refinement. No new reference-matched procedural character model is claimed.

## Scene detail (entrance refinement)

Everything is placed at real-world scale in metres and rests on the ground, a kerb or a planter; nothing crosses the
8.8 m road, the sliding-leaf track (z = 0.5) or the characters' paths.

- **Flags.** Each flag flies from a freestanding 7 m satin-aluminium pole (stone collar, truck, gilt finial, halyard and
  cleat) in a landscaped planter in front of its pier: Jordan on the approaching visitor's right, Germany on the left,
  mirrored at |x| = 5.9 m, 1.2 m clear of the road edge and 1.9 m in front of the gate track. The flags fly above the
  lintel line so neither covers the sign or logo. The Home gate model's two cloth simulations are reused (gentle,
  phase-offset wind; the hoist edge stays pinned at the pole); its original poles inside the opening are hidden on Login
  only. Colours, 1:2 / 3:5 proportions and the seven-pointed star come unchanged from the shared flag texture.
- **Gate and ground.** Darker plinth course at each pier foot, projecting coping on the lintel, fine joints on the pier
  faces; 0.6 x 0.3 m running-bond setts on the forecourt; aggregate grain on the asphalt; stone kerbs and grass verges on
  the approach; a matching sidewalk and painted kerb on the left beyond the gate; restrained road paint (centre dashes,
  stop line, checkpoint box around the reader).
- **Security equipment.** One bullet CCTV camera on the right pier facing the approach; the card reader gains a bolted
  base plate, a rain hood and a contact shadow.
- **Characters.** Guard: shoulder boards with brass buttons and a duty belt with buckle, in addition to the cap, badge,
  radio and bilingual patch. Student: a soft daypack worn on both shoulders. Both breathe slowly, shift their weight
  through the spine (pelvis and feet stay on the motion-capture clip, so shoes stay planted) and, while idle, glance away
  at different intervals (guard down the approach road, student up at the sign).
- **Camera and page.** The desktop camera sits 2.5 m further back so both flags fit beside the form; the Arabic layout
  mirrors the aim. After a failed sign-in the error is focused without the browser's jump-scroll; on success the page
  returns to the top so the entry is visible.

Captures: `tests/login-scene-capture.browser.js` writes before/after screenshots (desktop and phone, English/Arabic,
Light/Dark, character close-ups) and `entry.webm` recordings under `tests/artifacts/login-scene/` (ignored by git).

### Remaining limitations

- Both characters still share one licensed Rocketbox avatar mesh; clothing differences come from material treatment and
  attached accessories, not new garments. Hands are the avatar's own and are small at the Login camera distance.
- The accessories (belt, shoulder boards, daypack) are rigid and follow the chest bone, so they do not deform with the
  body; small gaps or overlaps can appear at extreme poses of the walk cycle.
- The flag cloth is a procedural wave, not a physics simulation; it never wraps around the pole.
- The flag fabric and the pole shafts cast no shadows (at this sun angle they darkened the gate sign and logo); collars,
  kerbs, shrubs and people still do.
- On narrow desktop widths (701-1100 px) and on phones the flags are smaller in frame; on desktop the German pole sits
  close to the form's edge in English, as does the Jordanian pole in Arabic.
- Pavement joints, stone courses and road grain are texture detail, not geometry.

## Performance

Measured with `tests/login-perf.browser.js` against the disposable IIS Express host, headless Chromium on the development
machine (SwiftShader/ANGLE GPU path), before and after this pass. *Phone* = 390 x 844 mobile viewport, 4x CPU throttling,
1.6 Mbit/s down / 150 ms latency. Cold = empty cache; warm = immediate reload. Numbers are relative between runs on the
same machine, not field data; headless frame pacing is capped near the display rate.

| Measure | Before | After |
| --- | --- | --- |
| Character model download | 3,166 KB | 1,431 KB |
| Campus photograph | 859 KB PNG | 83 KB WebP (PNG fallback) |
| Desktop cold: total transfer | 8,621 KB | 5,919 KB |
| Desktop cold: form ready (DOMContentLoaded) | 5,517 ms | 284 ms |
| Desktop cold: first complete 3D frame | 6,859 ms | 737 ms |
| Desktop cold: long tasks during load (total / max) | 1,485 / 981 ms | 231 / 175 ms |
| Desktop cold: input-to-frame delay while typing (max) | 35 ms | 6 ms |
| Desktop warm: first complete 3D frame | 478 ms | 411 ms |
| Phone cold: 3D scene | never (12 s model timeout -> photo fallback) | 20.7 s, form usable from 3.1 s |
| Phone warm: first complete 3D frame | never (fallback) | 1.65 s |
| Draw calls | 238 | 97 |

What changed:
- **Loading.** The scene's module graph is `modulepreload`ed and the model is preloaded at low priority, so downloads start
  with the page instead of after an import chain; the same request is reused by the scene (one download, checked by
  `tests/login-resilience.browser.js`). The photograph has explicit dimensions (no layout shift) and stays until the
  first complete frame: shaders are compiled with `compileAsync` before the canvas crossfades in (600 ms), so no blank or
  half-compiled frame is shown. The model timeout is 45 s; the form is usable over the photograph throughout.
- **Model.** See `Assets/models/people/README.md` (web build). Draco/Meshopt were not used: the remaining bytes are mostly
  textures and positions, and a decoder would add a download and main-thread work that the measured savings do not justify.
- **Runtime.** Static scenery (surroundings, entrance detail) is merged into one mesh per material and each sliding leaf
  into one mesh; the IK, gaze, breathing and ID-card code reuse preallocated vectors/quaternions (no per-frame
  allocation). Resolution adapts gradually to measured frame time (-0.1 after a slow second, +0.05 after five fast
  seconds, between 0.8/1.0 and the 1.25/1.5 device cap). Rendering stops when the tab is hidden, when paused, under
  reduced motion and after the entry; disposal also releases render lists and the WebGL context.
- **Server.** `.webp` is served as `image/webp`. `Assets/models`, `Assets/images/university` and `Assets/fonts` send
  `Cache-Control: max-age=30 days`; scripts and styles keep ETag revalidation because some module imports carry no
  version query. IIS already gzips scripts; `.glb` is not compressed by IIS Express (binary types are off by default).
  StudentDocuments handling is untouched.

Remaining limitations:
- On the throttled phone profile the first 3D frame still takes ~21 s cold: the 1.4 MB model at 1.6 Mbit/s is ~7 s and
  the self-hosted Noto Sans/Noto Sans Arabic TTF fonts (2.8 MB, loaded by the shared layout, not the scene) compete for
  bandwidth. Converting those fonts to subset WOFF2 would be the next largest saving and affects every page.
- Initialization on a 4x-throttled CPU has long tasks up to ~490 ms (shader compilation and model parsing); the
  form stays usable, but a keystroke landing in one of them waits for it (max 112 ms measured).
- The footer map (MapLibre, ~280 KB script plus tiles) loads on the Login page too; it is outside the scene.
- Frame timing here comes from software rendering; real GPUs will differ in both directions.

## Verification record

Verified locally on 2026-10-24 with Chrome against a disposable IIS Express host:

| Check | Result |
| --- | --- |
| Runtime browser checks | 40 passed in `tests/login-realism.browser.js` (adds walk-through and flag-placement checks) |
| Character state changes | Idle, checking, denied and success remain finite; gates stay closed before entry |
| Entry | 4.0-second sequence: gates open, the student turns and walks along their heading through the gate (reaches the gate line as the veil starts at 90%); fixed 40-degree desktop FOV, short dolly, veil and completion callback |
| Motion controls | Pause/resume, static reduced motion and immediate reduced-motion entry passed |
| Lifecycle | Context loss stops render restart; disposal removes the canvas and frees skeleton textures |
| Presentation | English/LTR and Arabic/RTL, Light/Dark, 1440px desktop and 390px phone; no horizontal overflow |
| Identity-card form | Official existing logo, bilingual heading, live email line and input-triggered ink/caret feedback; reduced motion updates without animation |
| Credential privacy | Card always shows a fixed eight-dot password mask, including when password visibility is toggled; no credential persistence added |
| Requested staging | Bilingual campus-security uniform patch, Jordan flag on the left and German flag on the right; independent cloth meshes |
| Model failure | Form remains usable; required-field validation passed with avatar request blocked |
| JavaScript/build | Syntax checks and Debug solution build passed; pre-existing CS0105 warning in `CompletionRecord.cs` |

Visual review covered the desktop scene, ID-reader pose and Arabic Dark phone view. A short
WebM and screenshots were generated under ignored `tests/artifacts/`. Browser checks exercise
presentation and client validation without credentials or POSTs; they do not establish a new
end-to-end authentication result. Server authentication code was not changed.

The scene uses the existing approximately 3.2 MB avatar once for both rigs and adaptive pixel
ratio/shadow resolution. The desktop idle view issued approximately 168 main render calls in
the local browser; this is not an FPS guarantee for every device. Native form and campus-photo
fallback remain available. Architecture, foliage and gate mechanics are still simplified;
this is an improved real-time scene, not photorealistic footage or an exact physical simulation.
