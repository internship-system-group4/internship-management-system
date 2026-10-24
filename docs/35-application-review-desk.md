# Company application review desk

The server renders only the current company's applications. A progressively enhanced
queue and detail pane keep all Web Forms controls inside their original server form.
Filtering and previous/next navigation operate on these authorized records only.
Rejection drafts remain in their original textareas; leaving a nonempty draft asks
for confirmation. No student data or draft text is stored in browser persistence.
After a successful decision, the search, status filter, and selected application
are restored from the authenticated server session. New decisions still use the
existing server-side company/application checks.

## Document contract

`Pages/Company/ApplicantDocument.aspx?id={applicationId}&type=cv|portfolio`
retains its company-role and application-ownership checks for every request.

| Mode | Local uploaded PDF | External document link |
| --- | --- | --- |
| Default | Inline PDF | Existing external redirect |
| `preview=1` | Inline PDF | Local explanatory HTTP 404; no external redirect |
| `download=1` | PDF attachment | Existing external redirect; external provider controls downloads |

The UI offers embedded preview and explicit download only when the effective CV
resolves to an uploaded local PDF. It lazily creates the preview request on demand.
The endpoint rechecks authorization and resolution independently of the UI flag.
Changes to a file or link after page load cannot bypass those checks. Non-embeddable
links retain the existing open-in-new-tab action; browser PDF support may vary.

Desktop keeps a nonmodal detail region beside the queue. Narrow/short viewports use
a full-screen dialog with focus containment, inert background, Escape/close, and
focus restoration. Without JavaScript, native disclosures and server actions remain.

Verification uses the disposable Web Forms host and existing local Postman Firebase
simulation with synthetic records/files; it does not establish live Firebase rule
correctness or third-party embedding support.

## Verification performed

| Check | Result in disposable environment |
| --- | --- |
| English/Arabic, Light/Dark, widths 320–1920px | 24 responsive layouts checked; no page overflow; decision actions visible |
| Review navigation | Filter boundaries, draft confirmation/preservation, mobile close/focus restoration, and no-JavaScript fallback checked |
| Actual Web Forms postbacks | Blank rejection validation, successful rejection with reason/owner, acceptance, and restored search/filter checked against simulated storage |
| Protected documents | Inline/download PDF, external preview denial, existing external open, company ownership, wrong role, and anonymous access checked using Postman |
| Source validation | Solution build, JavaScript syntax, resource completeness, and whitespace checks passed |

Browser screenshots use explicitly synthetic applicants. The local Firebase simulation
does not verify production credentials, deployment configuration, or production rules.
