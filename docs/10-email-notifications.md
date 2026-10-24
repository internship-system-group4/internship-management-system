# Notifications inside UIMS and by email

A successful workflow event creates an entry in `notifications/{recipientUid}/{id}` and, when enabled, attempts a separate SMTP email. Inbox delivery runs independently of `Email.Enabled` and of the recipient having an email address. A failed inbox write still allows the email attempt; a failed email leaves the inbox entry available. Neither channel rolls back the saved action.

## Gmail setup

Run from the repository root:

```powershell
./tests/Configure-GmailNotifications.ps1
```

The script asks for the sender address, application URL and a Google App Password using hidden input. It updates the ignored `App_Secrets.config`, preserving Firebase and other settings. It sends no test email. Restart IIS Express afterwards.

Google documents [Gmail SMTP with TLS on port 587](https://support.google.com/a/answer/176600) and [App Passwords](https://support.google.com/mail/answer/185833). Enable 2-Step Verification and create an App Password if the Google account permits it. Use the app password, not the ordinary account password. Some managed or protected Google accounts do not offer app passwords.

| Setting | Value |
| --- | --- |
| `Notifications.Enabled` | Defaults to `true`; the inbox works with email disabled. |
| `Email.Enabled` | `true` only after the sender and credentials are configured. Defaults to `false`. |
| `Email.ApplicationUrl` | Absolute application URL including a virtual directory. Local example: `https://localhost:44313/`. Use the public deployment URL when deploying. |
| `Email.FromAddress` | Gmail sender address, matching the authenticated account. |
| `Email.FromName` | University Internship Management System |
| `Email.SmtpHost` | `smtp.gmail.com` |
| `Email.SmtpPort` | `587` |
| `Email.EnableSsl` | `true` for STARTTLS. |
| `Email.SmtpUsername` | Full Gmail sender address. |
| `Email.SmtpPassword` | Google App Password, stored only in the ignored secrets file. |

The transport also supports another SMTP provider or local capture server. It uses STARTTLS rather than implicit TLS on port 465. Firebase password reset emails remain managed by Firebase.

## Firebase deployment required

Merge [firebase-notifications-rules.patch.json](firebase-notifications-rules.patch.json) into the existing rules, preserving other collections and grants. This is a fragment, not a complete replacement for the application's rules.

- Add `notifications/$uid` with recipient-only reads and `CreatedAt` indexing. Creation requires an active authenticated sender and active recipient. Existing content is immutable; recipients can mark their own entries read, and the recorded sender can update email delivery status.
- Add the `tasks/$taskId/Status` child grant. It permits the assigned student to transition Assigned → Submitted or RevisionRequested → Resubmitted. This child grant is needed with the stricter task rules in the completion rules fragment.
- Do not leave a broad `.read` or `.write` above the notification recipient node; Firebase grants cascade downward. Check the merged rules in the Firebase emulator or rules simulator before deployment.

The client uses the acting user's Firebase token, not an admin credential. Notifications are user-generated workflow notices; the rules enforce inbox isolation and field ownership but do not independently prove that every message corresponds to a domain event. Anonymous contact messages do not create cross-account notifications through this client-token mechanism.

Existing `Notification` entries with `Message` and `Link` remain readable. New entries also keep those compatibility fields. The latest 100 entries are returned and unread counts refer to that window.

## Events and recipients

| Event | Recipients |
| --- | --- |
| New task or reassignment | Assigned student |
| Task title, description, instructions or deadline changed | Assigned student |
| Submission or resubmission | Current placement company supervisor |
| Task grade or revision request | Student |
| Group assigned, membership changed or supervisor changed | Affected students and academic supervisors |
| Group removed | Its students and academic supervisor |
| Student academic supervisor changed directly through the user repository | Student, new supervisor and former supervisor as applicable |
| Placement confirmed | Student and assigned company and academic supervisors |
| Placement supervisor changed | Student, new supervisor and former supervisor |
| Placement cancelled | Student and assigned supervisors |
| New application | Active supervisors belonging to the application company |
| Application accepted or rejected | Student |
| Published opportunity through the opportunity screen | Eligible active students |
| Training hours reported | Assigned academic supervisor |
| Training hours approved or rejected | Student |
| Public academic feedback added or updated | Student; hidden comments produce no student notice |
| Company final evaluation submitted | Academic supervisor and active coordinators |
| Academic final evaluation submitted | Active coordinators |
| Completion awaits a final evaluation | Relevant assigned supervisor |
| Completion enters coordinator review | Active coordinators |
| Completion approved, rejected or returned for corrections | Student |
| Meeting request, acceptance, decline, cancellation or completion | Other party |
| Meeting details or participants changed through generic repository updates | Affected participants |

Final-evaluation emails and inbox entries contain no scores, confidential comments or attachments. Completion decisions link the student to their protected progress page and approved report. Each email has a plain-text version, a styled HTML version and a sign-in link. Dynamic content is escaped.

## Integration

`NotifyingRepositoryBase<T>` covers successful `Insert`, `Save`, and `Update` calls. Specialized conditional writes in applications, placements, evaluations and completion review have explicit post-save hooks.

Each event writes exactly one inbox entry. For the events listed in `docs/23-notifications.md` (new task, submission/resubmission, grade/revision request, application, decision, placement confirmation, visible academic comment, hours, final evaluations), `Services/NotificationService.cs` writes the bilingual entry with a deep link, and this service sends only the email (`EmailNotificationService.Saved(previous, current, writeInbox: false)`, or a repository's `SendNotice` override returning true). Other events (task edits and reassignment, supervisor changes, placement cancellation, completion waiting states, generic meeting edits) keep this service's English inbox entry plus the email. `EmailStatus` is recorded only on this service's own inbox entries.

Group changes, published opportunities, the student welcome, meeting requests and replies, completion decisions and the company final evaluation page are handled by `NotificationService` alone: it saves the bell notice and then emails the same English text through `EmailNotificationService.EmailOnly` (one email per address per event, skipped when `Email.Enabled` is false or the person has no address). Completion emails to the student never contain the result or the coordinator's note; they use `Notify.CompletionApprovedNoResult`, `CompletionReturnedNoNote` or `CompletionRejectedNoNote`. Publishing an opportunity emails every eligible student while the page waits (up to five seconds per address if SMTP is slow).

`TaskWorkflowService` handles assignment authorization, submission attempts, rubric-weighted evaluation and revision requests. Each submission/review and its status changes use a single Firebase multi-path PATCH. Earlier attempts are retained. Browser retries within one application instance are serialized and already-submitted/reviewed states are rejected. Multiple worker processes still need distributed idempotency before claiming exactly-once behavior.

Avoid adding a second page-level notification when the repository already dispatches the event. Arbitrary direct Firebase writes bypass the event policy.

## UI

All four role master pages use the live activity bell. It provides unread counts, All/Unread filters, mark-all-read, local timestamps, accessible focus states, Escape dismissal, and refresh every 30 seconds while the page is visible. The full inbox is `Pages/Notifications/Inbox.aspx`; previous inbox APIs remain scoped to the current account. Read changes use POST and a session CSRF token. Network failures show an explicit unavailable state.

## Delivery limits

Email is synchronous best effort, with a five-second SMTP timeout per recipient. `EmailStatus` is `Pending`, `Disabled`, `Sent`, `Failed`, or `Duplicate`. Sent means SMTP acceptance, not guaranteed inbox delivery. Entries are not retried automatically and enabling email later does not resend earlier notices. Confirm actual Gmail delivery using controlled test accounts after configuring the sender. Credentials and message content are not included in notification-service error logs.

Repeated saves of unchanged states do not emit another notice. Inbox recipients are deduplicated by user ID; email addresses are deduplicated within repository-dispatched events. There is no distributed exactly-once guarantee. Older events are not backfilled.

## Verification

```powershell
./tests/Run-EmailNotificationsSmoke.ps1
```

The suite runs four combinations of inbox/email enabled/disabled against an in-memory Firebase fixture and loopback SMTP capture server. It checks the task → submission → revision → resubmission → weighted grade cycle, history preservation, ownership restrictions, assignment changes, specialized application decisions, meeting responses, read flags, old-entry compatibility, HTML mail, confidentiality, failed writes and independent channel failures. It never accesses real Firebase accounts or real mailboxes.

Also build the solution and compile ASP.NET markup; ordinary MSBuild does not validate all Web Forms markup. Run the completion and export smoke suites when changing their shared repositories.
