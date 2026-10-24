# Light / Dark theme audit

Scope: every page, master page and user control in `InternshipManagementSystem/`, in Light and Dark, English and Arabic
(LTR/RTL), desktop (1440×900) and phone (390×844). Audited on branch `osamabanihani` at `cd6a1ea` plus the working-tree
changes listed below. The theme system itself is described in `docs/32-theme-system.md`; this document records what was
checked, what was wrong and what changed.

## How the theme works (unchanged)

- Each master's inline `<head>` script reads `localStorage['uims-theme']` (`light` | `dark`, Light by default) and sets
  `data-theme`, `data-bs-theme` and `data-theme-preference` on `<html>` before first paint. `Assets/js/theme.js` drives the
  toggle (circular View Transition reveal, reduced-motion fallback, cross-tab `storage` sync, bfcache `pageshow`) and fires
  `uims:themechange`.
- Colours: `Assets/css/ui-tokens.css` holds the Light semantic tokens (`--ui-*`); `Assets/css/theme.css` holds the Dark
  values, the Bootstrap 5.3 dark mapping and a generated block of `--th-<role>-<hex>` tokens. Stylesheets and page styles
  write colours as `var(--token, #original)`, so Light renders the original value and only Dark defines the token.
  `tools/theme/convert-colors.py` performs that rewrite and regenerates the block.

## Root causes found and fixed

| # | Root cause | Effect | Fix |
|---|---|---|---|
| 1 | Pages and stylesheets merged after the theme pass used raw hex colours (notifications, meetings, Jisr home/journey, company opportunities, forgot password, contact messages, grades and others). | White cards, tables and buttons in Dark; navy text on navy. | Tokenized with the existing tool (`var(--th-…, #orig)` / semantic tokens). Light is unchanged by construction. |
| 2 | Class-name collision: the theme toggle wrapper (`Layout/ThemeSelector.ascx`) and the team page scope in `Assets/theme.css` both use `.uims-theme`. | The toggle picked up a light page background; page scopes picked up `display:inline-flex` and 20px SVG sizing. | `Assets/theme.css` scope → `.uims-theme:not([data-theme-control])`; toggle rules in `css/theme.css` → `.uims-theme[data-theme-control]`. |
| 3 | `Layout/Public.master` "Global Navbar Master Fix" keyed on a `.scrolled` class that no script sets (`public-navbar.js` uses `data-scrolled` / `data-compact`). | White links forced with `!important` on every public page and state: unreadable on light pages and on the light compact bar (Light "AR" 1:1). | Scoped to the top state of pages that open on a dark full-bleed stage (`:has(.jisr)`, `:has(#gju404)`); the shared navbar states handle the rest. |
| 4 | Bootstrap mid tones used as text: `.text-primary` / default link `#0d6efd` (4.3:1 on the canvas and tinted rows), `.text-success/-warning/-danger/-info` on dark surfaces. | AA failures in both themes (badges, report scores, links). | `.text-primary` → `var(--ui-primary-text, var(--ui-primary))` in both themes; Light `--bs-link-color` → UIMS primary; Dark status text utilities → light status tones. |
| 5 | Muted greys just under 4.5:1 (`site.css --muted #6b7786` and a dozen page-level variants such as `#718298`, `#7a8ca1`, `#888`). | Light AA failures on the portal canvas and white cards. | Mapped to the semantic `--ui-muted` (5.7:1 on the canvas; light grey in Dark). |
| 6 | Page-level colour variables the tool cannot infer (`--jisr-muted`, Default `--uims-heading`, MyMeetings `--primary` used as text, `.ws-hours` band). | Near-black or 3:1 text in Dark. | Dark values added beside each variable (`--ui-muted`, `--ui-ink`, `--primary-text`, `--ui-brand-deep`). |
| 7 | Printable documents (official evaluation report, completion certificate) were themed like the UI. | In Dark the certificate became a dark certificate and the report's total row became light text on a light row. | New `.uims-paper` scope (+ `data-bs-theme="light"`): documents stay on light paper in both themes, so what is shown is what prints / saves as PDF. The tool now generates a reset of every `--th-*` token to its Light original inside `.uims-paper`. |
| 8 | Bootstrap's dark `.btn-close` filter inverts the whole element, including a `bg-white` disc. | Certificate close button was a blank white disc. | `[data-theme=dark] .btn-close.bg-white { filter:none; background:#fff }`. |
| 9 | The tool's selector check only saw the first declaration of a rule, and dark-by-design scenes were lightened. | Later declarations bypassed the skip list; the 404 night scene lost contrast. | Selector is read from the rule's `{`; `gju404` added to the skip list; file arguments added so one page can be converted without touching others. |
| 10 | Third-party map controls (MapLibre) keep white cards. | White squares in the Dark footer. | Control cards/attribution follow the dark surface; glyphs inverted (targeted, not a page filter). |

Found while auditing (not theme, fixed because they broke rendered pages): markup saved as UTF-8 without BOM rendered as
Windows-1252 (Inbox "â€", garbled Arabic) → BOM added to 7 files; `Global.asax.cs` page-title localization threw on pages
without `<head runat="server">` (CompletionReport, exploreOpport) → guarded.

## Shared token / component changes

- `Assets/css/theme.css`: Dark `--ui-brand-deep`; Bootstrap text utilities; MapLibre footer controls; `.uims-paper` scope;
  `.btn-close.bg-white`; toggle selectors; generated block (Dark tokens + paper reset). Cache version `theme-8` in all
  masters and `NotFound.aspx`.
- `Assets/theme.css` (team reference): scope excludes the toggle.
- `Assets/css/site.css`: `--muted` → `--ui-muted`. `Assets/css/interface.css`: hours band token. `Assets/css/jisr.css`,
  `notifications.css`, `task-workflow.css` and page styles: tokens as above.
- `tools/theme/convert-colors.py`: per-rule selector skip, `gju404` skip, file arguments, paper reset generation.

## Page-specific fixes worth knowing

- Company Evaluation Report / Final Evaluation: report and certificate are `.uims-paper`; "Preview Certificate" gold darkened
  to `#7d5c05` (hover `#604603`) — `#b8860b` / `#daa520` were 3.3:1 / 2.1:1 on white; certificate captions → `--ui-muted`.
- Meetings (MyMeetings): whole page tokenized; eyebrow uses a text variant of the teal.
- Default / Journey (Jisr): section cards, steps and CTA sections tokenized; secondary copy uses `--ui-muted` in Dark.
- 404 (`#gju404`): kept as a night scene in both themes (excluded from conversion).

Intentionally light in Dark (not defects): official logos on their white backing, the printable documents, the About film's
white play button (it sits on footage), the yellow "My Drafts" warning buttons (dark text on Bootstrap warning yellow),
the 404 gold decor circle, the 3D scenes' daylight materials and the coordinator dashboard illustration.

## Coverage matrix

Verification method: **B** = browser verified by the automated audit (`tests/theme-audit.browser.js`: every route as its
fixture role, Light + Dark × EN + AR × 1440 + 390, AA text contrast against the composited background, light surfaces in
Dark, page errors, server errors), plus **S** = interactive states exercised in `tests/theme-states.browser.js` /
`tests/theme.browser.js` / `tests/theme-company-surfaces.browser.js`, plus **V** = screenshots reviewed by eye.

| Page / route | Light | Dark | EN/AR | Desktop/mobile | Interactive states | Method | Remaining issues |
|---|---|---|---|---|---|---|---|
| Home `/Default.aspx` | ✓ | ✓ | ✓ | ✓ | toggle + reveal, navbar top/scrolled/compact | B S V | Top navbar keeps white links over the bright 3D sky (team design; text shadow) |
| Journey | ✓ | ✓ | ✓ | ✓ | navbar states | B V | — |
| About | ✓ | ✓ | ✓ | ✓ | navbar states | B V | Audit flags objective list items (false positive: 2px gradient rule averaged as background) |
| Contact | ✓ | ✓ | ✓ | ✓ | empty submit → validation messages | B S V | — |
| Powered by | ✓ | ✓ | ✓ | ✓ | navbar states | B V | 3D hall text is over canvas (not measurable; reviewed by eye) |
| Login | ✓ | ✓ | ✓ | ✓ | sign-in in Dark, first paint | B S V | Being redesigned in a parallel session; re-check after it lands |
| Forgot password | ✓ | ✓ | ✓ | ✓ | empty submit → validation | B S V | — |
| Access denied, 404, NotFound | ✓ | ✓ | ✓ | ✓ | — | B V | — |
| Student: Dashboard, Opportunities (+exploreOpport redirect), OpportunityDetails, Apply, MyApplications, MyTasks, Progress, Profile, DisplayEditProfile, CV & Portfolio | ✓ | ✓ | ✓ | ✓ | phone drawer, workspace repaint on toggle | B S V | — |
| Account: Notifications, ChangePassword | ✓ | ✓ | ✓ | ✓ | — | B | — |
| Account: CompletionReport | — | — | — | — | — | Blocked | 404 for the fixture student (no completion record); source inspected only |
| Notifications Inbox (all roles) | ✓ | ✓ | ✓ | ✓ | notification panel open (both themes) | B S V | — |
| Meetings: MyMeetings, Schedule | ✓ | ✓ | ✓ | ✓ | error dialog | B V | Simulation has no meetings data ("Could not load meetings" dialog); list rows source inspected only |
| Company: Dashboard, Opportunities, ManageOpportunities, ViewOpportunity, Applications, Trainees, TraineeDetails, Tasks, TaskReview, Account | ✓ | ✓ | ✓ | ✓ | pinned sidebar, edit profile modal, surfaces suite | B S V | — |
| Company: FinalEvaluation, EvaluationReport | ✓ | ✓ | ✓ | ✓ | scores / feedback / drafts modals, official report + certificate (paper) | B S V | Certificate shows raw key `Company.FinalFooter.HaveMetTheHighestStandardsOf` (missing resource; not theme) |
| Company: ApplicantDocument | — | — | — | — | — | Blocked | 404 without an application id in the fixture; source inspected only |
| Academic: Dashboard, StudentProgress, FinalEvaluation, Account | ✓ | ✓ | ✓ | ✓ | workspace repaint on toggle | B S | — |
| Reports: Grades (academic, coordinator) | ✓ | ✓ | ✓ | ✓ | — | B | — |
| Coordinator: Dashboard, ManageStudents (Students/AddStudent redirect here), Companies, AcademicSupervisors, Groups, ConfiguredGroups, Placements, PlacementDetails, CompletionReview, ContactMessages, Account, DemoStudent | ✓ | ✓ | ✓ | ✓ | read-only postback (Companies › View) keeps Dark from first paint | B S | ConfiguredGroups header icon flagged by the audit (false positive: a mask glyph in the text colour) |

Lifecycle (`tests/theme-states.browser.js`, `tests/theme.browser.js`): Dark applied before the document is parsed (no
Light flash) on direct access, refresh, navigation, sign-in, full postback and language switch (RTL); sign-out keeps the
saved preference; six rapid toggles after a postback raise exactly six `uims:themechange` events (no duplicate handlers);
workspace charts/marks repaint on toggle without reload (they are styled by tokens); second tab follows; reduced motion
switches immediately; unsupported View Transitions still switch.

## Validation results

Final run (disposable host from `cd6a1ea` + working tree, campus-login simulation):

- Route audit: 528 page loads (66 routes × Light/Dark × EN/AR × 1440/390). No server errors, no page or console errors.
  The 10 non-200 loads per variant are the 404 pages (by design) and the two blocked routes above.
- Light: no AA text failures except the About objectives false positive (see matrix).
- Dark: no AA text failures and no unintended light surfaces; the remaining flags are the intentional items listed under
  "Intentionally light in Dark" and the two false positives (About objectives, ConfiguredGroups mask icon).
- `tests/theme-states.browser.js` 34/34, `tests/theme.browser.js` 18/18, `tests/theme-company-surfaces.browser.js` 30/30.

Re-run: start `tests/Start-LoginTestHost.ps1 -Port <port>` with the simulation on 4910, open a playwright-cli session on
`http://localhost:<port>/`, then `run-code --filename=tests/theme-audit.browser.js` (edit `THEMES/LANGS/WIDTHS` at the
top for other variants) and `tests/theme-states.browser.js`.

## Limitations

- Contrast is measured on rendered text against the composited CSS background. Text over photos, video, canvas or
  gradients is counted as "unknown" and was reviewed on screenshots instead (home/journey/login/Powered-by 3D scenes, About
  film, gold seal).
- Hover, focus rings, native date/file pickers, autofill and print output were checked in source (rules exist in
  `theme.css`: focus tokens, autofill inset, disabled/read-only fields, `.uims-paper` for print), not measured per page.
- Pages need fixture data to show populated states; empty states were verified, populated tables only where the fixture
  has rows (Company surfaces suite uses `?ui-fixture=1`).
- The login page is being reworked in a parallel session and teammates merged further work during the audit; both were
  verified in the state they had at the final run.
