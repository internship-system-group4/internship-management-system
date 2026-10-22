# UIMS workspace redesign

23 October 2026. Implements the substantial four-role redesign brief attached as `a3ffcb36-ab82-41e0-aded-1b6429683e42/Pasted text.txt`. Supersedes the visual foundation described in docs26–28; their historical test results are not evidence for this revision.

## Implemented scope

The four dashboards have new compositions, not just new colors. Student prioritizes tasks and a navy approved-hours panel; Company pairs the applicant table with a review desk and trainees; Academic pairs assigned-student progress with evaluation follow-up; Coordinator pairs individual completion decisions with assignments and training exceptions. A shared separator metric band replaces repeated count cards. All four start with real, server-rendered journey buttons.

Warm ivory `#f4f1e9`, navy navigation `#132f43`, white working surfaces and restrained gold `#c0a261` carry the university identity. Locally licensed Switzer assets already in the repository supply headings; Segoe UI/system fonts supply interface text. Titles32–40px, section headings21–23px, body/controls16px, tables15–16px and state captions13px establish the hierarchy. Focal hours/assignment figures deliberately exceed the normal36–40px count scale.

Five master layouts load the same tokens, controls and interaction code. Navigation uses legible labels, consistent outline SVG icons, persistent pinning and an accessible mobile drawer. Work pages inherit the shell, typography, controls, semantic statuses and contextual dialog treatment; they are not claimed as individually recomposed. The Opportunities inverse heading and CompletionReview column widths were corrected during independent review.

Home's campus scene, About's video/scroll narrative, Contact's form/disclosures, Login's university gate, PoweredBy's lecture hall and the compact footer map remain their distinct experiences. No new raster asset was introduced. Existing font licensing and public image/model provenance remain in `Assets/fonts/README.md` and the historical public context retained in `DESIGN.md`.

## Server data and permissions

`WorkspaceDashboardRepository` is a presentation read model over existing repositories. It adds no Firebase schema or write endpoint. Student hours sum the student's approved entries and separate pending hours; missing targets remain explicit, and over-target bars stop at100% while keeping the actual number. Student completion requires an approved coordinator record. Company and Academic journeys clearly describe review queues across authorized trainees/students, without invented cohort completion percentages. No confidential final-assessment text is sent to Student dashboards.

The existing Academic FinalEvaluation handler now rechecks assigned-student and canonical-placement ownership before reading private company feedback or accepting a submitted hidden student ID, and refuses repeat submissions already finalized. Coordinator/Company account success markup explicitly identifies confirmed writes for checkmark feedback; cancellation and failure do not receive that marker. Existing server IDs, event handlers, postbacks, uploads, validation and Firebase contracts remain.

## Interaction system

`WorkspaceJourney.ascx` emits encoded stage templates and permitted links. Real buttons move a360ms selection marker/connector and open a centered Bootstrap dialog, ordinary width760px. Mobile retains viewport margins, bounded body scroll, accessible close/actions and an explicit swipe hint. Bootstrap retains focus containment/Escape behavior; shared enhancement restores postback openers.

Dashboard entry lasts460ms with60/110/170/220ms offsets for journey, metrics, work and support. Dialog panels enter over300ms from20px/0.97scale and exit over200ms. Press feedback is immediate. Real pending actions retain button width and native submit semantics, suppress duplicate activation and await server confirmation. A brief check/label transition follows a confirmed write. True progress changes animate from the previous actual value over600ms; repeated initialization does not restart them. Rows highlight only after an existing identity has a changed stored status. Reduced-motion removes travel while preserving state feedback. No production action receives an artificial delay.

## Skills and references actually used

- `frontend-design`: intentional role hierarchy, strong type and purposeful variation in work surfaces.
- `ui-ux-pro-max`: accessible focus/modal and interface guidance. Its initial general design-system search returned an unrelated portfolio direction; that output was not adopted. The user's university brief remained authoritative.
- `apple-design`: precise feedback, spatially consistent dialogs, interruptible marker motion and reduced-motion support.
- `impeccable`: pinned Operate direction, independent finish review and design-system documentation. `design-taste-frontend` supplied applicable app-screen guidance; user-pinned palette and type targets take precedence.
- Playwright CLI supplied browser/fixture verification. Postman's API-engineer/simulation workflow governed existing local dependency stand-ins; no live service was mutated.
- [21st.dev OriginUI stepper with titles/descriptions](https://21st.dev/@originui/components/stepper/with-titles-and-descriptions): inspected actual component code; adapted real triggers, status indicators, labels/descriptions and connecting rail into Web Forms/Bootstrap/plain JS. OriginUI reference is MIT. No React/TypeScript/Tailwind code or runtime was added.
- The previously inspected [sticky-header dialog](https://preview.21st.dev/@originui/components/dialog/scrollable-sticky-header) and [loading button](https://docs.21st.dev/@originui/components/button/loading-button) were revisited but inaccessible in this run; they are historical references, not claimed as newly inspected code.

The final independent visual verdict was SHIP after confirming both readability fixes, refreshed mobile helpers and revealed Home/About content. Static screenshots do not establish motion; the separate local recording and browser checks supply that evidence. See [coverage](30-workspace-redesign-coverage.md), [verification and captures](31-workspace-redesign-verification.md), and the updated `DESIGN.md`/`.impeccable/design.json` for maintained rules.
