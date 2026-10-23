# Arabic / English localization

UIMS runs in **English** (the default) and **Arabic**. Arabic renders right-to-left. The localization covers:

- the public site;
- sign-in, password recovery and password change;
- notifications;
- all four role portals (Student, Company Supervisor, Academic Supervisor, Internship Coordinator);
- meetings.

The stack is unchanged: ASP.NET Web Forms, Bootstrap 5, plain JavaScript and Firebase. No Firebase data or schema was changed for translation.

## How it works

| Piece | Where | What it does |
| --- | --- | --- |
| `Common/Localization.cs` (class `L`) | every request | Reads the `uims-lang` cookie and accepts only `en` or `ar`; any other value gives English. Sets `CurrentUICulture`/`CurrentCulture` to `en-US` or `ar-JO`. ar-JO keeps the Gregorian calendar, Latin digits and `.` decimals. `L.T("Area.Key")` reads a resource; `L.F(...)` formats one; `L.Value(group, stored)` labels a stored value; `L.Role(...)` labels a role. Also provides `L.ScriptDictionary()` for scripts and the gap recorder. |
| `Global.asax.cs` | `BeginRequest`, `PreRequestHandlerExecute` | Handles a `?ui-lang=xx` switch: saves the cookie and 302-redirects to the same path and query without `ui-lang`. Then applies the culture before the page runs, and localizes `<title>`. |
| `App_GlobalResources/<Area>.resx` + `<Area>.ar.resx` | Shared, Home, Public, Account, Student, Company, Academic, Coordinator, Meetings, Workspace | Stable semantic keys, for example `Student.MyTasks.SubmitTask`. These files are **generated**; do not edit them by hand. |
| `tools/i18n/strings/<Area>.txt` | source of truth | One block per key: `Key`, then `en:`, then `ar:`. Values keep their edge spaces. |
| `tools/i18n/memory.txt` | translation memory | The same English text gets the same Arabic everywhere, unless an entry has its own `ar:`. |
| `tools/i18n/build-resources.py` | developer tool | Writes the resx pairs and csproj entries. It reports entries that have no Arabic, bad keys, and duplicates (resource keys ignore case). |
| `tools/i18n/localize-markup.py`, `localize-code.py`, `logical-css.py` | developer tools | Move hard-coded text out of markup and C# UI sinks, and convert physical CSS to logical properties. All three are idempotent and accept `--check`. |
| `Layout/LanguageSelector.ascx` | public navbar, public mobile menu, portal header, portal drawer (≤900px) | Plain links named **English** and **العربية**, never flags. Each one opens the same page with `?ui-lang=xx`. |
| `Assets/js/i18n.js` | every master | Unsaved-changes guard: if a form was edited, switching language asks first. Also sets `dir="auto"` on free-text fields and on Latin-only text blocks in Arabic (user content). |
| `Assets/css/i18n.css` | last stylesheet in every master | Selector styles, Arabic typography (Noto Sans Arabic, no letter-spacing or uppercase, taller headings), LTR email/URL/phone fields, RTL drawer, script-positioned markers, mirrored directional arrows. |
| inline `<script>` in each master | `<head>` | `window.UIMS_I18N` (the Shared `Js.*` keys in the current language), `window.uimsT(key, ...args)` and `window.uimsLang`. |

Each master writes `<html lang dir>` on the server, so direction applies before first paint. It loads exactly one Bootstrap build: `bootstrap.rtl.min.css` in Arabic, `bootstrap.min.css` in English.

### Switching language
- The switch is a **GET link**, separate from every form. Switching after a postback opens the page fresh; the POST is never replayed (tested).
- If a form has unsaved changes, `confirm()` asks first in the current language. Cancel keeps the page and its input.
- The cookie `uims-lang` is first-party, HttpOnly, SameSite=Lax and lasts one year. The choice survives reload, navigation, postbacks, sign-in and sign-out (tested).
- The redirect only ever targets the same path. Other query parameters are kept as they were.

### What is never translated
- **Stored business values:** role ids, status codes, enum values, keys, URLs and permissions. The page translates only the displayed label (`L.Value`). For example, `<option value="On-site">` keeps its value, and only its text becomes «حضوري».
- **User-generated content:** names, cover letters, feedback, messages, opportunity titles and descriptions. It is shown as stored, with `dir="auto"`.
- **Firebase field names and query keys.**

## RTL rules applied
- **Layout:**
  - layout CSS uses logical properties (`margin-inline-start`, `inset-inline-end`, `text-align: start`, …), converted mechanically so LTR renders the same;
  - the portal sidebar sits on the right in Arabic and the mobile drawer slides in from the right;
  - the journey, KPI cards, tables and forms follow the reading direction.
- **Mirroring:**
  - only directional arrows/chevrons are mirrored;
  - logos, photos, video, the 3D campus and hall, and charts are not mirrored, and no whole-page `scaleX(-1)` is used;
  - chart data is not reversed.
- **Keyboard:** in Arabic, ArrowLeft moves to the next tab and the next chart range.
- **Typography:**
  - Noto Sans Arabic is the local font already in `ui-tokens.css`;
  - Arabic gets no letter-spacing and no uppercase, and headings get `line-height: 1.4` so diacritics are not clipped;
  - emails, URLs and phone numbers stay LTR.
- **Dates and numbers:**
  - the server and charts use `ar-JO` with the Gregorian calendar and Latin digits, so month names are Levantine («تشرين الأول»);
  - machine formats (ISO dates, `dd/MM/yyyy` in stored data, UTC) are unchanged.

## Glossary

| English | Arabic |
| --- | --- |
| Student | الطالب |
| Company Supervisor | مشرف الشركة |
| Academic Supervisor | المشرف الأكاديمي |
| Internship Coordinator | منسّق التدريب |
| Internship / training | التدريب |
| Internship opportunity | فرصة تدريب |
| Placement | جهة التدريب |
| Application | الطلب |
| Offer / confirm offer | العرض / تأكيد العرض |
| Task / submission / attempt | المهمة / التسليم / المحاولة |
| Revision requested | مطلوب تعديلها |
| Training hours / approved hours | ساعات التدريب / الساعات المعتمدة |
| Final evaluation | التقييم النهائي |
| Completion (approval) | إنهاء التدريب (اعتماد الإنهاء) |
| Completion report | تقرير إنهاء التدريب |
| Dashboard | لوحة التحكم |
| Group / assignment | المجموعة / الإسناد |
| Pending (application) | قيد المراجعة |
| Accepted / Rejected / Withdrawn | مقبول / مرفوض / مسحوب |
| Confirmed / Active / Completed / Cancelled (placement) | مؤكَّد / نشط / مكتمل / ملغى |
| On-site / Hybrid / Remote | حضوري / مدمج / عن بُعد |
| Log in / Log out | تسجيل الدخول / تسجيل الخروج |
| German Jordanian University | الجامعة الألمانية الأردنية |

## Coverage inventory

The table counts keys with English and Arabic (2,686 in total). There are **no missing Arabic entries** (`build-resources.py` reports 0).

| Area | Keys | Covers |
| --- | ---: | --- |
| Shared | 336 | masters, sidebar, header, selectors, roles, status vocabulary, page titles, script (`Js.*`) messages, charts |
| Home | 84 | home page |
| Public | 166 | About, Contact (incl. server messages), Powered by, Access denied |
| Account | 76 | Login, Forgot password, Change password, Notifications, Completion report page, sign-in service messages |
| Student | 426 | dashboard, opportunities, details, apply, applications, tasks, progress, profile, CV & portfolio |
| Company | 541 | dashboard, opportunities (add / manage / view), applications, trainees, tasks, review, final evaluation, account |
| Academic | 121 | dashboard, student progress, final evaluation, account |
| Coordinator | 630 | dashboard, students (incl. creation), companies, academic supervisors, groups, placements, completion review, contact messages, account |
| Meetings | 72 | my meetings, schedule |
| Workspace | 234 | dashboard journeys, KPI cards, chart titles, categories, units and record details (shared by all four roles) |

**At runtime, missing text is recorded, not hidden.** Each page writes `<script type="application/json" id="uims-i18n-gaps">` listing any key that fell back to English. The route test asserts that this list is empty on every route.

### Limitations and known gaps
1. **The completion report and certificate PDF stay English.**
   - `PdfReportService` writes PDFs by hand with the base-14 fonts. These fonts cannot shape Arabic (no glyphs, no joining, no bidi).
   - The working English PDF is kept as the fallback, and the Arabic interface links to it under Arabic labels.
   - Arabic PDFs would need an embedded Arabic font and a shaping engine.
2. **Stored notifications are not translated.** `NotificationService` saves the notification text when the event happens, so notifications appear in the language they were created in (English). New notifications could store a key plus arguments instead; that is a data-format change, so it was left out.
3. **Exception details stay as returned.** Messages such as «تعذّر تحميل المتدرّبين: {0}» put the raw `ex.Message` from Firebase or .NET in `{0}`.
4. **Plurals are simple.** Count phrases use one plural form («3 طلبات», «1 طالب»). Arabic dual and 3–10/11+ forms are not modelled.
5. **Scene text stays as part of the scenes.** Signage in the 3D campus and the lecture hall is not translated. Their status text and controls are translated.
6. **No captions were added to media.** The About film has no captions or transcript in either language, and none were invented. Its controls and overlays are translated.
7. **A raw `<` in the query string, for example `?ui-lang=<script>`, returns ASP.NET's request-validation error (500).** This is the platform's standard behaviour for any page.
8. **Three small overflows remain. All were there before this work:**
   - Company → Final evaluation at 320px (10px, was 24px): the "My Drafts" and "Send Evaluation" buttons do not wrap;
   - Company → Final evaluation at 390px (2px, in both languages): the page enlarges the header avatar;
   - Coordinator → Companies at 320px (5px, was 11px): the "Add Supervisor" button does not wrap.

   Every other 320px overflow, present before on all portal pages, is fixed: the portal header now lets the title give way below 360px.
9. **Two older browser tests are stale and fail on the committed build too:**
   - `tests/public-contact.browser.js` expects the pre-redesign label "Full name *";
   - `tests/sidebar-encoding.browser.js` expects the student sidebar to start collapsed.

   `tests/login-campus*.browser.js` now block `login-campus-scene.js*`, so the fallback test still works with the cache-busting query.

## Verification

All tests ran against the disposable host (`tests/Start-LoginTestHost.ps1`, port 57992) and the Firebase simulation (`postman/simulations/campus-login.sim.yaml`, port 4910). Writes went only to the simulation, which is reset before each suite. No live service was written to, and no password-recovery email was sent.

| Suite | What it checks | Result |
| --- | --- | --- |
| `tests/i18n-routes.browser.js` | 47 routes × EN/AR × 1440 / 390 / 320px, as the right role for each route. Checks HTTP 200, `lang`/`dir`, no server error, the gap list, horizontal overflow and page errors. | 282 page loads: all HTTP 200 with the right `lang`/`dir`, **0 missing translations**, 0 server errors, 0 page errors. Overflow only on the pre-existing items in limitation 8. |
| `tests/i18n-behaviour.browser.js` | See the list below. | 21 / 21 pass |
| `tests/i18n-english-baseline.browser.js` + `tools/i18n/compare-english.py` | English screenshots of the committed build (`git archive HEAD`, port 57993) against the working copy. | At 390px, 13 of 13 screenshots are pixel-identical. At 1440px, every difference is inside the header band where the language control was added, except a 372×58px anti-aliasing difference around the "Score Summary" button on Company → Final evaluation (identical markup). Two English regressions found by this check were fixed: the role label "Internship Coordinator" and the sidebar tooltip "My account". |
| Regression suites | theme, contact-page, public-contact, about-page, public-footer, footer-campus-map, login-campus, login-campus-lifecycle, sidebar-encoding, team-hall-experience | theme 43, contact-page 53, about-page 66, public-footer 139, footer-campus-map 29, login-campus 40, login-campus-lifecycle 8, team-hall-experience 134: all pass. `sidebar-encoding` and `public-contact` fail in the same way on the committed build, so they are stale tests and not regressions (see below). |

`tests/i18n-behaviour.browser.js` checks:
- English is the default, and exactly one Bootstrap build loads;
- the selector names the other language;
- after a POST, switching is a GET and the POST is not replayed;
- the same page and its safe query are kept;
- the cookie flags;
- Arabic client validation messages;
- the dirty-form confirmation, both cancel and accept;
- the choice survives sign-in, a portal postback and sign-out;
- the sidebar sits on the right in Arabic, and the role label reads «الطالب»;
- invalid cookie values fall back to English;
- there are no page errors.

Screenshots are in `tests/artifacts/i18n/` (generated, not committed):
- `light/` and `dark/` hold paired `en-*` / `ar-*` captures at 1440 and 390px of Home, About, Contact, Powered by, Login and the four dashboards;
- `english-before/` and `english-after/` hold the English baseline pairs;
- `recording/` holds the language-switching walkthrough (WebM).

## Adding or changing text
1. Write markup and code with `<%: L.T("Area.Page.Key") %>` (or `<%$ Resources:Area, Page.Key %>` on server-control properties), `L.F(...)` for messages with values, `L.Value(group, stored)` for stored values, and `window.uimsT('Key')` in scripts. Script keys live in Shared as `Js.Key`.
2. Add the key to `tools/i18n/strings/<Area>.txt` with `en:` and `ar:`. Repeated English text can rely on `memory.txt`.
3. Run `python -I tools/i18n/build-resources.py`. It must report `0 without Arabic` and no problems.
4. Save `.aspx`, `.ascx` and `.master` files as **UTF-8 with BOM**. Without a BOM, ASP.NET reads the file as Windows-1252 and Arabic literals turn into mojibake.

## Changed files

- **New:**
  - `Common/Localization.cs`, `Layout/LanguageSelector.ascx`, `Assets/js/i18n.js`, `Assets/css/i18n.css`;
  - `App_GlobalResources/*.resx` (generated);
  - `tools/i18n/` (string sources, translation memory, build and extraction tools, `compare-english.py`);
  - `tests/i18n-*.browser.js` (routes, behaviour, English baseline, screenshots, recording);
  - this document.
- **Infrastructure:**
  - `Global.asax.cs` (culture, switch, titles);
  - the five masters (`lang`/`dir`, Bootstrap build, selector, script dictionary, gap list);
  - `Layout/Sidebar.ascx`;
  - the project file.
- **Text moved to resources:** every page and user control under `Pages/` and `Layout/`, the code-behind messages, and `Services/AuthService.cs`.
- **Dashboard data:** `Data/WorkspaceDashboardRepository.cs`, `Data/WorkspaceChartFactory.cs`, `Data/CoordinatorMonitoringRepository.cs`.
- **Scripts:** scripts with interface text now read it through `uimsT`. Charts and number/date formats use `uimsLang`, and arrow keys follow RTL.
- **CSS:** layout CSS uses logical properties (`tools/i18n/logical-css.py`). The portal header gets a ≤360px rule.
- **Encoding:** markup files that contain non-ASCII text are saved as UTF-8 with BOM.
- **Tests:** `tests/login-campus*.browser.js` route glob updated.
