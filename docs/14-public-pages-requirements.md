# Four public pages — completed brief and integration notes

This extends the GJU design in DESIGN.md and the public redesign documented in
`13-public-redesign.md`, without changing the framework or protected dashboards.
The implementation reuses ASP.NET Web Forms, existing Bootstrap, FirebaseContext,
repositories, AuthService, SessionHelper, StudentPage and role-based route guards.

## Home and verified content

- Official existing GJU logo and campus photos remain in the shared public shell.
- College, program and specialization names are rendered from Constants rather
  than invented page-specific lists. Project configuration supports School of
  Computing, Computer Engineering and Computer Science. Official curricular policy
  verification beyond that configuration remains the team's X01 responsibility.
- About now includes sourced university context: GJU is a public Jordanian
  university founded in 2005 with an applied educational approach. Sources:
  [GJU About](https://gju.edu.jo/content/about-gju-687),
  [GJU identity](https://www.gju.edu.jo/content/university-identity-51), and
  [School of Computing](https://gju.edu.jo/content/school-computing-sc-381).
  No enrollment numbers, partners or testimonials were added.

## Public opportunity summaries

The existing `opportunities` collection requires authentication. It must not be
made public just to render homepage cards. The homepage therefore reads only a
separate allowlisted projection, `publicOpportunityPreviews/{opportunityId}`.
Each record contains Id, Title, CompanyName, Location, Summary (20–280 characters),
Status, RemainingSeats, ApplicationDeadline and PublishedAt. Full descriptions,
requirements, supervisor contacts, applications and user data are never rendered.
Unknown fields are not mapped into the view model.

Only valid-key, open, unexpired records with seats are shown, newest first, maximum
three. Text is HTML encoded. Missing data renders an honest empty state; read or
configuration failures render a recoverable notice. No seed/fake vacancy is
silently used by production code. Local screenshots use explicitly seeded test data.

### Required deployment configuration

`public-opportunity-rules.fragment.json` is a **merge fragment**, not a replacement
for the team's entire rules file. It permits anonymous summary reads, limits writes
to active verified owners/coordinators and rejects extra fields. Have the Firebase
owner review and test it in the project's security-rule environment, then merge it
without broadening reads on `opportunities`, `users` or other private collections.
No live rules were changed, and the local stand-in does not enforce these rules.

`OpportunityRepository.PublishPublicPreview(id, summary)` supplies the publication
operation. It rereads the caller's profile, requires the actual owner/coordinator,
loads the real opportunity and copies only the public fields. A closed/full/expired
opportunity is unpublished. The owning team's save/publish workflow must call it
after saving an opportunity; unpublish before deleting an opportunity. Existing
CRUD is deliberately unchanged. The current private opportunity-management page is
still a team placeholder, so automatic publication wiring remains a deployment/team
integration step. Until summaries are published, the homepage correctly shows none.
Do not directly copy full opportunity records into the public node.

Full-detail links target the existing protected Student/OpportunityDetails.aspx
route. Both that route and Apply.aspx inherit StudentPage and redirect anonymous
direct requests to Login on the server. Nonstudent roles cannot apply. No secrets
or administrative credential are added to anonymous pages or browser code.

## Process video — missing asset

No actual internship-process video was provided or found in the project. A dedicated
Home section is explicitly labeled **Development placeholder — official video
pending**, with a usable link to the written steps. It is not a fabricated video
or a broken play button. Add the approved MP4 and matching WebVTT captions as
documented in Assets/video/README.md. The page then renders native keyboard-accessible
HTML5 controls, no autoplay, inline playback and captions when supplied.
Actual playback, audio content and caption timing remain blocked by the missing files.

## Contact and authentication

The contact form retains client/server validation and the existing Firebase message
contract. It now announces sending progress, marks the form busy and blocks repeated
submission while a request is pending, without disabling the Web Forms submit control
before its name can be posted. Invalid browser input and browser-history restoration
reset that state. A stable server-owned key and post/redirect/get prevent accidental
duplicates. Only a confirmed successful Firebase write leads to success feedback;
failures retain input. There is no false success after merely clicking Send.

Login retains Firebase email/password authentication, field IDs, event handlers,
accessible password reveal and the recovery route. Existing sessions are now
reread from Firebase before redirecting by verified role; inactive accounts fail
closed, and required password changes retain precedence. ViewState is session-bound.
An expired profile lookup produces a friendly error. No user-selected role is accepted,
and no plaintext passwords are stored in database/session/browser storage by these changes.

## Motion and scope

Short hero entrances, one-time IntersectionObserver section reveals, subtle preview
hover and mobile-menu entrance motion use CSS and vanilla JavaScript. GSAP is not
necessary and was not added. Content remains visible if JavaScript or observers
fail; reduced-motion changes disconnect observers and suppress animations.
RTL inputs and logical spacing from the existing redesign remain supported.
All styles stay on the public shell/classes; no role master or dashboard is edited.

## Verification

The Debug build passed. Local verification passed 552 checks: 515 existing
regression assertions, 32 public-requirement assertions and five publication
checks through a disposable test-only endpoint. The latter endpoint is absent
from the application source. Publication checks covered unauthorized actors,
company ownership, allowed projection fields and removal after closing.
The final independent visual review found no material issues.

`tests/public-requirements.browser.js` runs against disposable IIS on 57983 and the
updated Postman Firebase stand-in on 4903. It covers public projection filtering,
private-field exclusion, encoded titles, empty/error states, direct visitor route
denial, role redirects from verified fixture profiles, role changes, inactive accounts,
temporary-password gates, contact progress/duplicate blocking and confirmed save,
missing-video state, reduced motion and desktop/tablet/mobile screenshots.

Use `Start-ApplicationTestHost.ps1 -Port 57983 -SimulationPort 4903`; build first and
start the simulation with `--port 4903`. Existing suites default to other local
ports, so adapt disposable copies or run their default test host. Do not point these
fixtures at a shared database. The public UI regression suite covers 1440, 768, 390
and 320px, keyboard/navigation, Arabic input, no-JS server validation and console errors.

Real Firebase sign-in, password-reset email delivery and deployed rule enforcement
were not tested: authorized live test-account credentials were not supplied. Role
tests use session fixtures and real profile reads against the local stand-in, not a
claim of successful live authentication. Recovery retains the existing non-enumerating
AuthService behavior. Production readiness still requires live-account/rules checks,
summary publication and the actual process video/captions.

The rules fragment is a proposed merge, not a deployed or emulator-verified policy.
Its authorization depends on trusted role, account-state and company-ownership
profile fields; the team must review it alongside existing parent rules before
deployment. No Firebase rules were deployed during this task.
