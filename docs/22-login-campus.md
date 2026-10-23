# Login: campus security in 3D

Updated 23 October 2026. This Login-only composition puts the HTML form beside a Three.js security checkpoint: Gate 1, a fictional security officer, a university ID on a reader support, and a recessed status display. It uses the existing UIMS colors, fonts, public navbar and language/theme controllers. On phones the form appears first, with the sign-in action in the initial viewport.

The form keeps Web Forms controls and server authentication. Email/password validation, password visibility, recovery navigation, keyboard order and dirty-input protection remain with the existing controllers. The visual controller posts `campusAnimation=0`; successful authentication immediately redirects to the server-approved route. The scene cannot grant access, choose a role, or delay navigation. Pending authentication changes the reader to amber and the officer's gaze; the gate stays closed. A generic sample pass is decorative and contains no user information.

## Geometry, materials and motion

`Assets/js/login-campus-scene.js` reuses the shared Gate 1 factory without changing Home. Login adjusts only its own instance: two Jordanian flags, beveled limestone portal edges, noise/grain surfaces, approach road, painted curbs, distant hall and lamps. Alpha-cutout foliage replaces solid sphere trees. Environment lighting, warm directional sunlight, contact shadows, rough metal and laminated-card materials provide depth cues.

The officer reuses the project's `Male_Adult_17_Animated.glb`, an MIT Microsoft Rocketbox adult. The captured neutral pose and existing skeleton are retained. Navy fabric shading preserves skin pixels; cap, badge and radio attach to the animated bones with their world scale preserved. Restrained breathing and damped head movement replace the earlier capsule figures. This is a generic adult, not a likeness or an assertion about the real campus uniform.

The camera frames the full gate behind the foreground checkpoint and moves by at most 0.11m horizontally and 0.04m vertically with the pointer. Motion is time based. Ambient rendering is capped near 30Hz; repeated foliage and curbs are instanced. The desktop evidence reports 15,762 triangles and 158 draw calls, down from 431 before batching. These are scene counts, not a measured physical-device frame-rate guarantee. Pixel ratio is capped at 1.5 desktop / 1.25 phone, with smaller phone shadow maps.

Pause and reduced motion stop the ambient render loop. A hidden document cancels frames. Page teardown disposes geometry, materials, textures, skeleton mixer, environment and renderer; persisted restoration initializes a single renderer and event-handler set. Model/import failure or actual WebGL context loss exposes the existing local campus photograph. The form works without WebGL and without JavaScript. An import map on Login resolves the existing GLTF loader's `three` dependency to the bundled local module. No new framework, npm package or downloaded model is required.

## Verification

The local project built successfully. Browser checks passed against a disposable IIS copy and the existing Postman Auth/Firebase simulation on port 4912:

- 74 functional/layout checks: all four verified role redirects, invalid credentials, unknown-role rejection, safe application resumption, validation, password visibility, keyboard order, recovery navigation, duplicate-submit prevention, English/Arabic and Light/Dark at 1440, 1024, 768, 390 and 320px, reduced motion, touch, disabled JavaScript and model failure.
- 12 lifecycle checks: pending gate closure, return to idle, disposal, repeated persisted restoration, pause handlers, motion-preference changes, resize, dirty-input cancellation and actual induced WebGL context loss.
- Eight final visual cases: both languages and themes at 1440 and 390px. Final screenshots wait for the scene crossfade to finish. The short recording adds 1.8 seconds of local POST latency solely to make the pending state visible; production adds no such delay.

Artifacts are under ignored `tests/artifacts/login-security-*`. Reproduce from the repository root:

```powershell
postman simulation run postman/simulations/campus-login.sim.yaml --port 4912 --no-history --output ndjson
./tests/Start-LoginTestHost.ps1 -Port 58136 -SimulationPort 4912
playwright-cli open http://localhost:58136/Pages/Account/Login.aspx
playwright-cli run-code --filename=tests/login-campus.browser.js
playwright-cli run-code --filename=tests/login-campus-lifecycle.browser.js
```

Only the disposable host's authentication endpoints point at the simulation. Production AuthService, credentials and server authorization code are unchanged. The results establish the local fixture integration; live Firebase and recovery-email delivery were not exercised. Mobile geometry and touch are emulated, not physical-device keyboard/GPU certification.

## Fidelity limits

The scene is an approximate real-time 3D interpretation, not a photogrammetric or fully photoreal reconstruction. Hidden architecture, scanner hardware, ID dimensions and security clothing are inferred. The existing avatar retains its underlying garment silhouette. The inherited `.img2threejs/gate-state.json` remains at blockout; this integration does not claim completion of the reconstruction skill's mandatory render/review gates or a photographic fidelity score. Existing reconstruction artifacts are not certification of this scene.
