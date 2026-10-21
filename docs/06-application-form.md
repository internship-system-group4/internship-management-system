# O01 — Internship Application Form

Open `Pages/Student/Apply.aspx?opportunityId=OPPORTUNITY_ID` as a student.
The `id` query parameter is also accepted for compatibility with opportunity links.
Configure the ignored `App_Secrets.config` as described in `05-firebase-setup.md`
and apply the `applications` indexes from that document first.

The form shows the selected opportunity and the signed-in student's profile.
A CV is an HTTPS link, not an uploaded file, following the project's link-only
storage policy. The cover letter must contain 50–4,000 characters after trimming;
the student must confirm accuracy and CV accessibility. The server checks all
inputs, reloads opportunity availability and eligibility, and refuses applications
from students with an existing placement. Document accessibility is confirmed by
the student; the server does not download or verify the linked document.

## Persistence contract

The existing PascalCase `InternshipApplication` model remains unchanged.
`Status` is the integer `0` (Pending), and `SubmittedAt` uses UTC Unix milliseconds.
Student/company identifiers, names, major, and opportunity title are copied from
the authenticated profile and the current opportunity, not posted form values.

One application per student/opportunity is stored at
`applications/{sha256(studentUid + "\n" + opportunityId)}`. A conditional PUT with
`if-match: null_etag` refuses an existing record, including concurrent requests
and retries after an uncertain response. A prior filtered read also catches
older applications created with push keys. A rejected/withdrawn application still
counts as an existing application; reapplication is not part of O01.

Both lists read this same collection using indexed `StudentId` or `CompanyId`
queries. They display application details, CV links and status. Company
accept/reject actions are now implemented in O05 (see 07-application-decisions.md).
Student offer confirmation (O03) remains separate. Existing development database rules remain development rules;
the list pages enforce role and ownership filters in the server application.

## Verification

Prerequisites: the README's Visual Studio/.NET Framework tools, Postman CLI
1.70+, and `playwright-cli` with its browser installed. Restore NuGet packages
and build the solution before starting the test host.

From the repository root, in one terminal:

```powershell
postman simulation run postman/simulations/internship-application.sim.yaml --port 4900 --no-history --output ndjson
```

In a second terminal:

```powershell
./tests/Start-ApplicationTestHost.ps1
New-Item -ItemType Directory -Force tests/artifacts
playwright-cli open http://localhost:57982/__fixture.aspx
playwright-cli run-code --filename tests/application.browser.js
```

The host script copies the built web app to a unique temporary directory,
excludes real secrets, points Firebase at the simulation, and adds a fixture
sign-in page **only in that disposable copy**. No authentication bypass is added
to the real app. It prints `ProcessId` and `TestRoot`; stop that IIS Express
process with `Stop-Process -Id PROCESS_ID` after testing. Stop the simulation
with Ctrl+C. Never deploy the temporary test copy.

The browser checks exercise the actual ASP.NET page lifecycle and Firebase REST
client: role guards, missing/invalid opportunity IDs, validation, availability
changes, eligibility, placements, submission, Pending visibility in both lists,
company isolation, duplicate/legacy application checks and conditional-write
conflicts. Screenshots cover 1440, 768 and 390 px and check horizontal overflow.

The local mock models only the paths used here, including Firebase's null reads,
query filtering and 412 conditional-write response, based on the official
[Firebase REST contract](https://firebase.google.com/docs/reference/rest/database).
It does not emulate Firebase Authentication or database security rules. Public
API discovery returned unrelated providers, so the official Firebase contract
and existing repository client were used. No owner-published mock was reused;
this is a local contract stand-in. Live Firebase credentials were absent during
development; sign in with real student/company accounts and repeat submission
against the team's configured database before release.

## Shared student layout

`Layout/Student.master` owns the GJU logo, sidebar icons, active navigation,
user initials and logout. Styles are in `Assets/css/portal-layout.css`.
All student pages using this master inherit the theme without copying markup
or loading O01's form stylesheet. Check the shared layout after the O01 tests:

```powershell
playwright-cli run-code --filename tests/student-layout.browser.js
```

This checks six student routes, active links, mobile overflow, rendering with
JavaScript disabled and logout/session clearing against the local fixture host.

Responsive navigation checks (35 assertions, desktop/tablet/phone):

    playwright-cli run-code --filename tests/student-hamburger.browser.js

Covers hamburger visibility, open/close, Escape, backdrop, focus trapping,
background inertness, link navigation, viewport changes and mobile logout.
