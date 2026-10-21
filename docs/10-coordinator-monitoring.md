# O06–O08: coordinator monitoring

Implemented in `Pages/Coordinator/Dashboard.aspx`, `Placements.aspx` and
`PlacementDetails.aspx`. All three inherit `CoordinatorPage` and the existing
`Coordinator.master`. The approved GJU theme and responsive hamburger remain shared.
`Assets/css/coordinator-monitoring.css` contains only these pages' styles.

## Data and behavior

`Data/CoordinatorMonitoringRepository.cs` reads the existing Firebase REST contract;
it does not update hours, tasks, evaluations or placements. No schema or enum changes.
The dashboard and lists load fresh data on each request/refresh. They do not subscribe
to live Firebase events or poll in the background.

- Dashboard: student and company totals plus active counts; opportunity totals plus
  open, unexpired opportunities with seats; historical confirmed placements plus
  confirmed/active counts; task-evaluation records including revision history;
  submitted company/academic final-evaluation records, excluding drafts.
- Attention: placements awaiting completion, tasks overdue and not graded, and
  positive reported hours awaiting approval.
- Placements: case-insensitive name, student number, UID or company search;
  status filter; ten results per page, preserving filters. Archived/missing student
  profiles fall back to the placement's student-name snapshot.
- Details: supervisors, training dates, tasks, all submission attempts, revision
  feedback, evaluations on their actual mark scales, hours with review states,
  company/academic final evaluations and academic follow-up comments.
- Final evaluations and private comments are accessible through the coordinator
  guard. The page displays saved results; it does not calculate or approve final
  grades. An official report link appears only on an approved completion record
  and only for a valid HTTPS URL. Completion Review remains Ahmad's separate page.

Only canonical placements where the Firebase key, `Id` and `StudentId` match and
status is a defined non-Offered value are included. Tasks must match the placement's
student and company. Submissions and task evaluations must also match the related
task and submission. Other-placement or mismatched-student records are excluded.

Approved hours are summed from positive `trainingHours` entries with matching
`PlacementId` and `StudentId` and `Status = Approved`. The cached
`Placement.ApprovedHours` is not used as evidence. Reported and rejected hours never
count. A missing hour requirement displays an explicit unconfigured message.

Empty states differ from read failures. A Firebase read error suppresses statistics
or partial detail content and shows a retry message. Missing valid placement IDs
return 404; malformed/missing IDs ask the coordinator to choose a placement.
Text is HTML encoded, and untrusted submission links require HTTPS.

## Firebase indexes for the shared environment

Have the Firebase owner merge these indexes into the existing nodes before a live
test. Preserve existing indexes and access rules; no live rules were changed here.

| Node | Required additional indexed field |
| --- | --- |
| `tasks` | `PlacementId` |
| `submissions` | `PlacementId` |
| `taskEvaluations` | `PlacementId` |
| `trainingHours` | `PlacementId` |
| `companyFinalEvaluations` | `PlacementId` |
| `academicFinalEvaluations` | `PlacementId` |
| `academicComments` | `PlacementId` |
| `completions` | `PlacementId` |

For example, add `".indexOn": ["PlacementId"]` beside a node's existing `.read` and
`.write` fields. An index does not grant permission. Existing development rules are
documented in `05-firebase-setup.md`; final-evaluation collections must stay private
from students. These views do not strengthen those development database rules.

The dashboard loads whole collections to aggregate counts. The placements list also
loads placements, student profiles and hours before filtering and paging. This suits
the course dataset; paging is at the UI layer, not a database scalability guarantee.

## Reproducible local verification

Use the disposable IIS fixture described in `06-application-form.md` and the existing
Postman simulation. The stand-in models Firebase JSON/query behavior and monitoring
read failures; it does not implement Firebase Authentication, security rules or index
enforcement.

```powershell
postman simulation run postman/simulations/internship-application.sim.yaml --port 4900 --no-history --output ndjson
playwright-cli run-code --filename tests/coordinator-monitoring.browser.js
```

The browser suite resets and seeds only the local stand-in. It verifies aggregation,
relationship mismatches, approved-only hours, search/status/paging, submission history,
actual score scales, HTML encoding, unsafe-link suppression, approval-gated reports,
refresh, role denial, empty/error states, missing profiles and mobile layouts.
Screenshots are generated under ignored `tests/artifacts/`. No shared Firebase data
or production credentials are needed. See `11-demo-checklist.md` for the remaining
live integration and demo checks.
