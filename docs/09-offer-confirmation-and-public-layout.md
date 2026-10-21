# O03 offer confirmation and public navigation

## Confirming one internship

My Applications now offers Confirm offer only for Accepted applications while
the student has no placement. The student must acknowledge that they can choose
only one internship. The server independently verifies ownership, Accepted
status, the linked opportunity/company and the assigned company supervisor.

`PlacementRepository.ConfirmAcceptedOffer` builds a placement from trusted
records, including the student, application, opportunity, company, company
supervisor, academic supervisor, required hours and dates. It creates
`placements/{studentUid}` with a conditional PUT (`if-match: null_etag`) through
the existing Confirm method. This key is the source of truth for the student's
one internship, including competing requests from different authenticated
sessions. It is never replaced by another application's confirmation.

The placement has Confirmed status and a Unix-millisecond ConfirmedAt timestamp.
ApprovedHours starts at zero. EndDate is derived from a specified StartDate and
DurationWeeks; unspecified dates remain zero. This change does not reserve or
increment opportunity seats, change other offers' statuses, assign tasks or
approve hours. Confirming an accepted offer is separate from new-application
availability/deadline checks.

After saving the placement, the application is patched with
`IsConfirmedByStudent = true`. These are two writes, not a multi-node transaction.
If this secondary write fails, the placement remains authoritative: the UI still
shows the confirmed internship and prevents a second confirmation. Sync
confirmation retries the application flag without creating a second placement.
A retry for the same saved placement is idempotent. A lost/uncertain placement
response instructs the student to refresh before retrying.

## Public Navbar and Footer

`Layout/Public.master` provides both components to Home, About, Contact, Login,
Forgot Password, Access Denied and Change Password. Existing page content and
role-specific layouts remain separate. Styles are in
`Assets/css/public-layout.css`; mobile menu behavior is in
`Assets/js/public-layout.js`.

The Navbar uses the approved GJU logo and palette with Home, About us,
Opportunities, Contact us and Log in/My dashboard. The Opportunities link goes
through the existing student role guard; visitors are redirected to Login with
a return URL. Authenticated users get their role's dashboard link. The Footer
includes product context, navigation, contact and the university website.
No links target missing process sections or unimplemented policy pages.

The menu collapses below 900px, supports Escape and outside-click closing, and
keeps navigation expanded if JavaScript is disabled. Branding identifies UIMS
as a student project rather than asserting an official university service.

## Verification

Use the local simulation/disposable host from 06-application-form.md, then run:

```powershell
playwright-cli run-code --filename tests/offer-confirmation.browser.js
playwright-cli run-code --filename tests/public-layout.browser.js
```

O03 has 24 assertions covering validation, saved relationships, one placement,
concurrent offers from two separate sessions, failed writes, sync recovery and
desktop/mobile rendering. The public shell has 37 assertions across six public
pages plus protected Change Password, including active links, logo loading,
responsive layout, mobile menu, no-JavaScript fallback and authenticated routing.

Existing O01/O05 and role-layout suites also pass. Tests run actual Web Forms and
the existing REST client against a local Firebase contract mock, now supporting
PATCH and serialized atomic conditional writes. Live Firebase Auth/rules and the
team's real database still require integration verification before release.
