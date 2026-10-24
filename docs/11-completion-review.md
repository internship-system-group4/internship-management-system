# Completion review implementation and operation

Implemented 2026-10-23. The DOCX brief was unavailable in the workspace. The user's supplied requirements and existing application contracts were used, as expressly authorized. Compare against the original brief when it becomes available; no production data was manufactured or migrated by this change.

## Behavior

The coordinator queue supports search and workflow filtering, student numbers/programs, internship type, training status, evaluation status and completion status. The detail view shows both confidential submissions, their original scales, authors, dates and comments; task evidence; independently approved hours; outstanding requirements; verification evidence; audit history; and approved documents.

Choose a rule and save it before reviewing a previously unconfigured placement. Record traceable references for each applicable requirement and the documented prior school approval date. Save evidence verification separately before approving. Both forms must have actually been submitted by the assigned supervisors; a numeric zero is a valid score, whereas missing evidence has no numeric result. The company and academic final-evaluation pages were placeholders and now provide authenticated, assigned-supervisor submission forms. They accept each assessment's own score/maximum, or a documented evidence-only assessment. They do not claim to implement an official university rubric.

Approval, corrections and rejection are separate actions. Corrections and rejection require reasons and do not assign an academic failure. A rejected decision is final on this page. Corrections remain editable. Approved/rejected decisions and submitted final evaluations cannot be overwritten through these workflows. Existing legacy decisions, including historical academic Fail results, remain intact. The student's progress page shows correction/rejection reasons without exposing either supervisor form.

Only approval publishes the protected student report route and the separate coordinator certificate route. Both PDFs are checked for renderability before approval is saved and generated on demand using the existing PDF service. New approvals snapshot printable identity, program, company and dates. Supervisor comments, assessment documents, numeric component scores and verification references are excluded from both PDFs. No signatures or seals are fabricated. These are UIMS records; the university transcript and endorsed forms remain authoritative.

## Evaluation and training configuration

Only approved hour entries with a recorded reviewer, review timestamp and work date within the placement period count toward approval. Legacy entries missing that metadata require verification/correction through the explicit hours workflow; cached totals are not substituted. Task evaluations must reference the student's matching submitted work and be authored by the assigned company supervisor; finalized completion evidence is read-only.

`InternshipManagementSystem/InternshipManagementSystem/App_Data/completion-rules.json` is server-managed configuration, not a public upload. Each versioned rule specifies university, school, programs/course, internship type, method (`Weighted` or `EvidenceOnly`), source classification/reference, weights/passing criteria when applicable, hours/duration and evidence requirements with individual sources. University, school and program must match the student profile (case-insensitive). Profiles missing these fields produce an actionable configuration issue. Selecting a rule explicitly establishes the placement's internship type; legacy records are never silently assumed to be local training.

The supplied rule applies to School of Computing Computer Engineering/Computer Science local training. It combines verified local training conditions with an explicitly **Project-Proposed** 30/45/25 weighted assessment and 60% provisional criterion. It also proposes current grades for every assigned task, at least one assigned task, and an ended training period as application approval gates. Different task weights and task/final-assessment maximum scores remain supported. These criteria are not verified GJU grading policy. A passing calculation never changes completion status.

Missing/invalid configuration blocks approval with a message; it does not fall back to `Constants.DefaultRequiredHours`, student defaults or `GradingPolicy` constants. `EvidenceOnly` omits numeric scoring. A different internship type can configure hours, duration or both and its own evidence requirements. No official international/German Year rule is shipped because it has not been verified for this task. Add a verified/applicable profile before reviewing such placements. Do not copy the local 160-hour conditions into other profiles automatically. New rule versions require a new ID; selecting another rule invalidates previous confirmations. The saved rule is retained as the review's snapshot.

## Verified official sources and unresolved matters

The [School of Computing Local Training page](https://gju.edu.jo/content/local-training-14477), consulted 2026-10-23, supports:

- 160 contact hours, relevant to the specialization, over four continuous weeks in one approved company.
- Prior school/department approval, including the training duration.
- Permitted training periods and exclusion of overlapping calendar hours.
- Company eligibility, including the next-of-kin restriction and approval before a company change.
- Signed/stamped forms, the company's task list, training report review, department approval and dean endorsement.

These external conditions are represented by explicit manual evidence checks; the system cannot independently authenticate physical forms, academic calendars, kinship or university signatures. A checkbox with no reference is insufficient. The source contains conflicting eligibility statements (credit-hour thresholds versus zero credits); eligibility is unresolved and no numeric credit-hour threshold is enforced here.

The [general undergraduate grading page](https://gju.edu.jo/content/grading-system-undergraduate-programs-13655) distinguishes course and cumulative passing criteria. It does not establish this internship's assessment weights or threshold. No general undergraduate number is imported as internship policy. Official internship grading/rubrics, international duration rules and verification against the unavailable original brief remain unresolved.

## Additive Firebase changes and deployment

No existing collection or field is renamed. `CompletionStatus.NeedsCorrections = 6` is appended without changing old enum values. Completion records add `EvaluationRuleSnapshot`, nullable `ProvisionalScore`, `ProvisionalResult`, `Verifications`, `AuditTrail` and `DocumentSnapshot`. Verification entries retain requirement key, confirmation, evidence reference/date, coordinator ID and timestamp. The audit list records each configuration, verification and decision save. Existing four boolean fields remain readable for compatibility but are not treated as sufficient evidence for new approvals.

New completions and final evaluations use the placement ID as their deterministic key. Existing push-key records are reused. Completion records with duplicate placement IDs are blocked for manual reconciliation; do not delete historical decisions automatically. Pending legacy records need an explicit rule selection and evidence verification. No bulk migration is necessary. Existing approved documents without an identity snapshot retain their legacy rendering behavior; a trustworthy historical snapshot cannot be reconstructed automatically.

Firebase REST ETags protect each review/evaluation write against concurrent changes ([conditional requests](https://firebase.google.com/docs/database/rest/save-data#section-conditional-requests)). Postback versions also prevent stale browser forms from overwriting later decisions. The page's view state is session-bound. The secure base page refreshes role/activation before handlers run; repositories additionally restrict confidential reads and final submissions. Hours decisions require an assigned academic supervisor or coordinator and are locked after finalization.

**Before using this flow against shared data, merge the nodes in `docs/firebase-completion-rules.patch.json` into the database rules, replacing the corresponding development nodes rather than combining them with their permissive `.write`/`.read` grants.** Preserve unrelated collection rules and indexes. This file is a scoped merge fragment, not a complete application's rules file. Remove blanket ancestor access grants because they override child restrictions. The fragment scopes confidential queries/direct reads, restricts supervisor authorship, makes submitted evaluations/final decisions immutable, protects role/academic profile fields, constrains placement updates, and separates student hour reporting from reviewer approval. The first coordinator must already be provisioned by a trusted administrator.

Use the Firebase rules simulator/emulator to validate the merged rules with your real data before deployment. The local tests use a REST fixture, not a Firebase rules engine, and these rules have not been deployed or emulator-tested. Full authorization of unrelated collections remains outside this change. Existing legacy push-key completion records require particular attention because rules cannot look them up by arbitrary field; application checks handle them, while direct database finalization locks refer to deterministic completion keys and completed placement status. Keep production database access restricted during migration/reconciliation.

ETag operations are atomic per record. Reading evaluations, hours, placement and configuration and then approving is **not a cross-node transaction**. Submitted evaluations are immutable in the new workflow, and hours decisions are blocked after finalization, but concurrent administrative/evidence edits across different nodes still need operational coordination. The saved completion record is authoritative if the subsequent placement summary cache update fails; the UI reports that condition. A larger server-side transaction architecture would be needed for a single atomic snapshot across every source node.

## Changed files

Application files (all under `InternshipManagementSystem/InternshipManagementSystem/`):

- `Pages/Coordinator/CompletionReview.aspx`, `.aspx.cs`, `.aspx.designer.cs`
- `Pages/Company/FinalEvaluation.aspx`, `.aspx.cs`, `.aspx.designer.cs`
- `Pages/Academic/FinalEvaluation.aspx`, `.aspx.cs`, `.aspx.designer.cs`
- `Pages/Student/Progress.aspx`, `.aspx.cs`, `.aspx.designer.cs`
- `Common/Enums.cs`, `Models/CompletionRecord.cs`, new `Models/CompletionRule.cs`
- `Data/FirebaseContext.cs`, `Data/CompletionRepository.cs`, `Data/EvaluationRepository.cs`, new `Data/CompletionRuleRepository.cs`
- New `Services/CompletionReviewService.cs`, `Services/HoursService.cs`, `Services/PdfReportService.cs`, `Services/EmailNotificationService.cs`
- New `App_Data/completion-rules.json`, `InternshipManagementSystem.csproj`

Tests/documentation: new `tests/CompletionReviewSmoke.cs` and `tests/Run-CompletionReviewSmoke.ps1`; updated notification fixtures/runner; `docs/01-university-rules.md`, `docs/05-firebase-setup.md`; this document and the rules fragment. Pre-existing unrelated workspace changes were preserved.

## Verification

Build with Visual Studio MSBuild, then run `tests/Run-CompletionReviewSmoke.ps1`, `tests/Run-GradesExportSmoke.ps1` and `tests/Run-EmailNotificationsSmoke.ps1`. IIS tests use disposable web roots, synthetic fixtures and loopback ports; they never read production credentials or write production Firebase. Notification tests use an isolated SMTP fixture only.

The completion suite covers all 14 requested scenarios, including Web Forms saves, submitted-versus-draft evidence, independent approved hours, missing documents/prior approval, required reasons, corrections without released documents, rejection without academic Fail, finalized/duplicate decisions, role restrictions, confidential student views, encoded unsafe data, different training requirements, missing configuration, immutable PDF identity snapshots, stale forms and REST ETag conflicts. Both supervisor submission forms are also posted through IIS. Sample report/certificate pages are inspected visually. Browser screenshots, a deployed Firebase rules evaluation and comparison against the original DOCX are not claimed.

Results: solution build succeeded without warnings; completion suite **53 checks passed**; existing grades/export suite **85 passed**; notification suite **55 passed with email enabled / 31 passed with email disabled**; changed JSON parsed successfully; `git diff --check` passed. All SMTP messages stayed inside the local fixture.
