# UIMS shared sidebar — live notifications, 24 October 2026

The integrated live `ActivityBell` is anchored above the shared sidebar utility row in all four portals. The panel uses the sidebar's available viewport height, scrolls its activity list, follows RTL and the selected theme, and remains above desktop content. Mobile drawer focus includes the native summary control: Escape closes notifications first and restores bell focus; a second Escape closes the drawer. Closing or resizing the drawer also dismisses the notification panel. The summary exposes its panel ID and expanded state. Each master versions the shared layout and notification scripts to invalidate old cached assets.

`tests/SidebarNotificationsSmoke.cjs` passed **500 checks** across four authenticated fixture roles, English/Arabic, Light/Dark, 1440/390/320px widths and a 1000×420 short desktop. Coverage includes one sidebar bell, unread badges/filtering, CSRF on mark-all-read, inbox navigation, compact keyboard access, panel bounds/scrolling, Escape/focus behavior, zero unintended form posts and zero browser errors. Arabic/dark mobile captures were inspected under ignored `tests/artifacts/sidebar-notifications/`. Browser activity responses are synthetic; notification service checks run separately. The grade/export fixture now includes the app's language lifecycle and a headed login page for those checks.

Run `tests/Run-GradesExportSmoke.ps1 -Serve`, then `node tests/SidebarNotificationsSmoke.cjs` with Playwright available through `NODE_PATH` and Chrome installed. The fixture uses only localhost ports 19081/19082. No runtime npm dependency was added to the portal.

# UIMS shared sidebar — 23 October 2026

The single shared `Layout/Sidebar.ascx` now owns the former portal-header content for all four roles: localized portal/page context, one language toggle, one theme toggle, the existing notification control, and the existing trusted account/avatar link. The duplicate header account literals and initials helpers were removed from the four masters and their designers. Their logout controls and postback handlers remain intact. Desktop content no longer reserves the former top-bar space; mobile retains only the drawer opener above the page.

The visual refinement uses the existing UIMS wordmark alongside the original university logo, with the pin control in the heading. Primary-soft selection, 8px link corners, a neutral utility strip and a 12px account surface establish a quieter hierarchy. Link text remains 16px; secondary sidebar context is 12px and account names are 13px. Names, university identity, account routes and role data are preserved.

The expanded panel is 264px, the compact rail 76px, and the mobile drawer is at most 360px with space for its backdrop. Context and university identity appear above the role links. Utilities, account and logout sit below the independently scrolling navigation. Long names wrap within the account block. Scrollbars are visually hidden with standard and WebKit rules; wheel, touch and keyboard scrolling remain enabled. Short viewports use tighter spacing without removing navigation destinations.

Coordinator theme-reveal correction: `portal-motion.css` disables the root snapshot and names the sidebar/main separately for route navigation. While the existing `uims-theme-reveal` class is active, it now restores the root snapshot and temporarily removes those route names. The circular 900ms theme animation therefore captures the whole page; normal route names return when the class is cleaned up. The Coordinator master's stylesheet version is bumped to invalidate cached CSS. This changes no theme controller, preference storage, server route or authentication behavior. `tests/coordinator-theme.browser.js` passed 41 checks: actual 900ms circular root animation in both directions on nine Coordinator pages, restoration of navigation snapshot names, Arabic mobile, reduced motion and the three other role dashboards.

The same language/theme controllers and notification server routes are reused. The Bootstrap notification dropdown opens above the utility row, remains inside the drawer's focus scope, and is bounded by the available viewport height. Escape closes notifications first, then the drawer. Canceling a dirty-form language change keeps both input and drawer state. Preference persistence, native form validation, role authorization and logout behavior are preserved.

`tests/sidebar-unified.browser.js` passed 132 assertions against the disposable IIS host on port 58137 and existing Postman Auth/Firebase simulation on 4912. Coverage includes all four roles, English/Arabic server navigation, Light/Dark toggling, single controls, no desktop header gap, 1440/390/320px layouts, compact pin persistence, keyboard access, mobile focus/inert state and Escape, short-height navigation scrolling, notification popup bounds, unsaved account input and real logout postbacks. Build and diff whitespace checks passed. Screenshots are under ignored `tests/artifacts/sidebar-unified-*`.

One browser View Transition rejection on Coordinator-to-Login logout was reproduced on the unchanged earlier host at port 58136: `ViewTransition opt-in disabled`. The regression test records this exact baseline separately and rejects other page errors. Notification popup layout was checked with the existing empty-data fixture; its server data-loading code is unchanged. This does not certify production Firebase or physical mobile keyboard behavior. The earlier test suite and width claims below describe the historical implementation and are superseded by this update.

Run the existing simulation, then `tests/Start-LoginTestHost.ps1 -Port 58137 -SimulationPort 4912`, open the returned host with playwright-cli and run `tests/sidebar-unified.browser.js`. Production endpoints are changed only in that disposable copy, never in source configuration. No frontend package or framework was added.

---

# UIMS shared sidebar — 22 October 2026

The supplied DesktopSidebar, MobileSidebar, SidebarLink and SidebarDemo TSX is
translated into the existing ASP.NET Web Forms stack. No React, Next.js,
TypeScript, Tailwind, Framer Motion or npm dependency was added. The demo's
neutral vertical rail, 60/300px width states, fading labels and full-screen mobile
sheet are retained. Its demo dashboard, Acet Labs identity and avatar are replaced
by the existing UIMS content, original GJU PNG and server-derived account data.

## Changed files

Paths below are relative to the web project
`InternshipManagementSystem/InternshipManagementSystem/` unless stated otherwise.

- `Layout/Sidebar.ascx`: shared logo, navigation, account, close and pin markup;
  trusted role conditions; exact active-route aliases; encoded account data and
  HTTPS/application-relative profile image with initials fallback.
- `Layout/Student.master`, `Company.master`, `Academic.master`, `Coordinator.master`:
  mount the shared control once inside the existing sidebar. Existing logout IDs,
  naming containers, `btnSignOut_Click`, header literals and page placeholders are
  preserved. The missing favicon reference now uses the existing university PNG.
- Corresponding `.master.cs`: remove duplicate active-route helpers now centralized
  in the control. Existing user literals, initials and logout methods are retained.
- Corresponding `.master.designer.cs`: register `PortalSidebar` as a UserControl.
- `Assets/css/portal-layout.css`: neutral rail, stationary 20px icons, nonwrapping
  labels, independent navigation scroll, 240ms width/panel and 200ms label
  transitions, reduced motion, full-viewport mobile and logical RTL styles.
- `Assets/js/portal-layout.js`: hover/focus/pin state; only
  `uims.sidebar.pinned` in storage; separate mobile state; inert/ARIA dialog,
  Tab trap, Escape, focus restoration, selection close and resize reset;
  idempotent initialization and `Sys.Application.add_load` hook when available.
- `InternshipManagementSystem.csproj`: include the ASCX as deployment content.
- Repository-root `tests/sidebar.browser.js`, `DESIGN.md`, and this report.

Public navigation and Home were outside this change. The working tree already
contained earlier Home/public changes; those were preserved.

## Existing routes and functional coverage

Every link uses `ResolveUrl`; query strings on the current page do not interfere
with exact active matching. Detail aliases preserve the existing grouping.

| Role | Menu routes under `Pages/` | Account |
| --- | --- | --- |
| Student | `Student/Dashboard.aspx`, `Opportunities.aspx`, `MyApplications.aspx`, `MyTasks.aspx`, `Progress.aspx`; `Meetings/MyMeetings.aspx` | `Student/Profile.aspx` |
| Company Supervisor | `Company/Dashboard.aspx`, `Opportunities.aspx`, `Applications.aspx`, `Trainees.aspx`, `Tasks.aspx`, `TaskReview.aspx`, `FinalEvaluation.aspx`; shared Meetings | `Company/Account.aspx` |
| Academic Supervisor | `Academic/Dashboard.aspx`, `StudentProgress.aspx`, `FinalEvaluation.aspx`; shared Meetings | `Academic/Account.aspx` |
| Coordinator | `Coordinator/Dashboard.aspx`, `Students.aspx`, `Companies.aspx`, `AcademicSupervisors.aspx`, `Groups.aspx`, `Placements.aspx`, `CompletionReview.aspx`, `ContactMessages.aspx`; shared Meetings | `Coordinator/Account.aspx` |

`Apply` maps to My Applications, `OpportunityDetails` to Opportunities,
`TraineeDetails` to Trainees, `PlacementDetails` to Placements, and Meetings
`Schedule` to My Meetings. No partial path matching or placeholder destinations.

There is no standalone student completion-report page or implemented report
availability/download control to expose. The existing Progress page is a TODO
scaffold describing the intended approved-hours/result/report workflow. Company
attendance/hours has no standalone page; existing Trainees/TraineeDetails own that
functional grouping, with TraineeDetails still a scaffold. Coordinator completion
review/report generation is represented by CompletionReview, also a scaffold.
Account/role administration remains grouped in the existing Students, Companies
and AcademicSupervisors destinations. The sidebar does not claim these page
workflows are implemented, add unavailable report links, or expose company/academic
final evaluation pages to students. CoordinatorPage still guards final approval.

## Verification

Built the actual .NET Framework 4.7.2 solution in Debug with Visual Studio MSBuild.
Result: exit 0. JavaScript syntax and `git diff --check` passed.

Ran IIS Express at `http://localhost:57983` against a disposable application copy.
The repository's existing Postman simulation ran at port 4903 as the Firebase REST
stand-in. Disposable `__fixture.aspx` signs in test users only in that copy; it is
not deployed with the application. SecurePage still re-reads their role through
UserRepository on each protected request and postback. No production accounts or
real Firebase data were changed.

`playwright-cli -s=sidebar-review run-code --filename=tests/sidebar.browser.js`
passed **279 assertions across 39 protected page/role combinations**, all four
roles, with **zero browser console/page errors**. Covered:

- Exact active routes, aliases and role-specific destinations; cross-role denial.
- 60px initial rail, 300px hover/focus, collapse after leaving both, stationary
  icons, native tooltips, pin/unpin and reload persistence.
- Desktop pin survives a mobile open/close/resize cycle; mobile open never pins.
- One panel/form/logout, non-submit menu buttons, existing native validation,
  successful application submission postback and real session logout per role.
- Full-width mobile panel, visible labels, inert/ARIA closed state, scroll lock,
  modal semantics, forward/reverse Tab wrapping, Escape focus restoration,
  selecting a destination and resizing to desktop.
- Long coordinator account name, independently scrolling long menu on a short
  screen, visible/reachable logout, RTL panel entry/exit and desktop edge,
  reduced motion and no-JavaScript fallback.
- No horizontal overflow at 320, 390, 768, 900, 901, 1000, 1440 and 1920px.
- Repeated initialization and replacing the panel DOM without duplicate handlers.

Evidence: `tests/artifacts/sidebar-tests.txt`, `sidebar-simulation.ndjson`,
`sidebar-inspect.json`, and `sidebar-{role}-expanded.png` / `sidebar-{role}-mobile.png`.
The simulation log records real app requests reaching the modeled Firebase paths.
This verifies the application's HTTP integration against that stand-in, not live
Firebase Authentication password login or production Firebase authorization rules.

No UpdatePanel exists in the repository. Initialization/replacement behavior was
exercised; a real partial postback could not be exercised without introducing one.
An additional IIS host for `/uims` virtual-application testing was rejected by
automatic approval review (`blocked by policy`, no detailed reason returned).
That runtime check is **not verified**. The implementation consistently uses
application-relative server URL generation; root-path deployment was exercised.

To reproduce, build the solution, run the existing Postman simulation with
`postman simulation run postman/simulations/internship-application.sim.yaml --port 4903 --no-history`,
start `tests/Start-ApplicationTestHost.ps1 -Port 57983 -SimulationPort 4903`,
open its fixture URL with playwright-cli, then run the browser test above.
The test creates/resets local fixtures; use the disposable host and simulation.

## Visual review

Used the design-taste app-screen workflow. Chosen sheet: **Achromatic ledger,
seed 1802906319**, no redraws. Palette/type were explicitly kept from the project.
The user-supplied 60/300px rail, navy active ink and existing dashboard header
supersede the sheet's generic shell geometry. Neutral surfaces and restrained
borders carry its visual intent.

Screen question: “Where can I go next for my verified internship role?” The face
is the original GJU mark and university/product lockup; the distinctive content is
the internship workflow specific to each role plus the real account/role row.
No sample product content was added; named test accounts and the stress-test long
name exist only in the local fixture database.

Reviewed collapsed/expanded desktop and open mobile captures for the four roles,
short-height long-menu/name stress and RTL. Round one revealed mobile labels losing
the CSS specificity contest; corrected. Round two exposed the RTL closed transform
winning over the open state; corrected. Final screenshots have readable labels,
stable icon positions, visible account/logout and no overflow. Existing dashboard
content and its TODO scaffolds were kept.

Source lint: **0 FAIL, 0 WARN**. Rendered app inspection at 1440/768/390px:
**0 FAIL, 0 WARN**, no allowed rule exceptions, zero console errors. Inspected
fold images at all three sizes, plus role menu screenshots and long-name/RTL
captures. These are visual/functional checks, not a claim that unfinished page
workflows or live Firebase authentication have been completed.
