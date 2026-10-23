# Email notifications

UIMS sends transactional emails after successful repository writes. SMTP is disabled by default. No changes to Firebase collections or database rules are needed.

## Configure delivery

Add the `Email.*` entries from `InternshipManagementSystem/InternshipManagementSystem/App_Secrets.config.example` to your local, git-ignored `App_Secrets.config`.

| Setting | Value |
| --- | --- |
| `Email.Enabled` | Set to `true` after configuring the remaining settings. |
| `Email.ApplicationUrl` | Public URL of this application, for example `https://internships.example.edu/` or `https://example.edu/uims/`. Include any virtual directory. Email links use this setting, never the incoming request's Host header. |
| `Email.FromAddress` | Verified sender address accepted by your SMTP provider. |
| `Email.FromName` | Sender display name. |
| `Email.SmtpHost` | Provider's SMTP server. |
| `Email.SmtpPort` | Usually `587` for STARTTLS. |
| `Email.EnableSsl` | `true` for STARTTLS. `false` is intended for local mail capture or a trusted relay. Implicit TLS on port 465 is not supported by this transport. |
| `Email.SmtpUsername` | SMTP username, or empty for a relay that requires no credentials. |
| `Email.SmtpPassword` | SMTP password or provider-issued app password. Keep this only in the secrets file. |

Use an SMTP service that accepts username/password credentials or an authorized relay. Firebase Authentication password-reset emails remain managed by Firebase; these settings control application event emails.

Restart IIS Express or recycle the application after changing configuration. Ensure recipient accounts have valid `Email` fields and `IsActive = true`. Each recipient receives a separate message; addresses are never shared through To/CC lists.

## Events and recipients

| Event | Recipients |
| --- | --- |
| New task, or assignment to another student | Assigned student |
| New task submission or resubmission attempt | Placement's company supervisor |
| Task evaluation or revision request | Student |
| Company final evaluation changes from draft to submitted | Active coordinators and the assigned academic supervisor |
| Academic final evaluation changes from draft to submitted | Active coordinators |
| Completion enters `AwaitingCompanyEvaluation` / `AwaitingAcademicEvaluation` | Assigned company / academic supervisor |
| Completion enters `UnderCoordinatorReview` | Active coordinators |
| Completion approved or rejected | Student |
| Training hours reported | Assigned academic supervisor |
| Training hours approved or rejected | Student |
| New pending internship application | Active supervisors at that company |
| Application accepted or rejected | Student |
| Placement successfully confirmed | Student and assigned company and academic supervisors |
| Meeting created, details changed, or cancelled | Invited participants, excluding the creator |
| Meeting participant added or removed | Added participant receives an invitation; removed participant receives cancellation |

Final evaluation emails contain no scores, private comments, or attachments. Recipients follow a link and sign in to the application's existing protected pages. Student completion emails only announce the review outcome and link to progress.

## Integration and delivery behavior

`TaskRepository`, `SubmissionRepository`, `ApplicationRepository`, `HoursRepository`, `CompletionRepository`, and `MeetingRepository` inherit `NotifyingRepositoryBase<T>`. This covers `Insert`, `Save`, and `Update`. `EvaluationRepository` and `PlacementRepository.Confirm` have explicit hooks for their specialized writes. Page handlers should continue to use these APIs and should not send a second email themselves. Direct `FirebaseContext` writes bypass the hooks.

The task assignment, submission, task review, final evaluation, and several application pages are still scaffolded in this repository. Notifications are ready at the persistence boundary; those screens need their own workflow implementations before users can trigger those events through the UI. Completion decisions and meeting creation already use the notification-enabled save paths. No new evaluation-request screen is introduced: request emails follow the existing completion status values.

Draft saves and repeated saves of the same state do not send emails. An address is deduplicated within one event, inactive/missing users are skipped, and one invalid address or SMTP failure does not prevent other recipients from being attempted. These checks do not provide exactly-once delivery for concurrent requests or separately inserted duplicate records.

Delivery is synchronous and best effort, with a five-second SMTP timeout per recipient. A failed notification does not fail or undo the saved action. Failures are reported through `System.Diagnostics.Trace` using the exception type only; credentials and message contents are not logged. If the notification's previous-state read fails, the write still proceeds and the email is skipped to avoid a false transition. When disabled, notifications introduce no extra database reads. There is no durable outbox, automatic retry, delivery history, or email for older events when email is later enabled. Confirm provider acceptance in its delivery logs; an SMTP success does not guarantee inbox delivery.

## Verify locally

Build the solution, then run:

```powershell
./tests/Run-EmailNotificationsSmoke.ps1
```

The tests use an in-memory Firebase stand-in and a loopback SMTP capture server. They check event recipients, confidentiality, state changes, generated evaluation IDs, repeated-save suppression, failed writes, failed snapshot reads, SMTP rejection, and disabled mode without accessing real accounts or mailboxes.

For a deployment check, configure a local SMTP capture service or a provider sandbox, enable email in `App_Secrets.config`, and schedule a meeting or save a completion decision using test accounts. Verify the recipient and application URL in the captured email before using the production sender.
