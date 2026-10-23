# Workspace redesign verification and visual evidence

23 October 2026. All writes used a disposable ASP.NET Web Forms application and local Postman Firebase/auth dependencies. No live Firebase, production deployment, real email delivery or live user-data verification is claimed. No commit or push was performed.

## Completed checks

| Check | Actual result |
| --- | --- |
| MSBuild Debug solution | Passed after implementation and final success-marker changes |
| JavaScript syntax: ui-system.js / workspace.js | Passed |
| Git whitespace check and design sidecar JSON | Passed |
| `redesign-workspace.browser.js` | 226 checks passed |
| `redesign-routes.browser.js` | 3 inventory checks;98 visits covering52 route files |
| Existing UI workflow suite, host/port adjusted | 24 checks passed |
| Existing single-offer suite, host/port adjusted | 24 checks passed, including competing sessions |
| `redesign-actions.browser.js` | 20 checks passed across all four roles |
| `redesign-contracts.browser.js` | 15 checks passed |
| `redesign-motion.browser.js` | Recorded real coordinator save confirmed in stored data |
| Independent visual review | Final SHIP after targeted fixes and settled public captures |

The workspace suite exercises every journey stage at1440/390px for all four roles, keyboard containment/Escape/focus return, real stage facts/actions, approved/pending/over-target/missing-target hours, assignment isolation, a tampered academic evaluation hidden ID, coordinator-only access, actual HTTP read failures and empty states. The student journey remains incomplete until an approved coordinator record exists. Confidential company/other-cohort academic text does not appear in the student dashboard.

The contract suite verifies actual45→65% progress frames, idempotent refresh, reduced-motion cancellation and removal of a stale missing-target note. It verifies that an accepted offer advances to one current placement-confirmation stage, and college and major eligibility in both opportunity listing and direct application URLs. It also verifies an incomplete completion gate, a real coordinator approval postback, the stored reviewer identity, the resulting student journey and highlighting of a row only after its real status changed.

The action suite verifies Saving…, stable width, native-enabled submit semantics, duplicate suppression, exactly one pending POST, stored changes, normal full postbacks and server confirmation for Student, Company, Academic and Coordinator. Only screenshot captures direct the POST response into a hidden iframe and introduce local test-network latency; those harness features do not ship in product code. Normal full postbacks are tested separately. The recording uses a normal full postback with controlled local latency so the real pending state is visible.

The existing workflow regression verifies persistent write failures, preserved input/retry, native PDF multipart upload, Bootstrap dialog/tab keyboard behavior and server pagination/filter/Back behavior. The offer regression includes single placement creation under competing authenticated sessions. Route evidence reports no server500s, no document overflow in96 rendered visits, and no uncaught JavaScript exceptions. The other two visits are document-authorization negative checks, not successful document generation/download certification.

## Before and after

Before: isolated pre-redesign copy on58010. After: final disposable copy on58013. Dashboard/work captures use the same seeded populated four-role dataset with72 approved,16 pending and160 required hours, and the same1440×1000 /390×1000 viewport sizes. Dates reflect capture time; these are equivalent-data comparisons rather than pixel diffs. Public after-captures scroll through lazy/reveal content before returning to the top. Full-page Home/About images retain empty bands belonging to their existing sticky cinematic scroll regions; these are not missing redesigned dashboard content.

| Role | Before desktop | After desktop | Before mobile | After mobile |
| --- | --- | --- | --- | --- |
| Student | [Before](../tests/artifacts/redesign-before-Student-dashboard-1440.png) | [After](../tests/artifacts/redesign-after-Student-dashboard-1440.png) | [Before](../tests/artifacts/redesign-before-Student-dashboard-390.png) | [After](../tests/artifacts/redesign-after-Student-dashboard-390.png) |
| Company | [Before](../tests/artifacts/redesign-before-Company-dashboard-1440.png) | [After](../tests/artifacts/redesign-after-Company-dashboard-1440.png) | [Before](../tests/artifacts/redesign-before-Company-dashboard-390.png) | [After](../tests/artifacts/redesign-after-Company-dashboard-390.png) |
| Academic | [Before](../tests/artifacts/redesign-before-Academic-dashboard-1440.png) | [After](../tests/artifacts/redesign-after-Academic-dashboard-1440.png) | [Before](../tests/artifacts/redesign-before-Academic-dashboard-390.png) | [After](../tests/artifacts/redesign-after-Academic-dashboard-390.png) |
| Coordinator | [Before](../tests/artifacts/redesign-before-Coordinator-dashboard-1440.png) | [After](../tests/artifacts/redesign-after-Coordinator-dashboard-1440.png) | [Before](../tests/artifacts/redesign-before-Coordinator-dashboard-390.png) | [After](../tests/artifacts/redesign-after-Coordinator-dashboard-390.png) |

Representative work pages also have before/after captures under `redesign-{before,after}-{Role}-work-{1440,390}.png`: Student Opportunities, Company Applications, Academic StudentProgress, Coordinator CompletionReview. Public captures use `redesign-{before,after}-{Home,About,Contact,Login,PoweredBy}-{1440,390}.png`. The26 final after captures comprise eight dashboards, eight work pages and ten public views.

Additional evidence: [desktop journey dialog](../tests/artifacts/redesign-journey-modal-1440.png), [mobile dialog](../tests/artifacts/redesign-journey-modal-390.png), [confirmed save](../tests/artifacts/redesign-confirmed-save-1440.png), [motion recording](../tests/artifacts/redesign-interactions.webm). Four-role loading/error/empty captures are named `redesign-{loading,error,empty}-{Role}-390.png`.

## Coverage and remaining limits

Only four dashboards are claimed as recomposed. Other routes receive the shared shell/type/control system while preserving existing composition and workflows. The route-by-route distinction is in [30-workspace-redesign-coverage.md](30-workspace-redesign-coverage.md); machine-readable evidence is in [workspace-redesign-coverage.json](workspace-redesign-coverage.json). Reference URLs, skill use and implementation details are in [29-workspace-redesign.md](29-workspace-redesign.md).

No new UpdatePanel exists, so full postbacks and repeated initialization are runtime-tested; framework partial-postback support is structural. Not every row-command permutation, account combination, external photo storage provider, report download or email path was exercised. Favicon/document-negative resource responses are not uncaught JavaScript errors. Earlier exploratory runs exposed test-selector/confirmation-timing issues; they are not counted as passed runs. Final reports were generated only from completed result records.

Local screenshots, videos and result JSON live in ignored `tests/artifacts`; preserve that folder when sharing this working copy. To reproduce: run `postman simulation run postman/simulations/campus-login.sim.yaml --port 4930 --no-history`, start `tests/Start-LoginTestHost.ps1 -Port 58013 -SimulationPort 4930`, then run the `tests/redesign-*.browser.js` files sequentially through Playwright CLI. The fixture script resets local data; restore it between suites. Existing regression copies only change the host/port to58013/4930. Record with `playwright-cli -s=redesign video-start tests/artifacts/redesign-interactions.webm`, run the motion script, then `video-stop`. Generate current coverage with `python tools/audit-workspace-redesign.py` after completed outputs have been saved as `tests/artifacts/redesign-{workspace,routes,workflows,offers,actions,contracts,motion,after}.txt`.
