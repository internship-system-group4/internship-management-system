# Arabic interface review

Reviewed on 24 October 2026 against the current Web Forms application, including the restored simple Academic dashboard.

## Changes

| Area | Correction |
| --- | --- |
| Academic | Translate the recent student-record filters and progress summary; retain the simple workspace. |
| Company | Localize task creation, submission review, evaluation tools, options, counters and feedback messages. |
| Coordinator | Translate account labels, completion review, placement summaries and recent dashboard copy. |
| Student | Localize task submission, resubmission, history, progress and completion messages. |
| Meetings | Translate requests, confirmations, dialogs, view options and displayed statuses. |
| Public and reports | Localize Journey, error-page copy, directory labels, report filters and missing page titles. |
| RTL | Use logical spacing/alignment in the recently changed pages and correct the standalone Journey's full-width origin. |

All UI text uses the existing `App_GlobalResources`, `L.T`/`L.F`, `L.Value` and `uimsT` implementations. Stored status values, filter values, command arguments, enum values and the Jordan time-zone identifier remain unchanged. Original resource wording was compared with the preceding revision and preserved. Names, record content and user-written feedback are not translated.

The resource source supports `\u0020` for significant trailing spaces, alongside the existing `\n` escape. This keeps message fragments accurate without trailing whitespace in source files.

## Verification

| Check | Result |
| --- | --- |
| Resource build | 3,888 entries across 10 areas; no missing Arabic translations. |
| Resource references | No unresolved static `L.T`/`L.F`/`L.H` references in the inspected UI sources. |
| Arabic route coverage | 58 role/route combinations at 1440px and 390px: 116 rendered checks. The missing Inbox title found in this pass passed a subsequent targeted check in both languages and sizes. |
| English regression coverage | Earlier paired run: 212 English/Arabic route checks at the same two widths, without unexpected HTTP errors, page script errors or document overflow. Custom error pages correctly return HTTP 404. |
| Open components and behavior | 57 assertions across Light/Dark and desktop/mobile, including task/submission filters, meeting dialogs, the coordinator account and the simple Academic workspace. |
| Language switching | Confirmed route/query preservation, saved preference, Arabic dirty-form confirmation and preservation of unsaved input when switching is cancelled. |
| Integration safety | Submission-status and status-CSS helper implementations match their prior versions; Arabic is applied only to displayed labels. |
| Build and source checks | Debug MSBuild, JavaScript syntax and `git diff --check` passed. |

Tests ran against a disposable IIS host and the existing local fixture service. Filter tests insert temporary DOM rows and do not create database records. Limited fixture data means this is evidence for the rendered states exercised, not a claim that every populated record, external meeting provider or production integration was tested.

The 56 UI routes include the Home page and the Student opportunities alias. Two document-serving endpoints (`ApplicantDocument.aspx` and `CompletionReport.aspx`) require authorized records; they were not treated as ordinary page screenshots. Exported PDF/workbook content and user-authored data are outside this interface translation pass. Native date-field notation follows the browser/OS locale.

## Reproduce

1. Start the existing disposable login fixture host with the local fixture service.
2. Run `tests/i18n-routes.browser.js` after setting its `base` URL to that host.
3. Open that host in Playwright and run `tests/i18n-recent-pages.browser.js`.
4. Run `python tools/i18n/build-resources.py --check` and build the solution.

Local screenshots and detailed outputs are under the ignored `tests/artifacts/` directory. No screenshots of production records or student documents are included.
