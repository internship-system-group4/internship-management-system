# O05 application decisions

Company supervisors review Pending applications at `Pages/Company/Applications.aspx`.
Company.master supplies the shared GJU shell, company navigation, active links,
account details and responsive hamburger on every company page. It reuses the
existing portal stylesheet and navigation script (`portal-layout.css` and
`portal-layout.js`) through the `uims-portal` class. Each role keeps its own menu.

## Decision contract

`ApplicationRepository.Decide` accepts the authenticated CompanySupervisor,
application ID, Accepted or Rejected status, and rejection reason. It verifies an
active supervisor, a valid company, application ownership and ownership of the
linked opportunity on every decision. Only Pending, unconfirmed applications can
be decided. Rejection requires 1–2,000 characters after trimming. Existing
application fields are preserved, including fields unknown to the C# model.

Persisted decision fields:

- `Status`: 1 Accepted or 2 Rejected (existing enum values).
- `RejectionReason`: required text for Rejected; absent/null for Accepted.
- `DecidedBySupervisorId`: authenticated supervisor UID.
- `DecidedAt`: UTC Unix milliseconds.

FirebaseContext supports versioned reads and conditional PUTs. A GET sends
`X-Firebase-ETag: true`, then a PUT sends `if-match` with that version. A 412
conflict produces a refresh message without overwriting the winning decision.
Existing PutIfEmpty behavior used by O01/O03 remains unchanged. This follows the
[Firebase REST contract](https://firebase.google.com/docs/database/rest/save-data).

Both lists read the same application record. The student sees the updated status
and rejection reason on the next request; refresh after a company decision.
Acceptance offers an internship. It does not create a placement, confirm an
offer, or increment filled seats. Student confirmation belongs to O03.

## Verification

Build the solution and start the local Firebase simulation and disposable test
host using `06-application-form.md`, then run:

```powershell
playwright-cli run-code --filename tests/application-decisions.browser.js
```

The 41 assertions run real Web Forms code and REST calls against the local mock.
They cover required/oversize rejection reasons, acceptance, rejection, student
visibility, audit fields, preserved fields, stale forms, changed ownership,
a competing-write 412, failed writes retaining the reason, wrong roles, company
isolation, three widths and seven additional company routes. The mock now
implements ETag headers and conditional writes. Original application,
student-layout and hamburger tests also remain applicable.

The local mock does not emulate Firebase Authentication or database rules.
Repeat the company/student workflow with the team's real accounts, configured
secrets and application indexes before release. Existing development Firebase
rules remain unchanged. Tests do not write to the real database or deploy code.
