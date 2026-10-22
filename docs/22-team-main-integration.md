# Integration of team updates — 22 October 2026

Work remains on `osamabanihani`. The public campus/navigation implementation was
saved as `bf5317e`; the pending merge incorporates team main commit `aac67bd`.
The requested push destination is `origin/osamabanihani`, not main.

The three conflicts were Contact.aspx, its code-behind and designer. Resolution
keeps the redesigned shared public layout, accessible client/server validation,
honeypot, session-bound ViewState, server-owned submission key and post/redirect/get
feedback. The team control IDs (`txtName`, `txtEmail`, `txtSubject`, `txtMessage`,
`lblMessage`, `btnSend`) and `btnSend_Click` handler name are retained.

The form saves the coordinator inbox's actual case-sensitive contract:
`ContactMessages/{submissionId}` with `Name`, `Email`, `Subject`, `Message`, string
`Status: New` and millisecond `SubmittedAt`. The shared FirebaseContext sends the
write with `if-match: null_etag` through PutIfEmpty. A repeated form POST therefore
cannot create another message or reset a coordinator's Reviewed status. This
reuses the existing REST client and conditional-write support. No database data
was migrated or deleted; no live Firebase writes were used for verification.

Other team changes merge intact, including academic/company/student/coordinator
pages, task and group repositories, solution/project entries, fixtures and
Newtonsoft.Json dependency. NuGet restored the package version declared on main.
Earlier reports describe the state when their features were built; page scaffolds
mentioned there may now have implementations supplied by the team.

Verification after integration:

- Debug MSBuild: exit 0, four pre-existing compiler warnings from team's changes
  (three repeated using directives in SubmissionRepository; unused ex in academic
  Account). No new build errors.
- Public requirements: 32 passing checks after updating ContactMessages assertions
  to the team's contract; includes the Contact save and existing public flows.
- Resizable navbar: 154 passing checks, four fixture roles, zero browser errors.
- `tests/contact-merge.browser.js`: 10 passing checks covering public submit,
  coordinator inbox read, actual review dialog/postback, stable record identity,
  reload/repeated POST safety and preservation of Reviewed status on replay.
- Total after integration: 196 browser assertions against a disposable IIS Express
  application and the existing local Postman Firebase stand-in (port 4905).
  This is not verification of production Firebase rules or real password login.

The Postman mock retains legacy lowercase contactMessages support and adds the
team's uppercase ContactMessages node and write-failure simulation. Browser tests
use the updated inbox contract. Generated target-port variants and execution logs
are under ignored tests/artifacts/main-merge-*.

Local `.img2threejs/` workflow diagnostics were left untouched. No force push,
reset, file deletion or push to main is part of this integration.
