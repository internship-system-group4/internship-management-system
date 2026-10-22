# Resizable public navbar — 22 October 2026

Implemented the user-supplied `resizable-navbar.tsx` reference in the existing
ASP.NET Web Forms application. Its wide-to-floating scroll behavior, rounded
hover indicator and mobile dropdown are translated into dedicated CSS and plain
JavaScript. No React, Next.js, Tailwind, TypeScript, Motion, icon package or
`components/ui` directory was introduced; the task's Web Forms adaptation
requirements supersede the generic installation instructions in the reference.

## Shared implementation

Web project paths below are under
`InternshipManagementSystem/InternshipManagementSystem/`.

- `Layout/Public.master`: one existing semantic header/nav for Home, About,
  Contact, Login and password recovery. Keeps `publicNav`, menu button, server
  form/content placeholders and authentication properties. Uses the original
  GJU logo and compact UIMS/university identity. Adds the decorative moving
  highlight and loads dedicated navbar files after page-specific styles.
- `Assets/css/public-navbar.css`: scoped `.uims-public-nav` rules, full and
  compact states, dropdown, logical RTL spacing, reduced motion and opaque
  fallback when backdrop-filter is unsupported. Page/hero clearance rules are
  public-only; dashboard CSS is untouched.
- `Assets/js/public-navbar.js`: passive scroll listener, stable threshold,
  highlight on hover/focus, dropdown state/inertness, Escape/outside/selection
  close, breakpoint reset, anchor/history restoration, idempotent initialization
  and optional `Sys.Application.add_load` registration.
- `Layout/Public.master.cs`: rereads an existing authenticated user's profile
  through UserRepository before advertising its role dashboard; invalid,
  inactive or unverifiable cached sessions fall back to Log in. Anonymous public
  requests do not add an account lookup. Protected-page guards remain intact.
- `Assets/js/public-layout.js`: retains existing section enhancements; old menu
  listeners removed so one component owns navigation behavior.
- `Assets/js/home-experience.js`: delegates hash history to the shared
  header-aware navigator rather than competing with a second scroll correction.
- `Assets/js/home-story-scene.js`: existing callout placement now considers the
  navbar and tries nearby clear positions before hiding labels behind copy.
  This repaired a real compatibility regression introduced by the larger title
  clearance. Campus geometry, occlusion rays, camera poses and animation loop
  remain unchanged.
- `Assets/js/home-story.js`, `Default.aspx`: update script cache versions for
  that compatibility fix and history integration.
- `InternshipManagementSystem.csproj`: deploy the new CSS/JS.
- Repository-root `tests/public-navbar.browser.js`, `DESIGN.md`, and this report.

Existing dirty Home/public/sidebar work was preserved. Private Master Pages and
sidebar assets were not modified in this navbar task.

## Geometry and behavior

The expanded bar is centered at up to 1280px. The compact width is 1000px, chosen
from the actual university identity, five links and the longer dashboard action.
Desktop begins above 1120px so that content never relies on the reference's
unconditional 800px minimum or 40% width. Mobile keeps 12–20px side margins,
including at 320px. Compact top offset is 20px. Width/position transitions take
260ms; hover highlight 200ms; dropdown opacity/translation 180ms.

Initial compact state reads the actual scroll position using 100px. Later entry
uses 112px and exit 88px to avoid flicker. Above 8px, even the still-wide bar gains
a readable white surface before page content moves behind its labels. At the
very top it is transparent. The compact bar adds a 90% white surface, 10px blur,
subtle border and soft overlay shadow. An opaque white declaration precedes the
supports query. Header position is fixed outside transformed/sticky story nodes;
changing its width or translation does not change document flow.

The approved navy/Segoe UI remain on inner pages; Home keeps its existing Switzer
scope. The original colored university PNG uses auto height. The compact UIMS
identity replaces the reference's Startup image/text. Native inline SVG provides
menu/close icons; decorative movement is disabled with reduced motion.

Routes are server-generated with ResolveUrl:

| Label | Destination |
| --- | --- |
| Logo / Home | `~/Default.aspx` |
| About us | `~/Pages/Public/About.aspx` |
| Opportunities | `~/Default.aspx#opportunities` — actual public summaries |
| How it works | `~/Default.aspx#how-it-works` — actual story chapter |
| Contact us | `~/Pages/Public/Contact.aspx` |
| Log in | existing Login route |
| My dashboard | reread profile's existing DashboardUrl |

No signup, pricing, book-a-call or placeholder link was added. Existing public
navigation had no logout control, so none was invented. Private logout is intact.
Exact page matches receive aria-current; temporary hover/focus feedback does not
replace that state. Section links preserve Home as the current page.

For an active story timeline, chapter links map to the actual ScrollTrigger
start/end range. Normal-flow, reduced-motion and fallback anchors use the target
position with 112px clearance. Direct hash loads and history restore are corrected
after layout changes; manual pointer/wheel/touch/key interaction cancels a pending
correction so resizing does not pull the reader back unexpectedly.

The mobile menu is a dropdown, not a modal: no focus trap, no background inertness
or forced scroll lock. Closed links are inert and aria-hidden. Escape returns
focus to the toggle. Outside click, destination selection and switching to desktop
close/reset it. The panel has bounded height and independent vertical scrolling.
Without initialization/JavaScript, essential links remain in normal flow on phones.

## Verification and evidence

Actual .NET Framework application built in Debug with Visual Studio MSBuild:
exit 0. JavaScript syntax checks and git diff whitespace checks passed.

Test target: disposable IIS Express copy at `http://localhost:57983`, with the
repository's existing Postman Firebase stand-in on port 4903. Only local fixture
accounts/data were used. Fixture sign-in is present only in that disposable copy;
real protected requests still pass the repository role/profile guards.

**259 passing assertions**: 154 navbar, 32 public requirements, 56 campus and
17 Home navigation/history checks. Browser results are recorded in:

- `tests/artifacts/public-navbar-tests.txt`: navbar, role/session routing,
  exact links/active states, top/compact/return/restored-scroll states, threshold
  hysteresis, no document shifts, visible/clear landmark actions, Home chapter
  and normal anchors, Back/Forward, manual correction cancellation, keyboard
  highlight, Escape/outside click/Tab flow, compact dropdown, short-screen scroll,
  RTL, reduced motion, no-JS fallback, form validation and repeated initialization.
- `tests/artifacts/navbar-public-regression.txt`: existing public requirements,
  preview privacy/filtering, protected redirects, role refresh/deactivation,
  password-change gate and successful Contact postback against the stand-in.
- `tests/artifacts/navbar-campus-regression.txt`: existing complete campus checks,
  including all chapters, hotspots/collisions, keyboard college interaction,
  camera, one canvas/timeline, reduced motion, fallback, disposal and authorization.
- `tests/artifacts/navbar-history-regression.txt`: existing Home design/navigation
  checks including keyboard chapter navigation and browser Back/Forward.

Viewport coverage includes 320, 390, 768, 960, 1120, 1121, 1200, 1440 and 1920px,
plus a 300px-high phone stress case. No horizontal overflow or desktop navigation
item overlap was observed. Login/recovery server control IDs and handlers remain
unchanged; existing public form validation and the Contact save path were exercised.

Screenshots reviewed include `navbar-home-wide.png`, `navbar-home-compact.png`,
`navbar-mobile-open-{width}.png`, `navbar-mobile-compact.png`, and
`navbar-mobile-rtl.png`. App/browser console errors: zero in passing suites.

The source lint has no unresolved findings. Scoped taste-skill comments document
border/blur/shadow exceptions explicitly requested for the floating bar/dropdown.
The existing Home editorial direction is retained; this is a reference component
adaptation, not a new page direction or a new typography/palette draw.

The whole-About page inspector also ran at 1440/768/390px and its screenshots were
reviewed. `tests/artifacts/navbar-final-inspect.json` reports four existing page
style failures (role-list dividers, one content photograph, hero dominance and
whole-page motion quantity) and three warnings (body grey, no video and a small
identity label). These concern the retained About content/page style or the compact
identity metadata. They are not reported as a clean whole-page redesign audit;
adding pictures/video or redesigning About was outside this navbar adaptation.
Navbar appearance, both scroll states and dropdown were reviewed directly.

No UpdatePanel exists in the project, so real partial-postback behavior was not
claimed; repeated initialization was tested. Role/session routing uses modeled
Firebase REST profiles and authorized fixture sessions, not real Firebase password
sign-in or reset-email delivery. A separate virtual-application IIS runtime check
was not run; server URLs are application-relative. The prior additional-host test
was blocked by automatic review. There are no missing navbar routes or assets.

`tests/navbar-probe.browser.js` is retained as a diagnostic projection probe.
Automatic review rejected the final cleanup batch that included deleting this
file (`blocked by policy`, no detailed reason supplied). No deletion was retried;
the probe is not deployed or referenced by the application.
