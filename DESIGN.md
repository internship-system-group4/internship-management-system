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
