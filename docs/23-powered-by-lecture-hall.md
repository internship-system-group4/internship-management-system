# Powered by: the team lecture hall

`Pages/Public/PoweredBy.aspx` credits the development team. The page is a full-viewport
3D lecture hall. Visitors find the seven members through their marked seats or a
"Find a team member" control, and open each profile in a side panel (a bottom sheet on phones).

## Files

- `App_Data/development-team.json`: the roster (not web-served). Each member has a stable
  `Key` and a `Seat` (`<block L|C|R><row 1-7>-<seat from the left>`, for example `C4-5`).
  An invalid or taken seat is reassigned automatically.
- `Pages/Public/PoweredBy.aspx(.cs)`: renders the full roster as real HTML. That list feeds
  the profile panel and is the visible fallback.
- `Assets/js/powered-by.js`: page controller (modes, finder, profile, focus, hover label, lifecycle).
- `Assets/js/powered-by-hall.js`: the scene. Loaded only on this page, after the HTML is usable.
- `Assets/css/powered-by.css`: overlays, profile panel and sheet, fallback list.
- `tools/New-TeamPhotoThumbnails.ps1`: 240 px photo copies used by the page.
- `tests/team-hall-experience.browser.js`: behaviour checks (run against `tests/Start-LoginTestHost.ps1`).

## Modes

`data-mode` on `.team-experience` is `fallback` in the HTML. An inline script switches it to `loading`.
The page becomes `ready` once the first frame renders. WebGL failure, a module load failure, context
loss, or a 15-second stall all return it to `fallback` with a short notice. Without JavaScript the
plain list shows with no error.

## Assets and licences

- **People:** ten seated figures from the Microsoft Rocketbox avatar library (MIT, Copyright (c) 2020 Microsoft).
  They live in `Assets/models/people/`, which also holds `LICENSE.md` and a README listing the avatars and changes.
  Each is frozen on a frame of Rocketbox's own seated-at-table motion, with 512 px textures, about 260-780 KB each
  and 5.2 MB for all ten. Phones load a five-figure cast (2.1 MB). The scene loads them with three@0.180.0
  `GLTFLoader` and `BufferGeometryUtils` (MIT, unchanged, `Assets/js/vendor/addons/`). PoweredBy.aspx carries an
  import map for their bare `three` import, and Web.config serves `.glb` as `model/gltf-binary`.
- **Conversion:** `tools/rocketbox/` is a development-only converter. It uses unchanged three@0.180.0 FBXLoader,
  TGALoader, fflate, NURBS and GLTFExporter modules. The raw Rocketbox downloads are not in the repository.
- **Everything else** (room, furniture, materials) is generated in code. The only other images are the official GJU
  logo and the team's own photos.
- The room interprets GJU's exterior material language. It is not a reconstruction of a real GJU lecture hall:
  no interior references were available.

## Limits

The figures are static: one frozen seated frame per avatar, with no idle motion. They show mid-2010s
game-character fidelity, convincing at hall distance but not photoreal in close-up. Team members use generic figures
chosen by the roster's `Character` field (male or female), in everyday university clothing; no attire is inferred from
names, and the figures are not likenesses. Identity lives in the profile photo.

## Team highlighting

Team members are drawn as their own meshes:
- a restrained cool rim and a soft accent-light lift in the shader (faces get only a fraction of the rim);
- light pools on the desk and behind the seat, and the backlit seat-back strip;
- HTML name markers above them, laid out without overlap, with a leader line when nudged, hidden while the camera
  moves and when something opaque blocks the view of the member's head.

Background students use slightly desaturated, dimmer materials. Hover, keyboard focus in the finder, and selection
strengthen the cues. All of it is depth-tested and works without shadows, so it holds on phones.
If the models fail to load, the hall falls back to simple procedural figures.
