# Supervisor interface system

This pass applies only to pages using `Layout/Academic.master` or `Layout/Company.master`, including shared routes when rendered through those masters. Student, Coordinator and public masters do not load the new files.

The pasted reference is a text inventory, not a visual specification: it identifies buttons, 20px/2px outline icons, badges, fields, search/filter controls, metrics, lists and dialogs. Sample names, counts and policies in that inventory are not application data and were not added to production pages.

## Component contract

| Component | Shared treatment |
| --- | --- |
| Buttons | 44px minimum target, 8px corners, 16px semibold text; primary, secondary, destructive and accent variants; visible focus, hover, pressed and disabled states |
| Inputs and search | 44px minimum, consistent borders/corners; native input types and server names retained; existing text supplies accessible names |
| Checkboxes/radios | Native 20px control, associated label with a 44px minimum target; selected state remains native |
| Badges | Content-sized, wrapping labels, 13px text and semantic theme colors; status remains readable without color |
| Metrics | Same panel edges, padding, 30px values and tabular numerals; clear label/value/help order |
| Progress | Solid 8px track, approved/required values and accessible progress semantics; no perpetual striped animation |
| Tables | Readable sentence-case headers, consistent cell spacing, separate secondary information and horizontal scrolling on small screens |
| Dialogs | Bounded viewport height, internal scrolling, clear title/action regions, focus management and Escape support |
| Icons | Existing outline SVG vocabulary, 20px icons with a 2px stroke; additional Bootstrap glyphs mapped to matching outlines |

## Integration

- `Assets/css/supervisor-ui.css` is loaded after the existing page/shared styles in the two masters. `uims-supervisor` scopes all rules. Existing colors and English/Arabic font assets remain in use.
- `Assets/js/supervisor-ui.js` adapts legacy component classes into `su-*` presentation classes. It does not intercept application actions, translate text, persist form values, or replace validation/postback code. It handles inserted content and partial postbacks.
- Custom task overlays reuse `UimsUI`'s existing focus trap, Escape handling and focus return. Bootstrap retains ownership of Bootstrap dialogs.
- Opportunity activation/deactivation confirmation also uses that dialog enhancement. Stray attribute text inside its confirmation button was removed while preserving `moAction=toggle`; its labels/messages now use the existing resource-based localization system.
- Printable `.uims-paper` content is excluded from adaptation. The original report and certificate artwork remain separate from interface components.
- The Academic student progress summary previously displayed fixed `0 / 160` sample values. It now uses the same server-loaded approved/required hours and placement status already shown on that page. No new grading or completion rule was introduced.

## Verification

Use a disposable host from `tests/Start-LoginTestHost.ps1` with the existing local test service. Copy `tests/fixtures/supervisor-components.aspx` to that host as `__supervisor-kit.aspx`, open the browser on the host and run:

```powershell
playwright-cli run-code --filename tests/supervisor-ui.browser.js
```

The component fixture exists only under `tests/` and in the disposable host. It contains explicitly synthetic populated rows and is not included in the application project.

Browser verification covers the 14 main Company/Academic routes, Light/Dark desktop views, Arabic/RTL phone layouts, component contrast, progress semantics, checkboxes, Bootstrap/task dialog focus, read-only Academic search postback, and the absence of the new system from Student/Coordinator pages. It does not submit application decisions, grades, profile changes or other business writes. Routes requiring an assigned student/placement also use component-level synthetic coverage; empty test accounts do not establish every populated production state.

Screenshots and logs are stored under ignored `tests/artifacts/`. Debug build and JavaScript syntax checks accompany browser verification.

Verified locally on 2026-10-24: **157 browser checks passed**, with no uncaught browser errors. The matrix includes 375px portrait and 844px landscape at 100%/200% root text size, native checkbox keyboard activation, and confirmation-dialog focus/submit-value preservation. Debug solution build, JavaScript syntax and `git diff --check` passed. Visual review includes actual task creation and account dialogs, desktop dashboards and Arabic Dark phone views. No business write was submitted during verification.

## Follow-up: populated opportunities and meetings

User screenshots exposed cases missing from the first empty-account route checks: compressed opportunity actions, duplicate HTML text inside the edit Save button, an overlapping task-search pseudo-icon, small meeting controls and an incorrectly decoded close glyph.

- Opportunity list/edit/details views now use up to 1440px of the workspace. The list reserves space for complete action labels and scrolls within its table on smaller screens. Technical record IDs remain available in details rather than occupying every list row.
- The edit Save button keeps its original `moAction=save` semantics and resource label; duplicate attribute text and a repeated back arrow were removed. Description/requirements textareas have at least 144px of editing space.
- Task search uses one outlined SVG with explicit logical input padding.
- Meeting controls, summary cards and statuses now participate in the supervisor component contract. The real server filter and Apply button are moved into the toolbar for Company/Academic views only; their names, IDs, options, event handlers and postback behavior are retained. The original view-popup trigger is hidden only after enhancement succeeds.
- Meeting request/details dialogs keep native `showModal()` behavior, with bounded scrolling, stable footer actions, readable details/agenda alignment and an ASCII SVG close icon. The shared ASPX page explicitly declares UTF-8. Meeting invitation/approval/join/completion rules are unchanged.

Run `python tests/prepare-supervisor-visual-host.py` against a `supervisor-host.json` produced by the disposable-host helper, rebuild that temporary project, then run `tests/supervisor-populated-layout.browser.js`. The preparer refuses paths outside a temporary `uims-o01-*` host. It supplies synthetic display records only in temporary code-behind copies, never application sources or remote data.

Final verification: **157 base checks + 83 populated-layout checks = 240 passed**. Populated checks cover full opportunity action labels, edit form/Save markup, details layout, meeting rows and dialogs for both supervisor roles, English/Arabic, Light/Dark, 1440px/390px layouts, request draft preservation and read-only filter postbacks. Screenshots were also reviewed at 1920px. No opportunity save, invitation, approval, cancellation or other business write was submitted; this establishes UI behavior rather than end-to-end write integration.

## Live meeting search and views

The subsequent search enhancement replaces the supervisor Apply interaction with immediate local filtering. A labeled search field matches meeting titles and participant names, supports case/Arabic-diacritic normalization, combines with the existing view selector, and provides clear/count/no-results feedback. Enter in this field never submits the Web Forms form. Refresh still obtains new server data; this is live filtering, not background polling.

Company/Academic rendering includes the complete set returned by the existing authorized `GetMine` query. Each row carries view memberships calculated with the original server predicates (`CanRespond`, `IsPending`, `IsApproved`, `IsHistory`), so the client does not infer permission or status from translated text. Initial nonmatching rows are hidden by CSS until enhancement runs; the initial selected view also works without JavaScript. Other roles retain server-filtered binding. Existing action handlers and authorization remain unchanged.

`tests/meetings-live-search.browser.js`: **79 checks passed** for both supervisor roles and languages, combined title/person/view matching, clear/empty states, Enter protection, no POST/navigation while filtering, phone themes, initial history-to-all switching, and no-JavaScript initial filtering. The populated regression suite's 83 checks also passed with live selection. Debug build and JavaScript syntax checks passed.

## Unified supervisor accounts

Company and Academic account pages now use the same `su-account` composition: page title/intro, a compact identity rail with start-aligned avatar/name/role and stacked actions, and two information sections for personal details and institutional association. Definition rows replace nested fact cards and the oversized cover. Both roles use the same widths, spacing, heading hierarchy and Edit profile dialog. Small screens stack the identity and information sections; actions remain below the identity even at 200% text size. Long read-only values wrap as selectable text. Missing values have a localized fallback, and both avatar initial treatments use the same two-letter convention where available.

Academic official fields and full name remain noneditable. Age and phone keep their existing save handler; the existing photo upload still runs on file selection and its helper text says so. Company name/phone/job title/photo keep the existing profile handler. Company password navigation uses the existing authenticated Change Password page; Academic retains its existing password dialog. This is presentation unification, not a change to account authorization, storage, upload policy or authentication. The duplicate page-local Bootstrap runtime was removed from Company Account so the master owns dialog initialization.

`tests/supervisor-account.browser.js`: **75 checks passed**, covering both roles, English/Arabic, Light/Dark, desktop/phone layouts, start-aligned identity, shared actions, role-specific readonly controls, Edit dialog semantics, cancel/reopen draft preservation, existing save/password controls, one Bootstrap runtime, and 375px/200% text layout. No profile, photo or password write was submitted; storage/authentication integration behavior is not newly established by these UI checks. Screenshots are under `tests/artifacts/account-*`.

## Application review loading

The initial queue binds names and majors saved on application records. Optional
student profiles, skills and document metadata load only for the selected
application through `Applications.aspx?candidate=<applicationId>`. The server
matches this ID against the signed-in company's applications before fetching a
profile. JavaScript imports only the candidate panel into the existing page;
decision buttons, postback controls and unsaved rejection fields stay in place.
A failed or timed-out detail request retains a localized retry link. Without
JavaScript, that link opens the same authenticated page with the selected details.
Loaded panels are reused within the page; PDF previews remain deferred.

On 2026-10-24, the real IIS application against the local Postman Firebase
simulation with shared read caching disabled made **3 initial reads instead of
39** for 12 synthetic applications. This measures initial database round trips,
not live Firebase latency; the selected profile adds its own reads afterward.
`tests/application-review-loading.browser.js` passed **22 checks**, including
independent detail loading, retry, unsaved input protection, actual acceptance and
rejection postbacks, Arabic Dark mobile, no-JavaScript fallback and company scoping.
Production Firebase rules and external network performance were not tested.
