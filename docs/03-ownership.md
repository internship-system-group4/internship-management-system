# Who owns what

One page, one developer. The owner writes that page's markup, its code-behind,
its Firebase calls and its tests. Reading data another person's page created is
normal and expected; editing their files is not.

Edit only your own `.aspx` and `.aspx.cs`. For a missing query, add a method to
the relevant repository without changing existing methods. For other shared
foundation changes, ask Ahmad. See `docs/06-team-guide.md`.

## Shared foundation - Ahmad only

| Area | Why it is shared |
| --- | --- |
| `Models/` | Every page uses these types (card X02). |
| `Security/` | The role guard protects all 40 pages at once. |
| `Common/` | Enums, constants, timestamps, validation. |
| `Layout/` | The five master pages. |
| `Data/Json.cs`, `FirebaseContext.cs`, `RepositoryBase.cs`, `UserRepository.cs` | The Firebase plumbing. |
| `Web.config`, `Global.asax.cs` | Application configuration. |
| `Assets/css/site.css` | The shared stylesheet. Page-specific CSS goes in the page's own `head` content block. |

`Common/GradingPolicy.cs` is the one shared file Suja also owns, because the
weights in it come from her research (card X01).

## Placement and academic comment contracts

Ahmad owns the shared contract: `placements/{studentUid}`, with `Id` and
`StudentId` both equal to the UID. Osama's O03 page uses `Confirm`; other pages
use `Exists(studentUid)` or `GetById(studentUid)` instead of a student-side pointer.
Do not create placements with generic `Insert` or `Save`.

`academicComments` belongs to Suja's S03 workflow. The model and collection name
are shared foundation; Suja can add repository queries and implement the timeline
in Student Progress. `GetByPlacement` and `GetByStudent` are supplied. Keep the
end-of-internship summary on `FinalAcademicEvaluation.AcademicComments` separate.

## Pages

| # | Page | File | Owner | Cards |
| --- | --- | --- | --- | --- |
| 1 | Home | `Default.aspx` | Nada | N01, N02 |
| 2 | About Us | `Pages/Public/About.aspx` | Nada | N02 |
| 3 | Contact Us | `Pages/Public/Contact.aspx` | Sara Dolat | D01 |
| 4 | Access Denied | `Pages/Public/AccessDenied.aspx` | Ahmad | A02 |
| 5 | Login | `Pages/Account/Login.aspx` | Ahmad | A01, A02 |
| 6 | Password Recovery | `Pages/Account/ForgotPassword.aspx` | Ahmad | A03 |
| 7 | Change Password | `Pages/Account/ChangePassword.aspx` | Ahmad | A04 |
| 8 | Student Dashboard | `Pages/Student/Dashboard.aspx` | Sara Rajoub | R05 |
| 9 | My Profile | `Pages/Student/Profile.aspx` | Sara Rajoub | R06, R07 |
| 10 | Explore Opportunities | `Pages/Student/Opportunities.aspx` | Sara Rajoub | R03 |
| 11 | Opportunity Details | `Pages/Student/OpportunityDetails.aspx` | Sara Rajoub | R04 |
| 12 | Application Form | `Pages/Student/Apply.aspx` | Osama | O01 |
| 13 | My Applications | `Pages/Student/MyApplications.aspx` | Osama | O02, O03 |
| 14 | My Tasks | `Pages/Student/MyTasks.aspx` | Fatima | F03, F04 |
| 15 | My Progress & Evaluation | `Pages/Student/Progress.aspx` | Ahmad | A15, A16 |
| 16 | Company Dashboard | `Pages/Company/Dashboard.aspx` | Nada | N05 |
| 17 | Manage Opportunities | `Pages/Company/Opportunities.aspx` | Sara Rajoub | R01, R02 |
| 18 | Applications Review | `Pages/Company/Applications.aspx` | Osama | O04, O05 |
| 19 | My Trainees | `Pages/Company/Trainees.aspx` | Nada | N06 |
| 20 | Trainee Details | `Pages/Company/TraineeDetails.aspx` | Nada | N07 |
| 21 | Manage Tasks | `Pages/Company/Tasks.aspx` | Fatima | F01, F02 |
| 22 | Review Submissions | `Pages/Company/TaskReview.aspx` | Fatima | F05, F06, F07 |
| 23 | Reports & Final Evaluation | `Pages/Company/FinalEvaluation.aspx` | Nada | N08, N09 |
| 24 | Company Account | `Pages/Company/Account.aspx` | Nada | N10 |
| 25 | Academic Dashboard | `Pages/Academic/Dashboard.aspx` | Suja | S01 |
| 26 | Student Progress Monitor | `Pages/Academic/StudentProgress.aspx` | Suja | S02, S03, S04 |
| 27 | Final Academic Evaluation | `Pages/Academic/FinalEvaluation.aspx` | Suja | S05, S06 |
| 28 | Academic Account | `Pages/Academic/Account.aspx` | Suja | S07 |
| 29 | Coordinator Dashboard | `Pages/Coordinator/Dashboard.aspx` | Osama | O06 |
| 30 | Manage Students | `Pages/Coordinator/Students.aspx` | Ahmad | A05, A06 |
| 31 | Manage Companies | `Pages/Coordinator/Companies.aspx` | Nada | N03, N04 |
| 32 | Academic Supervisors | `Pages/Coordinator/AcademicSupervisors.aspx` | Ahmad | A07 |
| 33 | Groups & Assignments | `Pages/Coordinator/Groups.aspx` | Ahmad | A08, A09 |
| 34 | Placements & Progress | `Pages/Coordinator/Placements.aspx` | Osama | O07 |
| 35 | Placement Details | `Pages/Coordinator/PlacementDetails.aspx` | Osama | O08 |
| 36 | Final Completion Review | `Pages/Coordinator/CompletionReview.aspx` | Ahmad | A10-A14 |
| 37 | Contact Messages | `Pages/Coordinator/ContactMessages.aspx` | Sara Dolat | D02, D03 |
| 38 | Coordinator Account | `Pages/Coordinator/Account.aspx` | Sara Dolat | D04 |
| 39 | Schedule a Meeting *(optional)* | `Pages/Meetings/Schedule.aspx` | Fatima | F08, F10 |
| 40 | My Meetings *(optional)* | `Pages/Meetings/MyMeetings.aspx` | Fatima | F09 |

Totals: Ahmad 9, Nada 8, Osama 6, Fatima 5, Sara Rajoub 5, Suja 4, Sara Dolat 3.

## Project-wide cards

| Card | Work | Owner |
| --- | --- | --- |
| X01 | Document the university's internship rules | Suja |
| X02 | Shared Firebase data structure | Ahmad |
| X03 | Repository and project structure | Osama |
| X04 | Final Figma prototype | Nada |
| X05 | README | Sara Rajoub |
| X06 | End-to-end testing and the live demo | Osama |

## Repository-level files

| File | Owner |
| --- | --- |
| `docs/01-university-rules.md` | Suja |
| `docs/02-data-model.md` | Ahmad |
| `docs/03-ownership.md` | Ahmad |
| `docs/04-git-workflow.md` | Osama |
| `docs/05-firebase-setup.md` | Ahmad |
| `README.md` | Sara Rajoub |
| `.github/CODEOWNERS` | Ahmad |

## Why there is no folder per person

It was considered and rejected. In Web Forms the folder is part of the URL, so
`Pages/Osama/Apply.aspx` is a URL with a person's name in it, and the student's
own pages would end up split across three different people's folders while
appearing in one sidebar.

It also would not have prevented the conflicts it was meant to prevent. The
real hot-spot in a Web Forms project is the `.csproj`, which gains three lines
per new page no matter which folder that page sits in. That is why all 40 pages
were created up front: with nothing left to register, nobody edits the project
file, and the conflicts disappear for a reason that actually matches the cause.
