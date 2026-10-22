# Public pages: cohesive GJU redesign

The additional four-page requirements are implemented in
`14-public-pages-requirements.md`, which supersedes the initial no-preview/no-video
state and documents the verified-session Login redirect refinement.

## Scope and direction

ASP.NET Web Forms / .NET Framework 4.7.2 is retained. Public routes:
`Default.aspx`, `Pages/Public/About.aspx`, `Contact.aspx`, `AccessDenied.aspx`,
`Pages/Account/Login.aspx` and `ForgotPassword.aspx`. All reuse Public.master.
Role masters, dashboards and private page implementations are outside the change.
The existing protected ChangePassword page inherits the public shell as before.

Audience: students exploring their internship journey, with company and university
supervisors accessing role-specific portals. Primary action: log in using an existing
university internship account. Opportunities keep their protected student route;
this redesign does not make private data publicly readable.

design-taste-frontend dealt three directions; `editorial-report` (seed 258884783)
was selected for a university process based on guidance and readable content. Its
column alignment, strong type and restrained color fields are used within the
approved GJU brand. The earlier split campus hero is retained rather than imposing
a new full-screen masthead or oversized footer. Palette/type stay pinned to DESIGN.md.

The page argument is: understand the journey → know the steps → connect study with
experience → understand available account-based access → log in or request help.
Home uses real configured study programs; its illustrative vacancy cards are removed.
About explains the system and four roles without invented claims. Contact provides
access/process guidance and a usable message form. Login/recovery retain existing
server handlers and control IDs, adding accessible labels, errors and password state.
Access Denied retains the authenticated/anonymous return-link logic.

The GJU logo and existing campus photos are reused. See `12-homepage.md` for origin
URLs. No invented statistics, partnerships, testimonials, emails, response-time
promises or video controls are added. Public content describes the intended project
workflow; this change does not complete the team's private placeholder pages.

## Shared behavior and accessibility

- 16px body type, generous reading measure, clear heading hierarchy and one H1.
- Consistent navy primary actions, plain white/pale blue surfaces and compact corners.
- 48px form controls; visible focus and at least 3:1 input boundary contrast.
- Mobile menu at 960px, Escape/focus return, outside/link close and no-JS fallback.
- Skip link, associated labels/errors, required-state semantics, status announcements,
  password reveal state and first-invalid-field focus.
- Short photo entrances and button-color feedback only, respecting reduced motion.
- Arabic contact input supports natural RTL through `dir=auto`. CSS logical properties
  and forced RTL layouts were checked. The existing UI is English; no unsupplied
  translations or artificial language selector were added.
- CSS/JS version strings avoid stale cached assets after deployment.

No dependencies were added. Existing Bootstrap remains available for the shared
shell/protected account page, while the redesigned public components use their own
scoped classes. Authentication, role guards, Firebase configuration and account
service implementations are unchanged.

## Contact integration

Contact was previously a placeholder with no form or handler. Its new form uses
the existing ContactRepository and ContactMessage contract, writing only
`contactMessages/{serverGuid}`. No collection, model, enum or live database rule is
changed. Fields: SenderName, SenderEmail, Subject, Message, Id, Status=New and
SubmittedAt. Names are 2–100 characters, email at most 254 and valid, subject 5–150,
message 20–4,000. Validation runs on both client and server; server errors are encoded.

A session-bound ViewState carries a stable server-owned submission key. Retrying
the same form writes the same key; successful submission redirects to a clean GET
with a one-time session notice. Refresh cannot resubmit a saved message. Failure
keeps the input and reports uncertainty honestly. A honeypot provides a basic bot
filter, not a claim of complete anti-spam protection. Public rate limits and deployed
Firebase rules remain deployment responsibilities.

The coordinator inbox page remains the owning team's implementation; this change
saves records in its existing collection but does not build that private page.

## Reproduce local verification

Build the web project, run the existing Postman Firebase stand-in and create an
isolated IIS copy. The test helper now explicitly loads the local override in the
copied Web.config before IIS starts, avoiding calls to the team's database.

```powershell
postman simulation run postman/simulations/internship-application.sim.yaml --port 4902 --no-history --output ndjson
./tests/Start-ApplicationTestHost.ps1 -Port 57983 -SimulationPort 4902
playwright-cli open http://localhost:57983/Default.aspx
playwright-cli run-code --filename tests/public-redesign.browser.js
```

The existing application/layout suites use ports 57982/4900 by default; run the
helper on those defaults for them, or adjust only disposable test copies. The
public-layout suite scopes the anonymous login assertion to the Navbar, since
content may legitimately offer additional login actions.

The public suite covers all six routes at 1440, 768, 390 and 320px; heading/shell
integrity, overflow, keyboard skip/menu access, form errors, password reveal,
Arabic input, forced RTL, reduced motion, no-JS validation/navigation, contact
save/retry/failure, refresh safety and browser console errors. Screenshot artifacts
are under ignored `tests/artifacts/`.

Verified: MSBuild Debug succeeds; public-redesign 158, application 32,
application-decisions 41, offer-confirmation 24, public-layout 37, role-layouts 164
and coordinator-monitoring 59 checks pass (515 total). Browser console/script error
lists are empty. Existing suites were run against disposable copies with the local
ports substituted; production configuration was not changed.

The Postman stand-in adds contactMessages to its modeled collections and applies
the existing write-failure control to contact writes. It does not emulate Firebase
Authentication, security rules, indexes or email delivery. Real login, reset emails
and deployed Firebase access remain unverified without live-account testing.

## Design review

Before screenshots were captured for all public routes at desktop/mobile widths.
After implementation, all six routes were reviewed at desktop, tablet and phone.
Independent visual review found no material layout issue. Independent source review
identified low-contrast input borders; these were darkened to #7b8fa5 and rechecked.

The Impeccable markup detector reported no findings. The generic taste inspector
also measured the page; its remaining stylistic preferences for more photographs,
more animation and no divider lines were intentionally not adopted: the approved
brand uses quiet borders, only relevant existing photos are available, and the
request limits motion to useful feedback. Brand metadata text was raised to 13px
after its small-text finding. This is not a claim of a zero-warning taste-inspector
run or formal accessibility certification.
