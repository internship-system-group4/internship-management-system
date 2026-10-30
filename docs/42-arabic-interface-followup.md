# Arabic interface follow-up — 26 October 2026

Reviewed the current application after the latest `main` updates. The earlier
Powered by size adjustment remains in place.

## Corrections

- Localize the final-evaluation report's headings, actions, dropdown prompts,
  placeholders, empty feedback and validation alerts. Select trainees by their
  stable dropdown value rather than detecting the English word “Select”.
- Use the selected student's actual major in the report; the preview previously
  displayed Computer Engineering for every student. Keep score fractions LTR
  within the Arabic report, and allow its mobile footer actions to wrap.
- Translate opportunity activation messages, the inactive-opportunity labels,
  configured college/major display labels and the partner-company fallback.
  Checkbox values, saved statuses and form identifiers retain their original values.
- Translate grade-report scope, counts and loading errors, Journey's preview errors
  and deadlines, its configured specialization labels, and campus fallback messages.
- Add missing page-title keys for Submission details and Supervisor profile, and
  the shared JavaScript Edit label. Localize the submission breadcrumb.
- Correct meeting-table alignment and the trainee-card logical border. Prevent the
  student profile's Arabic document action from forcing a wider grid at 320px.

## Resource-source consistency

The committed resource files contained **1,029 keys absent from the generator's
source tables**. Regeneration from those tables removed translations already used
by the application. The source tables now preserve those existing English/Arabic
values, plus the 66 keys introduced by this follow-up. No pre-existing resource
value was changed or removed.

`tools/i18n/build-resources.py` now validates all areas before writing any file.
It refuses to erase keys absent from the tables, rejects missing Arabic and
mismatched format arguments, and makes `--check` detect stale generated resources.
`tools/i18n/check-references.py` checks static server/markup references, implicit
page-title keys and literal `uimsT` keys; dynamic key prefixes remain runtime checks.

## Verification

| Check | Result |
| --- | --- |
| Resource generation and synchronization | 5,029 keys across 10 areas; no missing Arabic or mismatched format arguments. |
| Static references | 360 application source files; no unresolved static references. |
| Page matrix | 390 rendered checks: 65 role/route states in English and Arabic at 1440, 390 and 320px. No unexpected HTTP errors, missing resources, script errors or document overflow. |
| Additional page coverage | The development-only DemoStudent page and localized refusal states for ApplicantDocument and CompletionReport were checked separately. Together these cover all 61 `.aspx` paths. |
| Existing interaction checks | 57 assertions passed for Arabic filters, task creation, meetings, account pages, themes, language switching and unsaved-form protection. |
| Follow-up interaction checks | 82 assertions passed for localized report/certificate previews, actual student majors, unchanged option values, viewport fit, configured-major labels, breadcrumbs and protected-document messages in both languages at desktop/mobile widths. |
| Generator regression tests | Three tests passed, including refusal to partially write files when source tables would delete existing keys. |
| Build | Debug MSBuild succeeded; existing CS0108 warnings in Company Opportunities remain. |
| Source hygiene | JavaScript syntax and `git diff --check` passed. |

The browser run used a disposable IIS copy and the existing Postman campus-login
simulation with synthetic four-role fixture data. External requests were blocked;
Bootstrap CSS/JS requests were served from the repository's existing Bootstrap
assets. No production records were edited. Screenshots and detailed local results
are in ignored `tests/artifacts/arabic-review-20261026/`.

The mechanical design scan reports existing type/palette advice, Georgia declarations
overridden by the shared Noto font, and the retained trainee-card accent. This was a
language/layout refinement, not a redesign of those surfaces.

Coverage establishes the rendered fixture states and the interactions listed above.
It does not validate every production record, native date-input locale, external
document provider, generated PDF/workbook, or all possible validation branches.

## Reproduce

```powershell
python -X utf8 -I tools/i18n/build-resources.py --check
python -X utf8 -I tools/i18n/check-references.py
python -X utf8 -I tests/i18n-resources.test.py
```

For browser checks, start `postman/simulations/campus-login.sim.yaml` on 4910,
then `tests/Start-LoginTestHost.ps1 -Port 57992 -SimulationPort 4910`. Seed the
synthetic data in `tests/redesign-fixture.browser.js`, overriding its database URL
to `http://localhost:4910/firebase` in the test invocation. Open the disposable host
and run `tests/i18n-routes.browser.js`, `tests/i18n-recent-pages.browser.js`, and
`tests/i18n-complete-review.browser.js`. The interaction tests navigate and exercise
local UI/selection postbacks without saving evaluations, certificates or forms.
