# Student Progress, Students by Major and Final Completion Review

Owner: Ahmad (A10 - A16). Written 2026-10-23.

This note covers three areas: `Pages/Student/Progress.aspx`, the coordinator's
*Students by Major* chart (shared `Layout/WorkspaceChart.ascx`), and
`Pages/Coordinator/CompletionReview.aspx`, plus the completion PDFs.

The project brief file `docs/C# Project 3.docx` is **not in the repository**,
so the brief requirements below come from the task description and
`docs/01-university-rules.md`.

## 1. Where each rule comes from

Every requirement in the UI has a source label: *Verified GJU rule*,
*Project brief*, *Project proposal (not GJU policy)* or *Unresolved: verify
manually*. The definitions live in `Common/InternshipRequirements.cs`.

### Verified on official GJU pages (checked 2026-10-23)

| Rule | Source |
| --- | --- |
| SC programmes: Computer Science, Computer Engineering, Game Design and Media Informatics | [Undergraduate programs](https://www.gju.edu.jo/content/undergraduate-programs-3413) |
| Local training courses CS391, CE391, DMI3900; 160 contact hours at one company, related to the major | [Local training](https://gju.edu.jo/content/local-training-14477) |
| Department/school approval before training; hours before approval do not count | Local training |
| Not during a registered semester; no blood relative as employer | Local training, [CS FAQ](https://gju.edu.jo/content/faqs-14846) |
| Signed and stamped training forms with the task list; head of department review; dean endorsement | Local training |
| German Year internship: at least 20 weeks full time | [German Year](https://www.gju.edu.jo/content/about-german-year-14761), [Internship semester](https://www.gju.edu.jo/content/internship-semester-15909) |
| Signed contract approved before the internship; certificate and report uploaded afterwards; faculty validation | Internship semester, [MyGJU workflow news, 24 Feb 2021](https://www.gju.edu.jo/ar/news/12303) |
| Jordan field training must be completed before going to Germany (CS FAQ) | CS FAQ |
| Course pass mark 50%, cumulative pass 60%; P/F grades exist | [Grading system](https://gju.edu.jo/content/grading-system-undergraduate-programs-13655) |

None of these pages shows a publication date (only a "© 2014 - 2026" footer),
except the MyGJU news item.

### Unresolved (manual verification, never automatic)

* **Credit-hour prerequisite**: the local training page lists 115 (CE) and 90
  (CS, GDMI; 85 old plan) but also says "at least 0 credit hours".
* **Schedule**: "four weeks continuous" on the local training page versus
  "8 h x 4 weeks or 4 h x 8 weeks" in the CS FAQ.
* School vs department as the approving body.

### Project proposals (not GJU policy)

* Evaluation method `UIMS-PROPOSED-2026.1`: tasks 30%, company 45%,
  academic 25%, pass mark 60% (`Common/GradingPolicy.cs`). The 60% figure is
  the GJU *cumulative* pass average, not a published internship rule.
* The released result is Pass/Fail (docs/01); the score is shown as
  "supporting score".
* Placements without an internship type are treated as local training.

## 2. Completion rules (server side)

`Services/CompletionService.cs`:

* Approval needs **every** mandatory item: both final evaluations submitted,
  the hours rule (local) or the 20-week duration (international), all tasks
  graded, a Pass provisional result, and each manual check *Verified* or
  *Not applicable* **with a written evidence reference**.
* The numeric result never approves anything and cannot override a missing
  requirement.
* **Return for corrections** needs a note (5+ chars) and can be reviewed again.
  **Reject** needs a reason (10+ chars) and closes the review.
  Approved and rejected reviews are read-only.
* Decisions re-read the record with its Firebase ETag and write with
  `if-match` (compare-and-swap), so two coordinators or two tabs cannot both
  decide.
* The approval stamp animation plays only after the redirect that follows a
  saved approval (a one-time session flag, `SessionHelper.SetFlash`).

## 3. Firebase data (all additive, no migration)

| Node | New optional fields |
| --- | --- |
| `placements/{uid}` | `InternshipType` ("Local" / "International"; missing = local) |
| `completions/{placementId}` | `Decision` ("Approved" / "Corrections" / "Rejected"), `DecidedAt`, `Checks/{key}` (`Key, Status, Evidence, CoordinatorId, CheckedAt`), `EvaluationMethod`, `InternshipType`, snapshot fields `StudentName, StudentNumber, Program, CompanyName, OpportunityTitle, TrainingStart, TrainingEnd, CoordinatorName` |

Compatibility:

* `Status` keeps its meaning. Corrections and rejections both store
  `Status = Rejected (5)`, so older pages still read "not approved"; the new
  `Decision` field tells them apart. A record with `Status = 5` and no
  `Decision` is an older "returned" record and is shown as *Needs corrections*.
* Saving a manual check before any decision creates a `NotReady (0)` record
  (`CompletionRepository.EnsureFor`, conditional write). Teammates' pages show
  that as "awaiting supervisor assessment".
* No new top-level collection, so the database rules in
  `docs/05-firebase-setup.md` need no change. Note: those development rules let
  any signed-in user write `completions`; the pages enforce roles, the rules do not.

## 4. Students by Major

* `WorkspaceChartFactory.Coordinator` counts each student once (by Id) into
  CS / CE / GDMI (always shown), plus *Major not recorded* and *Unrecognized
  major* when present. Matching ignores case, extra spaces and "&" vs "and",
  and accepts CS / CE / GDMI abbreviations. Nothing else is guessed and the
  stored `Major` is never changed.
* The notice "Academic information verification required for X student
  records" appears when X > 0.
* Horizontal bars are opt-in (`BarLayout = "horizontal"`); the student,
  company and academic dashboards keep their vertical bars.
* "Open student list" links to `ManageStudents.aspx?major=cs|ce|gdmi|missing|unverified`.

## 5. Demo student (presentations)

`Pages/Coordinator/DemoStudent.aspx` (coordinator only, and only when the app
runs on your own machine; elsewhere it returns 404). It is not in the menu:
open `/Pages/Coordinator/DemoStudent.aspx` directly.

1. Sign in as the coordinator, open the page, type a name, an unused email and
   a password, and press **Create demo student**.
2. It creates the Firebase Auth account and a complete local internship
   (Computer Science, CS391) at the existing company supervisor's company:
   accepted application, placement, 5 graded tasks (out of 10/20/25/50/100,
   one revised), 4 x 40 approved hours, both final evaluations submitted, and
   6 of 8 checks verified (`Services/DemoStudentService.cs`).
3. **Review and approve now** opens the review. Verify *Training report* and
   *Department review and dean endorsement* with an evidence reference, save,
   approve, then download or print the report and certificate.
4. Sign in with the demo email and password to see the student's page.
5. **Reset to ready for review** puts the demo back so the approval can be
   shown again.

It only adds records with `demo-` keys (plus the new student's own UID),
sends no notifications, and never edits or deletes other data.

## 6. Known limits / follow-ups

* `Constants.Programs` (used by the Home page, company opportunity forms and
  `StudentCreation.ascx`) still lists only CE and CS. Adding GDMI there would
  also show it on the Home page, so it was left for the owners to decide.
  `ManageStudents.aspx` now offers all three programmes.
* PDFs use the built-in Helvetica font, so Arabic names print as "?".
* ETag behaviour was tested against a local Firebase stand-in, not the live
  project.
* There is no document upload for training forms or reports; their status is
  the coordinator's recorded verification with an evidence reference.
