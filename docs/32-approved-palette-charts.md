# Approved colors, larger typography and interactive dashboards

23 October 2026. Implements the user's latest correction: restore the established project colors, change/enlarge typography throughout the interface, and feature interactive charts with the main information for all four dashboard roles. This supersedes the ivory canvas/dark-navigation palette documented in the earlier workspace revision.

## Implemented changes

The approved palette was recovered from the committed `portal-layout.css`: primary blue#264f73, dark blue#173f62, pale blue#e5efff, ink#133d61, canvas#f6f8ff and light gray navigation#f5f5f5. White work surfaces and existing branding gold#c8a349 remain. Six coordinated categorical bar colors distinguish the actual values; labels, numbers and selected-state semantics keep color from being the only cue.

Self-hosted Noto Sans and Noto Sans Arabic variable fonts now replace the previous Switzer/Segoe interface mix across the five master layouts. The body and editable controls are18px, table text17px, section headings24–27px, page titles34–44px and major metric counts42px. Supporting type is generally15–16px; sidebar account metadata remains14px. Existing public cinematic geometry, photographs, logos and physical3D branding are preserved. Legacy family declarations are deliberately overridden by the shared `interface.css` type system.

Font sources: [official Noto Sans files](https://github.com/google/fonts/tree/main/ofl/notosans), [official Noto Sans Arabic files](https://github.com/google/fonts/tree/main/ofl/notosansarabic). Both use SIL Open Font License1.1; unmodified license files ship beside the local fonts. No external font service is required at runtime. Historical Switzer assets remain for compatibility.

Each dashboard now places its main chart before the existing journey and working lists. The chart is built from the already-authorized dashboard read model; it adds no Firebase schema, HTTP request or write handler. Native view selection changes the chart in place. Click/Enter/Space selects a category, arrows/Home/End move through bars, and sorting toggles between descending value and original order. A context panel shows the exact value, explanation and permitted related-record link. On mobile it moves below the plot. Direct labels, counts, units and data remain server-rendered, with a clear zero-record state and reduced-motion support. No chart library or new runtime dependency was added.

| Role | Actual chart views |
| --- | --- |
| Student | Approved/pending/required hours; placement task statuses; application decisions |
| Company | Company application decisions; pending application/submission/final-assessment queues |
| Academic | Mutually exclusive progress categories for assigned students; assessment follow-up indicators |
| Coordinator | Mutually exclusive completion queue categories; submitted final-assessment counts; active student assignments |

Hours targets are reference values, not part of a sum of completed hours. Pending hours are never counted as approved. Work queues that can overlap say so explicitly. Ready for review does not mean approved completion; the coordinator's existing gate remains authoritative. Student charts do not read confidential final assessments. No trends, time series or percentages are fabricated.

The font pass also fixes profile header name overlap after enlargement, readable profile instruction/file-action text, long-error wrapping, readable public contact/login/lecture-hall copy and navigation label wrapping. Public scene code was preserved; the PoweredBy capture now waits for its existing camera to settle at overview.

## Actual verification

All writes and reads used a disposable Web Forms copy and local Postman dependencies. No production or live Firebase verification is claimed.

| Check | Completed result |
| --- | --- |
| MSBuild Debug solution | Passed |
| workspace-charts.js syntax | Passed |
| `tests/workspace-charts.browser.js` | 216 checks passed across all four roles at1440/390px |
| Existing route inventory, host-adjusted | 98 visits across52 route files;3 inventory checks passed |
| Existing workflow regression, host/port adjusted | 24 checks passed |
| `tests/workspace-charts-capture.browser.js` | 18 work/public captures with viewport/font checks |
| Chart recording | Actual selection, view change and sorting |
| Final Profile action check | 16px action text and no overflow at1440/390px |
| Independent finish review | Four chart/palette compositions accepted; listed profile fixes resolved. Final SHIP covers the last action-typography fix, not every operational route. |

Chart tests verify native selectors, selected-value truth, sorting/restoration, keyboard focus, role-scoped links, loaded local fonts at18px, restored canvas/navigation colors, no viewport overflow, no confidential student data, real dependency-read failure, explicit zero data and reduced motion. The populated student chart reports72 approved,16 pending and160 required hours. Existing workflow checks cover real write failures/retry, retained inputs, native PDF upload, Bootstrap modal/tab keyboard behavior and real server pagination/Back navigation. The two document-route visits are authorization negative checks, not proof of generated reports/downloads.

The route check initially found a long profile-error message overflowing mobile because the local stand-in had not modeled the existing `studentProfileExtras` path. That existing path is now modeled and long errors wrap safely. Final reports use the completed passing run, not the exploratory failure.

## Visual evidence

| Role | Desktop | Mobile |
| --- | --- | --- |
| Student | [Current](../tests/artifacts/charts-Student-1440.png) | [Current](../tests/artifacts/charts-Student-390.png) |
| Company | [Current](../tests/artifacts/charts-Company-1440.png) | [Current](../tests/artifacts/charts-Company-390.png) |
| Academic | [Current](../tests/artifacts/charts-Academic-1440.png) | [Current](../tests/artifacts/charts-Academic-390.png) |
| Coordinator | [Current](../tests/artifacts/charts-Coordinator-1440.png) | [Current](../tests/artifacts/charts-Coordinator-390.png) |

[Short interaction recording](../tests/artifacts/charts-interactions.webm). Eight representative work captures use `charts-{Role}-work-{1440,390}.png`; ten public first-viewport captures use `charts-{Home,About,Contact,Login,PoweredBy}-{1440,390}.png`. Prior equivalent-data dashboard captures remain linked in [31-workspace-redesign-verification.md](31-workspace-redesign-verification.md) for comparison. Screenshots/videos live in ignored `tests/artifacts`; keep that folder with the working copy.

## Reproduce and scope

Run the existing `postman/simulations/campus-login.sim.yaml` on4930 and `tests/Start-LoginTestHost.ps1 -Port 58014 -SimulationPort 4930`. Seed with `tests/redesign-fixture.browser.js`, then run the chart and capture scripts sequentially through Playwright CLI; reseed between suites. Host-adjusted copies of the prior route/workflow scripts remain in `tests/artifacts/charts-{routes,workflows}.browser.js`. Run `python tools/report-workspace-charts.py` to collect completed outputs and generate [machine-readable evidence](workspace-charts-verification.json).

The four dashboards gain charts; other pages receive the shared palette/type system without being claimed as individually recomposed. Existing business logic, server IDs, validation, native form postbacks/uploads and public scene concepts remain. No commit or push was performed. Not every business mutation/account combination or external storage/email path was re-exercised. Applicable skills: frontend-design, ui-ux-pro-max's category-comparison/accessibility guidance, apple-design's precise feedback/reduced-motion guidance and impeccable's finish review/documentation workflow. Noto's official font sources are cited above; no unverified design-system search output was adopted.
