# Notifications (top-bar bell)

Owner: Ahmad. Every portal (student, company, academic, coordinator) shows a
bell in the top bar with an unread badge and the latest 8 notifications.

- **Live:** `Assets/js/notifications.js` asks `Pages/Account/NotificationFeed.ashx`
  every 20 seconds, so a new notification appears without reloading the page.
- **Toast:** anything new and unread pops up as a card (category, title, clear
  message, **Open** button). It shows once per person per browser.
- **Click-through:** every notification opens the page where you act on it,
  for example the exact application (highlighted), task or submission.
  Clicking goes through `Pages/Account/Notifications.aspx?open={id}`, which marks it read.
- **Both languages:** each notification stores a `Key` (for example
  `ApplicationSubmitted`) and `Args` (names, titles). The text is
  `Notify.{Key}.Title` / `Notify.{Key}.Message` in `Shared.resx` and
  `Shared.ar.resx`, so each person reads it in their own language. The English
  text is also saved in `Title` / `Message` as a fallback.
- "View all notifications" opens `Pages/Account/Notifications.aspx` (latest 100,
  All / Unread filter, **Mark all as read**).

## Setup (once) - required

The `notifications` rule from `docs/05-firebase-setup.md` must be published in
**Firebase > Realtime Database > Rules**:

```json
"notifications": {
  "$uid": {
    ".read":  "auth != null && auth.uid === $uid",
    ".write": "auth != null"
  }
}
```

Without it Firebase refuses every notification. The app then:
- shows "Notifications are blocked by the Firebase database rules..." in the bell,
- shows a warning to coordinators in the bell,
- writes `[UIMS notifications] Firebase refused notification ...` to the Visual
  Studio **Output** window (Debug).

## What sends a notification

| Cycle step | Saved by | Who is notified | Opens |
| --- | --- | --- | --- |
| Student account created | `StudentCreation.ascx.cs` | The student (welcome) | Student profile |
| Opportunity published | `Company/Opportunities.aspx.cs` | Eligible active students | Opportunity details |
| Student applies | `ApplicationRepository.Submit` | All active supervisors of that company + the supervisor who posted it | Applications, card highlighted |
| Application accepted / rejected | `ApplicationRepository.Decide` | The student | My Applications, card highlighted |
| Offer confirmed (placement) | `PlacementRepository.ConfirmAcceptedOffer` | Company supervisor, academic supervisor, coordinators | Trainee / student / placement details |
| Group created / edited / deleted | `GroupRepository` | Affected students and academic supervisors | Dashboards |
| Task created | `TaskRepository.Insert` | The student | My Tasks, task opened |
| Task submitted / resubmitted | `SubmissionRepository.Insert` | The task's company supervisor | Review Submissions, submission opened |
| Task graded / changes requested | `TaskEvaluationRepository.Insert` (and `EvaluationRepository.SaveTaskEvaluation`) | The student | My Tasks, task opened |
| Academic comment (visible to student) | `AcademicCommentRepository.Insert` | The student | My Progress |
| Hours reported / decided | `HoursService` | Academic supervisor / student | Student progress / My Progress |
| Company final evaluation sent | `Company/FinalEvaluation.aspx.cs` (and `EvaluationRepository.SaveCompanyFinal`) | Academic supervisor ("your evaluation is due"), coordinators | Academic final evaluation opened / placement details |
| Academic final evaluation sent | `EvaluationRepository.SaveAcademicFinal` | Coordinators ("completion review needed") | Completion review for that student |
| Completion approved / returned / rejected | `CompletionRepository` | The student; on approval also both supervisors | My Progress / student pages |
| Meeting requested / accepted / declined / completed / cancelled | `MeetingRepository` | The other person | My Meetings |

Final evaluation forms are confidential, so students are told only about the
released result, never about the forms.

## For teammates

- Save through the repository method above and the notification is sent
  automatically. Do not write to `notifications/` yourself.
- For a new event: add a method to `Services/NotificationService.cs` that calls
  `Send(recipientId, type, "YourKey", "~/Pages/...", args...)`, and add
  `Notify.YourKey.Title` / `.Message` to **both** `Shared.resx` and `Shared.ar.resx`.
- A failed notification is only logged; it never stops the save.
- Nobody is notified about their own action.

## Known gaps

- Contact Us messages come from visitors who are not signed in, and the rules
  only let signed-in users write notifications, so coordinators are not notified
  about new contact messages.
- There is no scheduler, so there are no deadline reminders (for example
  "task due tomorrow"); notifications are sent only when someone saves something.
