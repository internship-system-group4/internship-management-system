# Project QA — 24 October 2026

## Scope and environment

This review covered the public site and the Student, Company Supervisor,
Academic Supervisor and University Coordinator portals. Tests ran against a
disposable IIS Express copy of the application, synthetic accounts and a local
Postman simulation of Firebase/Auth. No production records or real emails were
created by these tests. Generated evidence is in the ignored `tests/artifacts/`
and `tests/bin/` directories.

## Corrections

| Area | Correction |
| --- | --- |
| Company final evaluation | Save drafts and submitted evaluations in the collection consumed by academic review and grading. Enforce the assigned supervisor and score limits. Company submission no longer completes a placement or issues a certificate before coordinator approval. |
| Academic final evaluation | Require a submitted company evaluation, handle save failures without discarding inputs, and make student search null-safe. |
| Completion approval | Use approved source hour entries and the applicable requirement snapshot instead of trusting cached placement totals. |
| Released reports | Preserve approved identity/training snapshots, including nested legacy snapshots, when profiles later change. |
| Arabic in PDFs | Render shaped Arabic glyph outlines, retain Unicode ActualText and Unicode titles, and measure shaped text for centering. Uses the existing Windows/System.Drawing stack. |
| Notifications | Validate the session owner and notification key, preserve email delivery metadata, and avoid duplicate in-app meeting alerts while retaining email delivery. |
| Student task submission | Redirect after a successful submission so refreshing a previous POST after a revision request cannot silently create another attempt. |
| Contact form | Bind view state to the anonymous session, reject repeated successful requests within that session, retain reviewed message state on replay, and bound upstream request time. |
| About page | Correct the film poster path and parallax targets after the image-to-video markup change. |
| Responsive/accessibility | Fix mobile overflow in student progress and coordinator completion evidence; label the opportunity search and read-only profile email. |
| Test infrastructure | Update obsolete smoke-test method names and fixtures; use free ports for the completion runner; correct mock notification ordering and meeting collection support. |

The existing provisional grading weights remain project defaults, not official
university policy. Certificate previews explicitly identify their draft status.

## Verified results

| Verification | Result |
| --- | --- |
| Solution build — Debug and Release | Passed; no build warnings/errors in the final logs |
| ASP.NET full-site precompilation | Passed |
| Route/UI matrix | 464 visits: 58 route variants × English/Arabic × Light/Dark × 1440/390 px |
| Matrix findings | No unexpected HTTP status, ASP.NET error page, uncaught page error, local asset HTTP error, horizontal overflow, language/direction mismatch, or visible unlabeled field detected |
| Completion workflow and report smoke test | 71 checks passed |
| Grades workbook smoke test | 85 checks passed |
| Email/notification smoke tests | 217 checks passed across four configurations |
| Role access, CSRF, sign-in and inactive-account behavior | 35 checks passed |
| Offer confirmation and concurrent acceptance | 24 checks passed |
| Task submission and revision/resubmission | 8 checks passed |
| Contact submission, replay, coordinator review | 10 checks passed |
| Theme interaction, persistence, keyboard and reduced motion | 18 checks passed |
| Login resilience and fallback behavior | 7 checks passed |
| About page media, keyboard, scrolling and fallback behavior | 65 checks passed |
| Team 3D scene, interaction and readable failure fallback | 134 checks passed |
| Shared supervisor accounts, responsive dialogs and draft retention | 75 checks passed |
| Final evaluation candidate/CV selection | 23 checks passed |
| Trainee document modal, safe links, keyboard and focus | 89 checks passed |
| Application review deferred loading, retry, scope and decisions | 22 checks passed; initial queue used three simulated Firebase requests with caching disabled |
| First-party non-vendor JavaScript syntax | 54 files checked, no syntax failures |
| Project content references | All declared content files exist |
| Patch whitespace | `git diff --check` passed |

Arabic report and certificate fixtures were rendered with Poppler and visually
reviewed for joined, readable names, centering and page layout. These fixtures
are synthetic test evidence, not user presentation documents or official
university certificates.

## Repeating the checks

Run the solution build before the C# smoke scripts:

```powershell
msbuild InternshipManagementSystem/InternshipManagementSystem.sln /t:Build /p:Configuration=Debug
./tests/Run-CompletionReviewSmoke.ps1
./tests/Run-GradesExportSmoke.ps1
./tests/Run-EmailNotificationsSmoke.ps1
```

Browser tests require a disposable host created by `tests/Start-LoginTestHost.ps1`
and the repository's local Postman simulation. Set the disposable Firebase read
cache to zero for tests that modify fixtures directly. The new
`tests/project-qa.browser.js`, `tests/project-security.browser.js` and
`tests/student-task-workflow.browser.js` use the current page origin and the
simulation on port 4940. Execute stateful suites sequentially: they reset the
same synthetic database. Never point these scripts at production.

## Boundaries

These results establish the behavior exercised locally, not an absolute absence
of bugs. Deployment-specific Firebase rules/indexes, real Firebase Auth and
Storage, SMTP delivery, live meeting-provider connectivity, other browsers and
production-scale load require verification in their actual environments. The
route matrix checks structural accessibility and layout; it is not a complete
WCAG conformance audit or a manual review of every possible record value.

No commits or pushes were made as part of this QA task. Local student documents,
uploaded personal images and personal tooling configuration remain excluded.
