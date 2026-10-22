---
name: GJU Internship Management System
description: Approved blue, white and gray university workspaces, larger Noto typography and interactive data charts.
colors:
  primary: "#264f73"
  primary-hover: "#173f62"
  primary-soft: "#e5efff"
  ink: "#133d61"
  muted: "#50657a"
  surface: "#fff"
  canvas: "#f6f8ff"
  nav: "#f5f5f5"
  nav-text: "#42474b"
  nav-muted: "#565f69"
  accent: "#c8a349"
  neutral: "#52616a"
  neutral-soft: "#f0f3f7"
  border: "#e4ebf4"
  control-border: "#7b8b9e"
  success: "#206044"
  success-soft: "#edf7f0"
  warning: "#76500b"
  warning-soft: "#fff5db"
  danger: "#a52c37"
  danger-soft: "#fff0f1"
  info: "#245979"
  info-soft: "#edf5fb"
  focus: "#315e8d"
  chart-blue: "#315e8d"
  chart-teal: "#087f8c"
  chart-amber: "#b77912"
  chart-green: "#258361"
  chart-purple: "#7955a3"
  chart-red: "#bc4b55"
typography:
  title:
    fontFamily: "\"Noto Sans\",\"Noto Sans Arabic\",Arial,sans-serif"
    fontSize: "clamp(2.125rem,2.8vw,2.75rem)"
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: "-.035em"
  body:
    fontFamily: "\"Noto Sans\",\"Noto Sans Arabic\",Arial,sans-serif"
    fontSize: "1.125rem"
    fontWeight: 400
    lineHeight: 1.6
  field:
    fontFamily: "\"Noto Sans\",\"Noto Sans Arabic\",Arial,sans-serif"
    fontSize: "1.125rem"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "\"Noto Sans\",\"Noto Sans Arabic\",Arial,sans-serif"
    fontSize: ".9375rem"
    fontWeight: 600
    lineHeight: 1.4
rounded:
  radius: "8px"
  radius-panel: "12px"
  radius-dialog: "16px"
  radius-analytics-kpi: "14px"
  radius-analytics-card: "18px"
spacing:
  space-1: "4px"
  space-2: "8px"
  space-3: "12px"
  space-4: "16px"
  space-5: "24px"
  space-6: "32px"
  space-7: "48px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.surface}"
    rounded: "{rounded.radius}"
    height: "48px"
  button-primary-hover:
    backgroundColor: "{colors.primary-hover}"
    textColor: "{colors.surface}"
    rounded: "{rounded.radius}"
  button-secondary:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.primary}"
    rounded: "{rounded.radius}"
  button-danger:
    backgroundColor: "{colors.danger}"
    textColor: "{colors.surface}"
    rounded: "{rounded.radius}"
  field:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.radius}"
    padding: "10px 12px"
    height: "48px"
  status-success:
    backgroundColor: "{colors.success-soft}"
    textColor: "{colors.success}"
    rounded: "{rounded.radius}"
    padding: "4px 9px"
  analytics-kpi:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.radius-analytics-kpi}"
    padding: "18px 20px"
  analytics-card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.radius-analytics-card}"
    padding: "22px"
  journey-stage:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.radius}"
---
# Design System: GJU Internship Management System

## Overview

**Creative North Star: "The university workspace: clear information, real decisions"**

The university workspace restores the approved blue, white and light gray identity. Locally served Noto Sans and Noto Sans Arabic unify interface typography with larger body text, controls and tables. Flat work areas and interactive, directly labeled charts make each role’s principal information easier to read and explore.

The four dashboards have distinct working compositions. Other authenticated pages inherit the shared shell, typography, controls and feedback; this does not mean every work page has been recomposed. Home, About, Contact, Login and Powered by retain their existing public scenes, photographs, video and footer concepts, with shared type and control refinement.

**Key Characteristics:**

- Pale blue canvas, light gray navigation, navy type and white work surfaces.
- Distinct role work areas, interactive charts and a server-backed journey.
- Real counts, permission-bound actions and server-confirmed feedback.

Authority: `Assets/css/ui-tokens.css`, `portal-layout.css`, `ui-system.css`, `workspace.css`, `interface.css`, `reference-analytics.css`, `Assets/js/ui-system.js`, `workspace.js` and `workspace-charts.js` in the web project. All five masters load the foundation and shared workspace assets; shared system and workspace CSS follow page styles. Dashboard analytics follow `.impeccable/briefs/reference-analytics.md`; the preceding shared workspace contract remains `.impeccable/briefs/chart-workspace.md`. Tokens describe the current replacement world; the collapsed public record below preserves historical evidence without overriding them.

## Colors

### Primary

University blue identifies primary actions and current journey stages. The pale blue selection surface supports selected tabs, chart bars and secondary hover. Deep blue anchors the student’s approved-hours panel. Gold appears sparingly on the actual approved-hours bar; it is a university accent, not a success status.

### Neutral

The approved pale blue canvas frames white work areas. Ink carries headings and principal text; muted carries readable supporting information. Neutral-soft distinguishes read-only fields and table headers. Quiet borders separate work areas, while control-border makes editable boundaries visible. Navigation uses dark text and muted text tokens against light gray.

### Semantic feedback

Success, warning, danger and information each retain an ink/soft pair. The dedicated focus token marks keyboard focus. Color always accompanies a meaningful label or icon.

**The Server Authority Rule.** Success, progress and workflow completion come from real server results. Activation, a spinner or an animation never establishes success.

## Typography

Noto Sans and Noto Sans Arabic variable fonts (100–900) are self-hosted under the SIL Open Font License. The shared font stack is used for headings, body text, fields, buttons, labels and public interface text. Arabic glyph support does not imply a translated Arabic interface. `Assets/fonts/README.md` records provenance and licenses. Existing Switzer assets remain available for historical assets; they are no longer the working UI type family.

Body text and editable controls use 18px with a generous 1.6–1.65 line height. Table cells and headers use 17px; field labels use 17px; supporting text and metadata generally use 15–16px. Sidebar links are 16px, while compact account metadata remains 14px. General workspace headings use 34–44px and 34px on phones; sections use 24–27px. The four reference-adapted dashboards have a scoped hierarchy: page titles 36px (32px below 600px), analytics section title 24px, chart titles 20px (19px on phones), KPI values 36px (32px on phones), interface context 16px and supporting chart labels 13–14px. Chart data tables retain 14px text and record-modal titles use 26px. Existing public editorial headline geometry is preserved while its HTML type family changes.

**The Consistent Reading Rule.** Shared interface typography deliberately overrides legacy per-page font families. Keep physical 3D signage, original logos and text embedded in images intact; they are brand assets rather than interface text.

## Layout

Use the seven-step spacing scale. Authenticated content has a 1560px outer maximum and 36px desktop gutters; dashboards have a 1440px maximum. Gutters reduce to 24px below 1100px and 18px below 600px. On the four role dashboards, the compact heading leads to the server-backed journey, then reference analytics and the real work area. Analytics presents four KPI buttons, two equal chart columns and a full-width donut card underneath. The former repeated metric band is hidden with its server controls retained; the student hours panel keeps its real progress and pending-hour actions while its duplicate giant count is suppressed.

The student dashboard pairs next tasks with approved hours, then application history. Company pairs the applications table with its review desk and trainee list. Academic pairs assigned-student oversight with assessment follow-up. Coordinator pairs the completion queue with assignments and exception totals. These are the four recomposed surfaces; legacy work pages keep their functional structures.

Navigation is a light gray 264px panel, initially pinned when no preference exists. An explicit unpin permits a 76px rail with pointer/keyboard expansion. The stored pin preference remains authoritative. At 900px and below, a drawer up to 360px wide leaves a 28px viewport margin and retains its focus trap, inert background and Escape handling. Public navigation keeps its separate 1120px collapse point.

Below 760px, major legacy work columns stack. Reference analytics has its own 1000px breakpoint: the primary charts stack and four KPIs become two columns. At 1200px the donut explanation moves below its chart and legend; below 600px the donut, legend and explanation stack, card padding reduces to 18px 16px and sparklines are hidden. Journey stages use a local horizontal scroller with visible guidance and the current stage initially centered; the shared stage width is 160px, reduced to 142px on reference dashboards below 600px. Wide tables stay inside keyboard-accessible, labeled local scroll regions; do not force the entire page wider than the viewport. Preserve native navigation, history and the public scene layout.

## Elevation & Depth

Working panels stay flat, using borders and surface contrast. Dialogs and toasts use the elevation token (`0 22px 70px rgb(11 36 51 / 20%)`). Preserve the existing public floating navigation depth and scene materials as contextual exceptions. Layer tokens reserve navigation at 1100, modals at 1200 and toasts at 1300; the Bootstrap backdrop uses 1190.

## Shapes

Controls and statuses use 8px corners, general work panels 12px and dialogs 16px. Scoped reference analytics uses 14px KPI corners, 18px chart-card corners and 4px bar caps. Shared buttons and editable controls have a 48px minimum height; public actions use 50px. Compact file-selector buttons and pagination use 40px targets; checkboxes/radios remain 18px, while dedicated close/menu buttons retain their 44px targets. Avoid claiming every control shares one dimension.

## Components

### Buttons and asynchronous actions

Primary, secondary and danger actions use the unified Noto family and larger interface text (18px in portal working areas), with 600 weight. Portal action padding is 10px 17px. Hover changes color without travel; press scales to .985 (public actions to .975). Disabled and aria-disabled actions use .65 opacity. Visible focus uses a 3px outline with 3px offset.

Explicit `data-ui-action` hooks reserve space for their loading label and spinner, then lock measured width and minimum height while pending. They announce the wait and mark the local region busy. Duplicate hooked activation is blocked. Input submits use a wrapper spinner. Use aria-disabled while pending so native Web Forms submit names and events are preserved. Navigation and postbacks remain immediate; no artificial delay declares success. Partial completion and pageshow restore action state. A matching visible server success notice can briefly confirm the same user's same-route action; a timer only restores its original label afterward.

### Fields and validation

White editable surfaces use control-border, 10px 12px padding and larger field typography. Focus changes the boundary to primary. Read-only fields use neutral-soft. Preserve native upload, autocomplete, keyboard and browser validation behavior.

Failed Web Forms validators associate errors with fields, set aria-invalid and provide a linked summary. Native portal invalid events add associated inline feedback; typing clears that native field error state. These additions preserve server validation and do not imply identical legacy markup.

### Icons and statuses

Inline 24-unit outline SVGs use rounded caps/joins, no fill and a 1.75 stroke. Default icons are 21px, compact icons 17px and status glyphs 15px; sidebar icons remain 22px. Decorative SVGs are aria-hidden; icon-only buttons need accessible names. Recognized legacy icon names and route destinations map to authored paths without an icon-font dependency. Brand and scene artwork remains intact.

Status labels remain server-owned. Pending and awaiting approval use warning; submitted and under review use information; approved, accepted, confirmed, completed and graded use success; rejected uses danger. Assigned, resubmitted and the recognized completion-review queue states have explicit mappings. Unknown labels are not guessed. Never replace readable status text with color alone.

### Panels, tables and navigation

Flat panels contain meaningful work. Legacy metric bands use separators; the four reference dashboard KPIs use the dedicated bordered card composition. Summary numbers link only when there is a real destination. Tables retain real sorting, filtering, pagination and permission checks. Active tabs use primary-soft; existing tablists gain ArrowLeft, ArrowRight, Home and End behavior through idempotent listeners.

### Reference analytics

The shared Web Forms control adapts the supplied Layro `revenue-charts-kpi.tsx` and `demo.tsx` composition using native SVG, C# authorized read models and plain JavaScript. It adds no React, Tailwind, chart runtime, API endpoint or per-chart network request. Four KPI buttons lead two chart cards (dated area activity and current-category bars); a full-width mutually exclusive donut follows. White surfaces use quiet borders rather than lifted shadows. Journey and work actions retain their functional priority above and below analytics respectively.

Area strokes are 2px with a 14%-to-2% vertical wash and horizontal hairline grid. Bars are at most 24px wide with 4px corners and direct numeric labels. The donut uses 54px inner and 80px outer radii, white 2px slice boundaries and a total in its center. Zero totals show a neutral ring and an em dash for shares; tiny nonzero shares display `<1%`. Category tones retain semantic identities: active/primary, review/information, approved/success, pending/warning, rejected/danger and neutral. Color accompanies labels and values; it never becomes the sole category key.

Student analytics covers applications, pending decisions, dated approved hours and actionable tasks; its bars show task status and its donut shows application decisions. Company analytics covers active trainees, pending applications, submitted work and pending reported hours; independent review-queue bars are item counts, explicitly overlapping rather than a part-to-whole total. Academic analytics covers assigned students, active training, assessments due and dated approved hours, with exclusive progress bars and assessment-stage donut. Coordinator analytics covers students, unassigned active placements, ready final reviews and dated explicit completion approvals, with college bars and exclusive completion stages. Student payloads exclude confidential company and academic final evaluations.

The 6/12-month radio group filters actual approval events from a calendar-month start through the current UTC instant. Approved positive hours use valid `ReviewedAt`; explicit completion approvals use valid `ApprovedAt`. Only actual recorded month buckets appear and their x positions follow date spacing. Current retained records are not historical status snapshots. Snapshot KPIs, bar categories and donut totals remain unchanged by range selection. Previous-window comparisons use equal elapsed duration and require a positive dated denominator; absence of a valid denominator never creates a percentage. Undated, invalid or future approvals are excluded from ranges and remain inspectable. Unavailable history is an em dash, known zero is 0, one month is one point without inferred history, and sparklines require at least two actual month buckets.

Selecting a KPI, category, donut segment or dated point opens a centered record dialog with actual authorized records, safe local links and ten records per page. Bootstrap owns modal focus containment and dismissal; Escape restores the opener and retains the selected range. Full category names remain in legends, tooltips and data tables. Native View data disclosures, table record buttons and legend buttons provide keyboard alternatives to pointer marks. Range radios support arrows, Home and End. Tooltips are clamped inside the viewport; generated record content uses text nodes and embedded JSON escapes HTML.

SVG dimensions follow measured panel width without shrinking type. Bar-axis labels are measured at 13px in the actual interface family, shortened with defined aliases only when needed, and rotated when they still exceed a category cell; full names remain available nearby. Wide data tables scroll locally. Initialization and redraw are idempotent; resizing preserves range and does not replay chart entrances. At reduced motion, all final values and states remain visible without travel or reveal.

### Interactive journey

The shared server-rendered journey reads each role's real records. Student stages cover application, placement, training, evaluation and completion. Final completion appears only after coordinator approval; confidential company and academic final evaluation contents never enter student dialog templates. Company and academic stages represent their own queues, and coordinator stages expose individual decisions and assignments, without a fabricated cohort completion percentage.

Each stage is a keyboard-focusable button. Selecting it moves the anchored marker and connector (360ms), then opens a centered contextual dialog with encoded facts and actual permission-bound destinations. The selected marker is presentation state; it does not rewrite workflow status. Resize handling keeps the marker anchored and mobile scrolling exposes the current stage. Escape dismisses and focus returns to the opener.

### Dialogs and drawers

Bootstrap owns Bootstrap modal semantics, focus containment and dismissal. Shared workspace initialization centers dialogs; ordinary dialogs have a 760px maximum, while existing large dialogs can reach 920px. Bodies scroll internally within viewport-bounded surfaces; journey headers and actions remain outside the scrolling body. Journey dialog titles retain their contextual 32px desktop and 28px mobile scale.

Portal dialogs enter over 300ms from 20px below at scale(.97) and exit over 200ms. Explicit custom `data-ui-dialog` panels receive dialog semantics, Tab containment, inert siblings, Escape/backdrop closing through their declared callback and opener restoration. Their close callback waits 200ms for the exit. Preserve operation-specific unsaved-change handling and the separate public dropdown/sidebar implementations.

### Progress and feedback

`data-ui-progress` uses server-emitted approved hours and requirement. The visual bar is clamped to 0–100%; aria-valuetext preserves actual counts, including over-target values. Nonpositive or missing targets show an explicit note. Previous approved-hour percentages persist per user, route and element for real changes across navigation, rather than repeatedly animating from zero.

Important errors remain inline alerts. Visible actual success notices receive status semantics and a brief check drawing. Existing rows receive a 1400ms background highlight only when their saved status differs from the same user's prior observed status. Explicit noncritical toast hooks create dismissible notifications without an automatic disappearance timer. Skeletons only pulse inside an actual busy region; shared helpers do not fabricate fetched data.

### Motion and partial updates

Shared timings are 120ms press feedback, 200ms control changes, 300ms dialog entry, 200ms exit and 600ms real progress changes, with `cubic-bezier(.16,1,.3,1)` easing. Shared workspace entrances last 460ms with a 16px rise. The reference dashboards keep the journey above analytics. Their KPI cards enter over 450ms with 55ms increments, primary cards over 500ms after 120ms and the donut card over 500ms after 180ms. Charts reveal over 620ms and the anchored range indicator moves over 340ms; changing the range updates only dated activity and flow KPIs, without replaying snapshot charts. These are section entrances, not a permanent transform on the entire main-content ancestor. Journey marker movement lasts 360ms; confirmed checks enter over 380ms and draw over 450ms.

Reduced motion sets shared timings to zero and removes entrance, marker travel, row/check animation, dialog travel, press travel, spinner rotation and skeleton pulsing while keeping the final state readable. Public scenes retain their pause/static fallbacks.

`UimsUI.refresh()` and workspace refresh initialize idempotently after relevant partial postbacks and pageshow. Preserve ClientID behavior, naming containers, ValidationGroup, CausesValidation, LinkButton postbacks, file uploads, ViewState, event validation, Firebase schemas and server access checks. Keep one server form per page.

## Do's and Don'ts

### Do:

- Do use the shared CSS tokens and master-page assets.
- Do preserve server control IDs, names, naming containers, validation groups and postbacks.
- Do derive progress from real approved hours and the applicable requirement.
- Do preserve the original logo, licensed fonts, factual asset provenance and public scene fallbacks.
- Do pair semantic color with readable labels and meaningful icons.

### Don't:

- Don't invent percentages, successful outcomes, campus facts or final completion.
- Don't expose confidential final evaluation content in the student journey.
- Don't disable a submit control before Web Forms receives its name and event.
- Don't delay navigation or postbacks solely to finish an animation.
- Don't spread Home camera motion or decorative scenes into task dashboards.
- Don't describe shared CSS refinement as a full recomposition of every work page.

### Public identity and provenance record

Home retains its architectural editorial composition and procedural campus story; Login retains the university-gate experience; About, Contact and Powered by retain their established concepts. Shared typography and actions refine those surfaces without replacing their 3D scenes, video behavior or footer structure. Procedural campus geography remains artistic rather than a verified campus map. The original university logo is not redrawn. Existing photograph, texture and video provenance remains in the public implementation records and the historical evidence below; no new raster asset was introduced for these workspace changes.

The collapsed record below is historical evidence, including superseded type, palette, navigation measurements and compositions. It must not be used to revert the current system above. The latest explicit Home direction in that record governs its preserved scene; older Home concepts explain provenance only. Its historical Switzer interface typography is superseded by the current Noto system, while physical university signage and original brand assets remain intact.

<details>
<summary>Existing approved theme and Home/public implementation record</summary>

# Approved UIMS visual theme



## Current Home direction — 22 October 2026



The user explicitly authorized a broader Home redesign beyond the earlier

composition. Home now follows an architectural editorial direction: oversized

two-line Switzer title, one expansive continuous campus scene, neutral daylight

ground `#f1f3f2`, navy university ink, named chapter navigation and large real

courtyard photography. The normal-flow opportunity section is a navy field;

the closing login section is full width. See `docs/18-home-editorial-redesign.md`.

This Home direction supersedes the older Home composition notes below. The

shared university identity and all authenticated portal styling remain as defined.



The latest design-taste refinement removes visible chapter numbering and the

two-color headline, consolidates Home to five type roles, and adds the actual

wheel/Gate 1/glazed-connector photographic folio. Body copy uses the university

ink at 16px. Public previews use editorial rows. See `docs/19-home-taste-review.md`

for the three visual-review rounds, zero-FAIL final inspection and asset limits.



Osama supplied student-portal screenshots on 2026-10-21 as the visual authority

for O01 and future requested pages. Match this theme rather than inventing a

new visual direction.



- Neutral `#f5f5f5` sidebar and white top bar; very pale blue content background `#f6f8ff`.

- Primary buttons: `#264f73`; hover `#173f62`. Active sidebar links use navy ink on a quiet `#e3e8ec` surface.

- Heading/text ink `#133d61`; secondary text `#58718a`.

- Quiet borders `#e4ebf4`; light blue badges `#e5efff`.

- Segoe UI/system sans typography. Small outline navigation icons.

- White form surfaces, 5–7px corners, no decorative shadows or gradients.

- GJU mark with university name, product name and Student role label.

- Top bar breadcrumb, authenticated user's real name and initials.

- Responsive stacked form with readable controls and no horizontal overflow.



All four role masters use `Layout/Sidebar.ascx` as the shared brand, navigation,

pin and account component. The original `btnSignOut` remains in each master with

its original ID, event handler and naming container. Exact active-route aliases

live in the user control; permitted menus come from the server-verified session

role. Shared CSS and behavior live in `Assets/css/portal-layout.css` and

`Assets/js/portal-layout.js`. Existing page content and form controls stay in their

original content placeholders. Meetings still select the verified role's master.



O01's form-only styles remain in `Assets/css/apply-theme.css`. Its script only

updates the cover-letter character counter; it does not construct the shell.



The GJU logo is the original downloaded PNG from the university website:

https://gju.edu.jo/sites/all/themes/bootstrap/images/GJU-LOGO2.png

Local asset: `Assets/images/gju-logo.png` within the web project. It has not been

redrawn or generated. Original screenshots guide visual styling only; example

people, hours, dates and company names are not product facts.



At widths above 900px, navigation begins as a 60px rail and expands to 300px

on pointer hover or keyboard focus, or while pinned. Only the pin preference is

stored locally. Content resizes alongside it. At 900px and below, one compact

menu button opens the same panel full-screen with an RTL-aware transition,

focus trapping, Escape/selection close, background inertness and scroll locking.

Without JavaScript, the expanded navigation remains available in normal flow.

See `docs/20-shared-sidebar.md` for reference adaptation and verification limits.



Public.master provides the shared resizable public navbar and footer. The fixed

navbar sits outside the campus story, expands to at most 1280px at the top, and

contracts to 1000px with a translucent floating surface after about 100px.

It uses a 1120px mobile breakpoint chosen for the actual logo/link/action widths.

The mobile navigation is a nonmodal dropdown with inert hidden links, Escape,

outside-click close and no focus trap. Home section links use the real public

opportunity previews and the current story timeline, with header-aware history

restoration. Dashboard actions reverify the cached user's profile on the server.

See `docs/21-public-resizable-navbar.md`; private portal navigation is separate.

The footer retains its three flat columns, university identity and support links.



O03 shows a white, green-outlined confirmed-placement summary above the student's

application list. Accepted offers offer an explicit one-internship acknowledgement

and Confirm offer action until a placement exists. Other offers then lose their

confirmation actions while their application statuses remain visible.



O06–O08 reuse Coordinator.master. The dashboard uses six flat metrics and a recent

placements table; monitoring uses labeled search/status controls and ten rows per

page. Detail panels keep task attempts, grading, hours and completion visibly

separate. Narrow screens stack panels and keep wide tables in their own horizontal

scroll areas. Page-specific styling lives in coordinator-monitoring.css.



Public pages follow a restrained editorial direction: clear navy headings, real

campus photographs, white backgrounds, pale blue sections and consistent column

alignment. The current implementation supersedes the initial small-type mockup.

Home keeps a split campus hero, the ordered internship process, two real study

programs, support information and a closing login action. Illustrative vacancy

cards were removed. Curated summaries now use a dedicated public projection; full

details and applications remain behind the existing protected routes.



Public typography: 16px body at 1.65 line height, 17–18px lead, 13–15px supporting

text, 20–24px subheadings, 28–40px section headings and up to 68px for Home's title.

Headlines use balanced wrapping; no decorative labels, statistics or testimonials.

Maximum public width is 1200px; gutters are 40px desktop, 24px tablet and 16px phone.

Sections use roughly 80px separation, reducing to 52–56px on phones. Form and photo

corners remain compact at 5–6px. No decorative shadows or gradients are introduced.



Input boundaries use #7b8fa5 for non-text contrast. Focus uses a visible #a45220

outline. Shared form labels, associated inline errors, password visibility state,

status alerts and native keyboard-accessible disclosures are part of the system.

Public navigation collapses at 960px; role-portal navigation keeps its own rules.

Motion is limited to short image entrances, one-time section reveals, preview/button

feedback and mobile-menu entrances; reduced-motion users receive static content.

Content is visible without JavaScript.



The current interface is English. Arabic name/message input uses dir=auto and the

public layouts use logical spacing and RTL overrides. Do not claim an Arabic UI

translation or add a language selector without translated content. Public styles

remain scoped to .uims-public and do not restyle role portals. The protected

ChangePassword page retains its own implementation and inherits the shared shell.



Image provenance is retained in docs/12-homepage.md. Implementation and verification

are documented in docs/13-public-redesign.md.



The homepage renders college/program/track names from shared project configuration,

not a parallel marketing list. Public opportunity summaries are server-filtered,

encoded and separated from private opportunity records. A process-video section

uses native controls when the actual local MP4 exists; until it is supplied, an

explicit development placeholder links to the readable steps. Contact progress

and duplicate-action blocking are announced without losing the Web Forms submit

button name. See docs/14-public-pages-requirements.md for missing assets, publication

configuration, verified sources and authentication test limits.



Home's hero now uses a contained procedural courtyard waterwheel beside the existing

HTML headline/actions. Preserve its limestone, dark timber and muted blue water;

do not spread the 3D runtime or styling to other pages. Keep the supplied courtyard

photo as fallback, an accessible pause control, and a static reduced-motion view.

The reconstruction is approximate; see docs/15-home-courtyard.md for evidence and limits.



The current Home supersedes that waterwheel composition with a Jordan/Germany

flag-to-Gate-1 story. Keep the university logo and readable navy HTML, native

scrolling and a concise two-chapter sticky visual. GSAP ScrollTrigger moves only

the camera; continuous cloth motion is independently pausable. Compact screens

and reduced motion use an overview. Native college disclosure, internship steps,

stable video and public summaries follow. One configured college uses a restrained

navy computing symbol. See docs/16-home-scroll-story.md for references and limits.



Home now uses a full-viewport architectural miniature as the entire hero environment, superseding the contained flag-to-gate visual. One sticky canvas accompanies five HTML chapters with native scroll/GSAP camera transitions. Stone, restrained planting, daylight and approved navy branding remain. Mobile reframes the same world; reduced motion and renderer failure restore normal flow. Gate/courtyard adjacency is artistic, never a campus map. See docs/17-home-campus-experience.md.



Home refinement (2026-10-22): closer camera framing; photograph-derived limestone maps; recessed and framed glazing; detailed instanced foliage, paved paths and subtle normal-mapped water. Keep original branding, natural scroll, static fallbacks and mobile quality caps. Do not claim a photographic scan or verified map.


</details>
