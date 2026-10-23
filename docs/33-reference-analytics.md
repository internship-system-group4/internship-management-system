# Reference analytics implementation

Implemented 23 October 2026 on `osamabanihani`. Read both supplied attachments, including the actual `revenue-charts-kpi.tsx` and `demo.tsx`. Adapted their composition to existing Web Forms, C#, Bootstrap and native SVG/JavaScript. No React, Tailwind, Recharts or new runtime dependency. Existing blue/white/gray palette and Noto fonts retained. No public-page redesign in this task; prior unrelated workspace edits preserved. No commit or push.

## Reference mapping

| Reference | UIMS implementation |
|---|---|
| ChartCard | Shared `Layout/WorkspaceChart.ascx`, scoped `reference-analytics.css`: 18px corners, hairline border, 20px titles, View data tables |
| KpiCard | Four native drill-down buttons, 14px corners, 36px values, actual values without counting animation |
| Sparkline | Native SVG curve, only when two or more actual dated month buckets exist |
| AreaTrend | 2px monotone line, semantic approval color, 14% to 2% fill, actual date spacing and monthly records |
| BarCompare | Narrow bars capped at 24px, 4px corners, direct values, semantic legend, measured mobile labels |
| DonutBreakdown | Full-width panel below primary charts; exclusive categories, 54/80 inner/outer radii, adjacent names/counts/shares |
| Demo range selector | Native keyboard radio group, 6/12 months, 340ms anchored moving indicator |

Journey remains above analytics. Desktop has four KPIs and two primary chart columns; charts stack on tablet/mobile and KPI cards become two columns. Readable 13–14px labels, 16px interface text and 36px page headings (32px mobile). Existing work queues, progress, actions and server-control IDs remain. Previous repeated KPI band is hidden, preserving controls. Chart entrance is 620ms; snapshot charts do not replay for range changes. Reduced motion skips animation.

## Metric definitions and authorized scope

| Role | Four KPIs | Primary charts | Exclusive donut |
|---|---|---|---|
| Student | All own applications; pending own applications; approved hours in selected range; assigned/revision-requested tasks | Approved positive training hours by actual `ReviewedAt`; own tasks by current status | Own applications: pending/accepted/rejected/withdrawn, unknown if present |
| Company | Confirmed/active trainees; pending company applications; submitted/under-review submissions; sum of reported pending hours | Company approved hours by `ReviewedAt`; three independent queue counts: applications, submissions, hour entries | Company application decisions |
| Academic | Assigned students; confirmed/active placements; company feedback received with academic action outstanding; approved hours in range | Assigned students' approved hours by `ReviewedAt`; exclusive hours-target-met/training/target-unset/no-placement groups | Submitted, ready for academic action, awaiting company, awaiting placement |
| Coordinator | Student profiles; active profiles without academic supervisor; final reviews ready excluding returned; explicitly approved completions in range | Current retained approved completion records by `ApprovedAt`; student profiles grouped by college, missing college explicit | Approved, returned, ready, awaiting company, awaiting academic |

Factory consumes existing server-authorized repository read models, reusing loaded hours/profile records; no request per chart or new Firebase schema/write. Company queue bars share the unit *items* but can overlap: they are explicitly independent queues, never donut shares. Pending-hours KPI uses hours, while hour-entry bar counts records. An academic hours target is not final completion. Coordinator ready means both assessments received; requirements still need review.

Range starts at UTC calendar month start, 5 or 11 months before the current month, ending at the model's current UTC instant. Only dated approval activity and flow KPIs change. Snapshot categories/totals are labeled current and remain unchanged. The preceding comparison window has equal elapsed duration; percentage appears only with a positive dated previous denominator and uses neutral wording.

Unavailable historical status snapshots are not reconstructed. Only actual recorded approval months are plotted; missing months are not invented zero observations. Single-month history is one point with no decorative sparkline. A known empty dataset is zero with an empty chart. Undated/invalid/future approval dates are excluded from every range and inspectable as undated records; when all approvals lack usable dates the historical KPI is a dash. Constructor-generated submission timestamps are deliberately not used. Historical series represent currently retained approved records, not an immutable audit trail or past period-end status.

Category/KPI/month drill-down uses actual authorized records, 10 per page, safe local links, centered Bootstrap dialog, Escape/focus return and preserved range. Native legend buttons and real data tables provide keyboard alternatives to pointer marks. JSON uses Newtonsoft `EscapeHtml`; generated content uses `textContent`. Resize and repeated initialization retain one instance. Existing authorization, validation, postbacks and workflows remain.

## Actual local verification

Built the solution successfully with Visual Studio MSBuild; JavaScript syntax and `git diff --check` pass. Tests used a disposable ASP.NET host at localhost:58015 against the existing local Postman Firebase simulation at localhost:4930. Fixtures never wrote to live Firebase. No live deployment or production-data validation is claimed.

- `tests/reference-analytics.browser.js`: **315 passed**, four roles × 1440/768/390/320px, metric ranges, scope exclusions, exclusive totals, keyboard ranges, modal trap/focus return, responsive resizing, table fallback, missing/zero/single point, safe hostile text, reduced motion, real simulated read failure and denied cross-role dashboards. No uncaught page errors.
- Route inventory: **98 visits**, all **52 declared page paths** exercised; three aggregate checks passed: no server errors, no viewport overflow, no uncaught page errors. Includes expected authorization/document negative results.
- Existing workflow suite: **24 passed**, persistent failed-write/retry behavior, real stored application/rejection results, native PDF upload, Bootstrap modal/tab behavior and actual list pagination.
- `tests/reference-interactions.browser.js`: **12 passed after the final mobile-label correction**: measured 620ms area/340ms selector animations, no stock-chart replay, 72-hour reconciliation to three records, month-mark drill-down, preserved range, bounded tooltip at 320px, idempotent refresh and 10-row modal pagination.
- Fresh independent visual reviewer: **SHIP** after a bounded measured-label fix and three confirming Company/Academic mobile recaptures. Reviewed all four roles at desktop/mobile/320px and centered-modal captures.

The original interaction test attempted Escape during Bootstrap's opening transition; the harness now waits for that transition before testing dismissal. No product change was required for this test timing correction.

## Evidence

Paths are repository-relative. Screenshots and videos are local ignored verification artifacts, not runtime/public assets.

| Role | Desktop | Mobile | Narrow |
|---|---|---|---|
| Student | [1440px](../tests/artifacts/reference-Student-1440.png) | [390px](../tests/artifacts/reference-Student-390.png) | [320px](../tests/artifacts/reference-Student-320.png) |
| Company | [1440px](../tests/artifacts/reference-Company-1440.png) | [390px](../tests/artifacts/reference-Company-390.png) | [320px](../tests/artifacts/reference-Company-320.png) |
| Academic | [1440px](../tests/artifacts/reference-Academic-1440.png) | [390px](../tests/artifacts/reference-Academic-390.png) | [320px](../tests/artifacts/reference-Academic-320.png) |
| Coordinator | [1440px](../tests/artifacts/reference-Coordinator-1440.png) | [390px](../tests/artifacts/reference-Coordinator-390.png) | [320px](../tests/artifacts/reference-Coordinator-320.png) |

[Desktop modal](../tests/artifacts/reference-modal-1440.png), [mobile modal](../tests/artifacts/reference-modal-390.png), [range and drill-down recording](../tests/artifacts/reference-interactions.webm).

Raw outputs: `tests/artifacts/reference-functional.txt`, `reference-routes.txt`, `reference-workflows.txt`, `reference-interactions.txt`, `reference-build.txt`. Reproduction: start the existing Postman campus simulation on 4930 and disposable test host on 58015; run `redesign-fixture.browser.js`, then `reference-analytics-fixture.browser.js`; run browser suites sequentially. Route/workflow suites reset local fixtures, so reseed both fixtures before analytics verification or recording.

## Scoped implementation files

- `Data/WorkspaceDashboardRepository.cs`: retain already-authorized hours/profiles and placement status for accurate metrics.
- `Data/WorkspaceChartFactory.cs`: role adapters, definitions, records and dated event models.
- `Layout/WorkspaceChart.ascx` and `.ascx.cs`: shared composition, safe serialization and modal/data alternatives.
- `Assets/js/workspace-charts.js`, `Assets/css/reference-analytics.css`: reusable SVG rendering, responsive labels, filters, motion and drill-down.
- `Pages/{Student,Company,Academic,Coordinator}/Dashboard.aspx`: journey-first composition, retained workflow controls.
- `Layout/{Student,Company,Academic,Coordinator}.master`: scoped asset inclusion/cache version; project file publishes new stylesheet.
- `DESIGN.md`, `.impeccable/design.json`, `.impeccable/briefs/reference-analytics.md`: scoped final component guidance/reference contract.
- Three `tests/reference-*.browser.js` files and this report.

No new raster assets, external design templates or package licenses were introduced. Existing Noto font and vendor provenance remains unchanged.
