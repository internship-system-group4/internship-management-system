# Notifications (top-bar bell)

Owner: Ahmad. Every portal (student, company, academic, coordinator) shows a
bell in the top bar with an unread badge and the latest 8 notifications.
"View all notifications" opens `Pages/Account/Notifications.aspx`, which lists
the latest 100 and has **Mark all as read**. Clicking a notification marks it
read and opens the page it points to.

## Setup (once)

Add the `notifications` rule from `docs/05-firebase-setup.md` to the Firebase
Realtime Database rules. Without it the bell says "Notifications are
unavailable right now"; nothing else breaks.

## What sends a notification

Notifications are sent from the shared repositories and services, right after
a successful save. A page that saves through these methods needs no extra code.

| Cycle step | Saved by | Who is notified |
| --- | --- | --- |
| Opportunity published | `Company/Opportunities.aspx.cs` → `NotificationService.OpportunityPublished` | Eligible active students |
| Student applies | `ApplicationRepository.Submit` | Company supervisors of that company |
| Application accepted / rejected | `ApplicationRepository.Decide` | The student |
| Offer confirmed (placement) | `PlacementRepository.ConfirmAcceptedOffer` | Company supervisor, academic supervisor, coordinators |
| Group created / edited | `GroupRepository.SaveAssignments` | Added, removed and (if the supervisor changed) kept students; new and former academic supervisor |
| Task created | `TaskRepository.Insert` | The student |
| Task submitted / resubmitted | `SubmissionRepository.Insert` | The task's company supervisor |
| Task graded / revision requested | `EvaluationRepository.SaveTaskEvaluation` | The student |
| Academic comment (visible to student) | `AcademicCommentRepository.Insert` | The student |
| Hours reported | `HoursService.Report` | The academic supervisor |
| Hours approved / rejected | `HoursService.Decide` | The student |
| Company final evaluation submitted | `EvaluationRepository.SaveCompanyFinal` | Academic supervisor, coordinators |
| Academic final evaluation submitted | `EvaluationRepository.SaveAcademicFinal` | Coordinators |
| Completion approved / returned | `CompletionRepository.Insert` or `Save` | The student |
| Meeting scheduled | `MeetingRepository.Insert` | Every participant except the creator |

Final evaluation forms are confidential, so students are told only about the
released result, never about the forms.

## For teammates finishing a card

- Save through the repository method above (for example `new TaskRepository().Insert(task)`)
  and the notification is sent automatically. Do not write to `notifications/` yourself.
- For a new kind of event, add one method to `Services/NotificationService.cs`
  and call it after your save succeeds.
- A failed notification is only logged; it never stops the save.
- Nobody is notified about their own action.

## Known gaps

- Contact Us messages come from visitors who are not signed in, and the rules
  only let signed-in users write notifications, so coordinators are not notified
  about new contact messages.
- `Company/Tasks.aspx`, `Company/TaskReview.aspx`, `Coordinator/CompletionReview.aspx`
  and the Meetings pages do not save yet.
  Their notifications start working as soon as they save through the methods above.
