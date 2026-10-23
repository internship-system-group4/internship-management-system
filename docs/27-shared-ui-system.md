# Shared UIMS design and interaction system

Implemented 22 October 2026. No commit or push performed.

The approved GJU navy, pale blue workspace, white surfaces and Segoe UI remain the portal identity. All five masters load `ui-tokens.css` before page styles and `ui-system.css` after them, followed by `ui-system.js` after page scripts. Shared assets have a version query for cache invalidation. Root `DESIGN.md` and `.impeccable/design.json` describe the actual foundation.

## Foundation

| Meaning | Foreground / surface |
| --- | --- |
| Main action | `#264f73`, hover `#173f62`, soft `#e5efff` |
| Content | ink `#133d61`, supporting text `#526b80`, white panels, canvas `#f6f8ff` |
| Neutral | `#52606d` / `#f1f4f6` |
| Confirmed success | `#206044` / `#edf7f0` |
| Attention / pending | `#76500b` / `#fff5db` |
| Failure / destructive | `#a52c37` / `#fff0f1` |
| Information | `#245979` / `#edf5fb` |
| Field border / focus | `#7b8fa5` / `#a45220` |

Spacing is 4/8/12/16/24/32/48px; radii are 6px controls, 10px panels, 12px dialogs. Controls target 44px, compact controls 36px. Icons use one authored outline SVG language: 20/16px, 1.75 stroke. Existing Bootstrap icon names are mapped to these paths; sidebar outline artwork uses the same stroke treatment. Decorative icons are hidden from assistive technology.

| Action / state | Icon |
| --- | --- |
| Add / edit / save | Plus / pencil / check |
| Search / filter | Magnifier / funnel |
| Download / upload | Down / up arrow with tray |
| Delete / close / back | Trash / X / left arrow |
| Pending / approved / warning / information | Clock / circled check / triangle / circled information |

Semantic badges retain their server labels, with text and icons accompanying color. Workflow requirements remain distinct from final coordinator approval. The academic dashboard says “Hours requirement met,” because that count is not a completion approval.

## Behavior

Explicit mutation hooks preserve IDs, native submit names/values, LinkButton events, validation groups, ViewState, file uploads and existing confirmations. Busy controls retain their minimum dimensions, use an accurate spinner label and `aria-disabled`, and reject repeated activation without setting native `disabled` before submission. Full postbacks and `pageshow` restore the actionable state. Server responses remain authoritative: there is no timed fake success or invented progress. Login, recovery and Contact retain their existing public-form controller.

Failed ASP.NET validation produces a focusable linked summary and field associations. Native validity errors gain inline descriptions. Important failures remain visible and values are preserved by the existing server workflow. Successful notification clearing alone opts into the shared dismissible toast, after the actual write confirms; the original success banner is hidden to avoid duplication.

Bootstrap continues to own Bootstrap dialog containment and Escape. The page entrance uses backwards fill so a retained transform cannot trap a dialog below its backdrop. Existing tab handlers take precedence when they already prevent an arrow-key event; actual Bootstrap nav tabs gain associated roles and panels. Shared listeners associate titles and restore focus. The coordinator’s server-opened student dialog explicitly remembers its opening control across the full postback, storing only control ID, route and dialog ID in sessionStorage. Three custom dialogs are adapted through explicit hooks: Company Tasks, Student task details, and Company opportunity closing. Their existing close functions remain the authority; the adapter adds containment, inert background, Escape, focus return and internal scrolling.

Data tables scroll inside their own keyboard-focusable region. A visible hint appears when actual columns overflow. A single empty GridView cell fits its container and does not request pointless scrolling. Existing filters, paging, sorting and row commands remain in their original implementations.

Training progress uses approved hours and the applicable target. Reported/pending hours are excluded. Over-target hours remain numeric truth while the bar stops at 100%; a zero/missing target is explicit. Updates animate from a previously observed value rather than replaying from zero. No fake operation percentage is used.

## Motion and loading

Feedback 120ms; controls 180ms; dialog entrance 220ms, exit 160ms; page entrance 280ms; real progress change 550ms. Easing is `cubic-bezier(.2,.8,.2,1)`. Page content enters once per full navigation; navigation and postbacks are never delayed for an exit animation. Focus rings remain visible.

Reduced motion removes travel, compression, spinning and decorative pulses while keeping static busy/state information. Skeleton styles and `beginRegion`/`endRegion` are available for predictable real asynchronous content; current server-rendered pages do not pretend to fetch after loading. There are **zero UpdatePanels** in the current source inventory. The optional Microsoft AJAX adapter is idempotent but has no production partial-postback route on which to claim runtime verification.

## Actual 21st.dev references

A coherent OriginUI subset was inspected, including its example code, and adapted into Web Forms/plain JavaScript. The reference pages identify OriginUI’s MIT license. No React component source was copied into the runtime, and no React, TypeScript, Tailwind, shadcn or animation runtime dependency was introduced.

| Inspected reference | Adaptation |
| --- | --- |
| [Loading button](https://docs.21st.dev/@originui/components/button/loading-button) | Small local spinner, readable action state. Its disabled-button approach was adapted to preserve Web Forms submit events. |
| [Scrollable dialog with sticky header](https://preview.21st.dev/@originui/components/dialog/scrollable-sticky-header) | Bounded dialog height and internal body scrolling, with existing Bootstrap/custom ownership retained. |
| [Input examples](https://21st.dev/@originui/components/input) | Explicit field labels and associated helper/error text. |
| [Tabs](https://21st.dev/@originui/components/tabs) | Consistent list/trigger/content roles and arrow/Home/End behavior for existing tab lists. |

Progress, skeleton and toast source examples were inaccessible in this environment. Their local equivalents were implemented independently; they are not claimed as inspected or copied references. Dashboard/table/empty-state treatments were derived from the existing GJU portal and actual data, without inventing chart content or an external reference attribution.

## Deliberate exceptions and functional repairs

Home’s editorial/campus composition, Login’s gate scene, About/Contact scenes, PoweredBy’s lecture hall, existing video/Three.js behavior and their asset provenance remain owned by those pages. Shared controls and accessibility enhancements coexist with them. Existing reconstruction/fidelity limitations of the 3D scenes are not certified by this task.

Runtime route verification discovered three code-behind pairs present on disk but excluded from compilation: DisplayEditProfile, StudentCVPortfolio and ManageOpportunities. They are now included in the project. The obsolete student `exploreOpport.aspx` contained incompatible company creation markup; it is now a protected redirect to current Student Opportunities. Existing creation remains on Company Opportunities. This is recorded rather than counting a broken duplicate as a working page.

See [route/component coverage](26-ui-coverage.md) and [actual verification and visual evidence](28-ui-verification.md). Existing unrelated user changes were preserved.
