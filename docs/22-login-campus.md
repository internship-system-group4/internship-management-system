# Gate 1 login experience

Implemented 22 October 2026. This is a Login-only extension of the existing UIMS visual system. It does not establish a new product identity or change shared navigation, dashboard styling, or design tokens.

## Scope and visual contract

The requested surface is a full-viewport daylight Gate 1 environment with a fictional adult security guard and visitor. The scene fills the viewport behind the page; the readable HTML form overlays it on the left on desktop, and the camera frames the gate, guard and visitor in the remaining space. On phones and portrait tablets the scene stays full-width behind a top band that frames the whole gate, and the form (capped at 480px) follows it. The original GJU logo, inherited Segoe UI/system typography, university navy (`#264f73` actions, `#133d61` ink), white form surface and compact six-pixel form corners continue the established system.

The form retains Web Forms server controls, associated labels and inline validation, password visibility state, recovery navigation and keyboard access. The scene is decorative and hidden from assistive technology. A real campus photograph remains underneath the canvas. A visible pause button controls ambient motion; reduced motion uses a static scene and skips the success animation.

The architectural treatment reuses the existing procedural Gate 1 model and its photograph-derived stone materials. Login changes only its own model instance: two Jordan flags, fictional people, a verification device and symbolic sliding leaves. The photographed portal remains stationary. The sliding mechanism is illustrative and does not assert how the actual gate operates. The scene is an approximation, not a surveyed campus or certified photographic reconstruction.

## Revision (22 October 2026, second pass)

- Overlay: the large caption card that covered the guard became a compact place label with the pause control. A server-rendered welcome chip ("Welcome. Your entry is verified.") stays visible during the entrance while the form fades.
- Scene (`login-campus-scene.js`, Login instance only): painted daylight sky; procedural limestone in roughly 0.6 m courses, toned from the Gate 1 photograph (the courtyard tile read as orange wood grain); soffit downlights; long approach road with the photo's black-and-white painted curb, street lamps, low terracotta wall and a distant hall. The guard has a cap, epaulettes and a radio. The visitor has a lanyard pass. There is a verification kiosk whose light is neutral at idle, amber while authentication is pending, and green after verified success.
- Motion: poses ease toward restrained targets instead of snapping. The exit camera runs between the two flagpoles. The leaves open in the first 70% of the 1.25 s entry, and the camera starts after 15%. Phones skip the shadow maps and the courtyard texture downloads.
- The img2threejs local state for the gate (`.img2threejs/gate-state.json`) is still at the blockout pass. The changes above were checked side by side against the reference photograph, not run through the gated pass pipeline.

## Changed files

Paths below are relative to the repository; the web project root is `InternshipManagementSystem/InternshipManagementSystem/`.

- `Pages/Account/Login.aspx`: semantic HTML form, background photograph/canvas mount, status output, pause and verified continuation link; loads Login-only assets alongside the existing form validator.
- `Pages/Account/Login.aspx.cs`: rechecks existing sessions, validates the authenticated profile and approved destination, and enables a brief presentation response only after successful server verification.
- `Assets/css/login-campus.css`: scoped viewport composition, compact white form, responsive stacking and reduced-motion treatment.
- `Assets/js/login-campus.js`: progressive loading, pending/success presentation, bounded redirect fallback and page lifecycle cleanup/reinitialization.
- `Assets/js/login-campus-scene.js`: daylight scene, fictional adults, symbolic sliding leaves, success camera passage, pause/reduced motion, resize/context-loss handling and resource disposal.
- `InternshipManagementSystem.csproj`: includes the three new Login assets for deployment.
- `tests/Start-LoginTestHost.ps1`, `tests/login-campus.browser.js`, `tests/login-campus-lifecycle.browser.js`: isolated HTTP test host and browser checks.
- `postman/mocks/campus-auth/` and `postman/simulations/campus-login.sim.yaml`: local Firebase Auth fixture alongside the existing RTDB fixture.
- `.img2threejs/`: inherited gate reconstruction evidence; its validation status is bounded below.

`Public.master`, shared public-navbar sources, dashboard sources and production `Services/AuthService.cs` remain unchanged by this feature.

## Authentication and presentation contract

Authentication remains Firebase email/password sign-in followed by a server-loaded user profile, active-account check and session creation. The server determines the role and dashboard; URL role/return parameters and posted presentation fields confer no authority. Unknown roles or destinations outside the four dashboards and ChangePassword route are rejected. Existing sessions are reverified before reuse; failures sign out the stale session. The response is non-cacheable, and the verified destination exists only for the successful POST response rather than ViewState.

Before verification, the visitor presents a pass while the leaves stay closed. A successful animated response contains only the server-approved destination. The nominal 1.25-second camera move opens the symbolic leaves and crosses the gate before replacing the location. A 1.7-second JavaScript timer and three-second server `Refresh` header bound the delay; an explicit continuation link remains available. Import/scene/animation failures still lead to the verified destination. No-JavaScript and reduced-motion submissions take the immediate server redirect. The password is cleared on the animated response, and authentication tokens are not emitted into its HTML.

Page hiding disposes renderer resources and exposes the photo. A persisted page-show event rebuilds a single scene. Actual WebGL context loss exposes the photo and hides the pause control. Animation completion affects presentation only; protected routes retain server authorization.

## Verification evidence

The implementation run reported a passing build with four preexisting C# warnings. The documentation pass read the final sources and test definitions; it did not rerun browsers or perform additional visual polishing.

`tests/login-campus.browser.js` passed 40 assertions, covering four real role redirects through the local HTTP fixtures, rejected unknown roles, server-selected destinations, token/password absence from returned HTML, duplicate submission handling, password visibility and validation, recovery-link navigation, immediate no-JavaScript/reduced-motion redirects, scene/animation failures, viewport overflow, keyboard order and absence of browser JavaScript errors. Viewports checked were 1440, 768 and 390 pixels wide. Recovery delivery was not submitted.

`tests/login-campus-lifecycle.browser.js` passed eight assertions against observed rendered geometry and lifecycle behavior. The pending leaves stayed at `[-2.5, 2.5]`; success moved them to approximately `[-7.6, 7.6]`. The portal stayed at x=0. Camera z finished at -2, crossing the gate plane at z=0.5, with a measured duration of 1254.3ms. The test also checked disposal, exactly one reconstructed canvas after simulated persisted lifecycle events, the restored pause control and fallback after actual induced WebGL context loss. Simulated persisted events do not certify every browser's real back/forward cache behavior.

The startup script creates a disposable copy through the existing application test host. Only that copy's hard-coded AuthService endpoint is rewritten to the local Postman Auth fixture, and only that copy is rebuilt. Production AuthService is untouched; the RTDB fixture is reused. The Auth fixture contract was authored from the local AuthService request/response parser. Postman was unauthenticated, so organization/owner mock discovery was skipped. These results demonstrate the local fixture integration, not production Firebase integration certification.

To reproduce from the repository root, start the simulation, start the disposable host, then run each browser function file with the project's `playwright-cli run-code` workflow. Start the lifecycle script in a new page because it registers an exposed browser function:

```powershell
postman simulation run postman/simulations/campus-login.sim.yaml --port 4910 --no-history --output ndjson
powershell -File tests/Start-LoginTestHost.ps1 -Port 57992 -SimulationPort 4910
playwright-cli -s=login open
playwright-cli -s=login run-code --filename=tests/login-campus.browser.js
playwright-cli -s=login tab-new
playwright-cli -s=login run-code --filename=tests/login-campus-lifecycle.browser.js
```

## Limits and existing documentation drift

Live Firebase sign-in and recovery email delivery were not tested; no real recovery emails were sent. Actual mobile operating-system keyboard behavior was not exercised, although narrow viewport layout and keyboard navigation were checked. The existing inherited img2threejs gate specification passes its strict schema; no specification repairs were performed during this change. The mandatory reconstruction render/review pipeline remains unfinished. Existing rendered artifacts do not establish completion of that pipeline or certify photo fidelity.

`PRODUCT.md` and `DESIGN.md` were read and preserved. No `.impeccable/design.json` was found under the Project3 workspace, and none was synthesized. Existing DESIGN prose mixes superseded Home compositions and type scales with the current editorial direction. It also retains an older 960px public-navigation breakpoint after the newer 1120px navbar description, and an earlier Home-only 3D restriction. The current Login brief authorizes this local extension; it does not generalize scene use to other pages. These preexisting inconsistencies were recorded without refreshing the global design system.
