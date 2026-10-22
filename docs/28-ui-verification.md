# UIMS UI verification

22 October 2026. All writes below used a disposable copy of the Web Forms app and local Postman Firebase/auth stand-ins. No live Firebase verification, email delivery or production file write is claimed.

## Results

| Check | Actual result |
| --- | --- |
| MSBuild Debug solution | Passed |
| `node --check Assets/js/ui-system.js` | Passed |
| `tests/ui-system.browser.js` | 29 checks passed; 98 visits covering all 52 route files |
| `tests/ui-system-workflows.browser.js` | 24 checks passed |
| `tests/ui-system-loading.browser.js` | 3 checks passed |
| `tests/ui-system-touch.browser.js` | 2 checks passed in a mobile context with touch enabled |
| `tests/ui-system-touch.browser.js` | 2 checks passed in a mobile context with touch enabled |
| Existing offer-confirmation regression, port-adjusted disposable copy | 24 checks passed |
| Route rendering | No runtime 500s; all 50 non-document route entries rendered or followed their intended redirect |
| Responsive | No document overflow in the 96 rendered-page visits at their recorded viewports |
| JavaScript | Zero uncaught page errors during the complete route run |
| Independent finish review | SHIP within reviewed implementation scope; five listed findings resolved |

The 58 checks across the four new scripts include: four-role dashboard sizing; actual approved/pending/over-target/missing-target hours; server-backed coordinator save and academic comment; native PDF multipart upload; student/company real write failure, preserved input and successful retry; exactly one POST after duplicate activation; ASP.NET linked validation; Bootstrap/custom modal focus containment, Escape, backdrop/scroll cleanup and focus return; native submit event preservation; empty and filtered results; idempotent refresh; wrong-role denial; tab keyboard behavior; real server pagination with retained filters and browser Back; and actual touch navigation.

The loading capture sends an actual delayed POST response into an invisible iframe **only in the screenshot harness**, so a cross-document navigation cannot blank the capture. It verifies Saving…, a native-enabled submit control, stable width, exactly one POST and confirmed stored data. Normal full-postback behavior is independently exercised by the main script. The blank experimental capture was discarded.

The complete inventory is in [26-ui-coverage.md](26-ui-coverage.md); machine-readable source and runtime evidence is in [ui-coverage.json](ui-coverage.json). Per-check JSON reports are in `tests/artifacts/ui-system-results.json`, `ui-system-workflows-results.json` and `ui-system-loading-results.json` and `ui-system-touch-results.json`.

## Before / after evidence

Each role has actual desktop and mobile screenshots. Before captures came from the pre-system disposable fixture app on port57996; after captures came from the current app on port58001. Before data is a smaller baseline fixture; after data includes a confirmed placement and assigned task to exercise the system. These are visual comparisons, not identical-data pixel diffs. Capture dimensions are 1440×1000 and 390×1000 with full-page output.

| Role | Before desktop | After desktop | Before mobile | After mobile |
| --- | --- | --- | --- | --- |
| Student | [Before](../tests/artifacts/ui-before-Student-1440.png) | [After](../tests/artifacts/ui-after-Student-1440.png) | [Before](../tests/artifacts/ui-before-Student-390.png) | [After](../tests/artifacts/ui-after-Student-390.png) |
| Company | [Before](../tests/artifacts/ui-before-Company-1440.png) | [After](../tests/artifacts/ui-after-Company-1440.png) | [Before](../tests/artifacts/ui-before-Company-390.png) | [After](../tests/artifacts/ui-after-Company-390.png) |
| Academic | [Before](../tests/artifacts/ui-before-Academic-1440.png) | [After](../tests/artifacts/ui-after-Academic-1440.png) | [Before](../tests/artifacts/ui-before-Academic-390.png) | [After](../tests/artifacts/ui-after-Academic-390.png) |
| Coordinator | [Before](../tests/artifacts/ui-before-Coordinator-1440.png) | [After](../tests/artifacts/ui-after-Coordinator-1440.png) | [Before](../tests/artifacts/ui-before-Coordinator-390.png) | [After](../tests/artifacts/ui-after-Coordinator-390.png) |

Additional evidence: [settled custom dialog](../tests/artifacts/ui-modal-mobile.png), [validation](../tests/artifacts/ui-validation-mobile.png), [real saving state](../tests/artifacts/ui-loading-mobile.png), [persistent write failure](../tests/artifacts/ui-write-failure-mobile.png), [Bootstrap tab dialog](../tests/artifacts/ui-bootstrap-tabs-mobile.png), [touch navigation](../tests/artifacts/ui-touch-mobile.png), [Bootstrap tab dialog](../tests/artifacts/ui-bootstrap-tabs-mobile.png), [touch navigation](../tests/artifacts/ui-touch-mobile.png), [short interaction recording](../tests/artifacts/ui-interactions.webm).

The independent reviewer checked all eight role captures and interaction states, then confirmed corrections to academic warning contrast, truthful zero-pending feedback, shared Active status, discoverable mobile columns and the settled modal capture. The final narrow verdict confirmed that empty tables no longer request unnecessary scrolling. A later functional recheck confirmed accessible Bootstrap tabs and the settled modal above its backdrop. The page entrance does not retain a transform after completion; existing tab handlers are respected to avoid double arrow-key movement. A later functional recheck confirmed accessible Bootstrap tabs and the settled modal above its backdrop. The page entrance does not retain a transform after completion; existing tab handlers are respected to avoid double arrow-key movement. No new raster asset shipped with the feature.

## Limits and reproducibility

- Start Postman: `postman simulation run postman/simulations/campus-login.sim.yaml --port 4920 --no-history`.
- Start the disposable app: `tests/Start-LoginTestHost.ps1 -Port 58001 -SimulationPort 4920`. Auth URL rewriting occurs only in that copy.
- Run each browser script with `playwright-cli -s=ui-system run-code --filename tests/<script>.browser.js` after opening that isolated browser session. Tests mutate local fixtures; do not point them at a live service.
- The route suite renders 46 routes at both desktop/mobile sizes, four shared account/meeting routes at mobile size, and two document endpoints as authorization negative checks. The completion report correctly returned404 with no approved report; a student was denied the company document route. Actual file downloads/report generation are not certified by these negative checks.
- Native PDF upload was exercised in the disposable app. External photo storage, real emails, every row-command permutation and every account-role combination were not exhaustively exercised.
- No current UpdatePanel exists; only full postbacks and repeated initialization are runtime verified. Microsoft AJAX lifecycle support remains structural.
- Existing older application/review scripts initially failed obsolete assertions: duplicate application now opens its existing view, the rejection form changed from details to an inline toggle, and collapsed sidebar labels are hidden. Those exploratory failures are not reported as passing regressions. Current workflow scripts explicitly verify the real current behavior instead.
- Expected document-negative404 and an existing favicon404 are HTTP resource responses, not uncaught JavaScript exceptions. This report does not claim zero console resource messages.
- Local screenshots, recordings and fixture reports live in ignored `tests/artifacts/`; keep that folder with the working copy when sharing the evidence. No commit or push was performed.
