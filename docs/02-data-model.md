# Firebase data model

**Owner: Ahmad — Trello card X02.** Every page reads these field names, so a
rename here breaks other people's work. Add fields freely; coordinate renames.

Database: **Firebase Realtime Database**, not Firestore. The Realtime Database
REST API works cleanly on .NET Framework 4.7.2 with no SDK, whereas
`Google.Cloud.Firestore` pulls in gRPC and a dependency chain that is awkward on
net472 under Web Forms. See `docs/04-git-workflow.md` for the reasoning.

Timestamps are **Unix milliseconds** (`long`) everywhere — Firebase's own
convention. `Common/Time.cs` converts; each model exposes a `[ScriptIgnore]`
`DateTime` companion so pages work with real dates without the stored shape
changing.

Enums are stored as their **integer** value. The numbers in `Common/Enums.cs`
are therefore part of the data contract: never reorder them.

---

## Collections

```
users/{uid}                        all four roles, discriminated by Role
companies/{id}
studentGroups/{id}
opportunities/{id}
applications/{id}
placements/{id}                    one per confirmed internship
tasks/{id}
submissions/{id}                   append-only, never overwritten
taskEvaluations/{id}               visible to the student
companyFinalEvaluations/{id}       CONFIDENTIAL
academicFinalEvaluations/{id}      CONFIDENTIAL
trainingHours/{id}
completions/{id}
contactMessages/{id}
meetings/{id}                      optional
```

## users/{uid}

One node for all four roles. The key **is** the Firebase Authentication UID, so
there is never a second identifier for a person.

Why one collection and not `students/`, `supervisors/`, `coordinators/`: the
account is read on every request by the role guard, so one node means one read
and no chance of two nodes drifting out of sync. `Models/PersonFactory.cs`
reads `Role` and rebuilds the right C# subclass.

Shared fields, from `Person`:

| Field | Type | Notes |
| --- | --- | --- |
| `Id` | string | the UID; also the node key |
| `FullName` | string | |
| `Email` | string | matches the Authentication account |
| `PhoneNumber` | string | |
| `Role` | int | 1 Student, 2 CompanySupervisor, 3 AcademicSupervisor, 4 Coordinator |
| `IsActive` | bool | coordinator can deactivate — card N04 |
| `MustChangePassword` | bool | true on creation — card A04 |
| `ProfileImageUrl` | string | |
| `CreatedAt` | long | Unix ms |

Role 1 — Student adds `StudentNumber`, `University`, `College`, `Major`,
`RequiredHours`, `ApprovedHours`, `GroupId`, `AcademicSupervisorId`, `CvUrl`,
`PortfolioUrl`, `ConfirmedPlacementId`.

Role 2 — CompanySupervisor adds `CompanyId`, `CompanyName`, `JobTitle`.

Role 3 — AcademicSupervisor adds `Department`, `AcademicRank`, `GroupIds[]`.

Role 4 — Coordinator adds `College`, `OfficeLocation`.

`ConfirmedPlacementId` is the single field that enforces *a student may confirm
only one offer*. Null means no confirmed internship.

## placements/{id} — read this one carefully

A placement is created when a student confirms an accepted offer. **Tasks,
submissions, training hours, both final evaluations and the completion record
all hang off `PlacementId`** — not off the application, and not off the student
alone.

A student has many applications but at most one placement, so anchoring on the
placement is what keeps the one-internship rule true throughout the system. A
team that anchors tasks on the application ends up with a student holding tasks
from two companies, and the bug surfaces during the demo.

`AcademicSupervisorId` is copied onto the placement at confirmation time so the
academic supervisor's pages need one query rather than three.

## submissions/{id} — append-only

A resubmission after a revision request is a **new record** with
`AttemptNumber` incremented. Never update an existing submission in place: card
F07 requires the full history to stay readable, and the revision loop
(submission → revision requested → resubmission → review) is part of the demo.

## Confidentiality

`taskEvaluations` is visible to the student. `companyFinalEvaluations` and
`academicFinalEvaluations` are **not** — the requirements document says so
directly. The student sees their final *result* once the coordinator approves
completion, never the forms.

`Data/EvaluationRepository.cs` names its methods so a page cannot reach the
confidential ones by accident. Enforce it in the Firebase rules too, not only
in the UI.

## Denormalised fields

Several records carry a copy of a name alongside its id — `CompanyName` on a
placement, `StudentName` on an application. The Realtime Database cannot join,
so without the copy every list page would need one extra read per row.

The cost is that a renamed company leaves stale copies behind. That is an
acceptable trade for this project; if a rename feature is ever added, it has to
fan out the update.

`ApprovedHours` appears on both `users/{uid}` and `placements/{id}` as a cached
total. It is always **recomputed** from the approved `trainingHours` entries by
`HoursService.RecomputeTotals` — never incremented by hand, so a missed write
cannot drift the total.

## Required indexes

`GetWhere` queries need `.indexOn` rules or Firebase returns an index warning
and filters on the client. The full rule set is in
`docs/05-firebase-setup.md`.

## Field naming

C# PascalCase, matching the property names exactly, because
`JavaScriptSerializer` maps them one to one with no attributes. It makes the
Firebase console slightly unusual to look at and saves a whole layer of
mapping code. Do not switch some fields to camelCase: the mismatch fails
silently, leaving a field quietly null.
