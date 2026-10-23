# UIMS missing-page response

`Pages/Public/NotFound.aspx` is a public, session-free Web Forms document. It returns 404 even when opened directly. It uses the existing `L` resources, local Noto fonts, UI tokens, Light/Dark theme controller and language control. It does not use the public master, Firebase, Bootstrap's CDN, the footer map, campus runtime, video or React.

The original React composition is adapted as a large 404, expanding navy-tinted circles and three small students. The student symbol and route marks are original inline SVG alternatives; none of the reference's externally hosted SVG files are downloaded or used. Mobile renders one student and two circles. CSS animations run once for at most 2.1 seconds and the entrance class is removed at 2.2 seconds. The content is visible before any script runs. There is no canvas, frame counter, render loop or resize allocation. Reduced motion, backgrounding and page teardown settle immediately. Resize and orientation changes keep the relative SVG geometry without replaying the entrance.

## Response paths

- A managed `HttpException` with HTTP code 404 is internally transferred by `Global.asax` to the error page. The guard excludes assets, the error handler itself and repeated handling. The existing viewstate recovery and handling of other exceptions remain in place.
- Native IIS 404s, including unknown extensionless paths, use `system.webServer/httpErrors`, `ExecuteURL`, `errorMode="Custom"` and `existingResponse="Auto"`. The page sets 404, `TrySkipIisCustomErrors`, `nosniff`, `noindex` and `no-store`, so IIS keeps the custom response instead of replacing it or redirecting.
- Missing resources under `Assets/` use `PassThrough`: 404 without the HTML document. This avoids re-entering the error page for missing error-page CSS, scripts, logo or fonts. A missing script outside `Assets/` may receive the custom HTML body, but only with 404 and `nosniff`, never a successful JavaScript response.
- `L.SwitchUrl` and `L.HandleSwitch` use the validated original `RawUrl` path/query. IIS internally changes `Path` and `QueryString` to the handler URL and a `404;original-url` payload. Using `RawUrl` retains the real missing route, its query parameters and the single existing language controller. Nonlocal/ambiguous redirect paths fall back to application Home.

The primary action is an application-relative Home link. The secondary action starts as Contact (including without JavaScript). It becomes Go Back only with a same-origin referrer, an available history entry, a different pathname and no evidence that the previous page was another known 404. The validated referrer is never used as a redirect destination. A bounded per-tab list of missing paths prevents error-to-error back loops. No `returnUrl` is read by the page.

## Build, publishing and IIS

The Web Application project explicitly includes the page, its compiled code-behind, CSS and JavaScript. Existing global resources are already included by the project. Release and Debug transforms do not remove the new HTTP error configuration. There is no saved `.pubxml` profile in this repository. Standard Web Application publishing must include these registered content files and the rebuilt assembly; copying only the `.aspx` is insufficient.

Local verification uses IIS Express with ASP.NET 4.7.2 in an Integrated pipeline and the rebuilt application. Full production IIS is not available in this workspace. Deployment requires ASP.NET and permission to configure `httpErrors`. The current project runs at the site root. IIS `ExecuteURL` is server-relative: if published under an application alias such as `/uims`, change its configured path to `/uims/Pages/Public/NotFound.aspx`. Home, assets and other page links already use `ResolveUrl` and remain application-relative. Hosting-level request filters, proxies or custom error overrides must be checked in that environment; this change does not override authentication or access policies.

Microsoft IIS configuration reference: [HTTP Errors](https://learn.microsoft.com/en-us/iis/configuration/system.webserver/httperrors/) and [ExecuteURL paths](https://learn.microsoft.com/en-us/iis/configuration/system.webserver/httperrors/error).

## Verification

Run a disposable rebuilt host with `tests/Start-LoginTestHost.ps1` (the error page itself never calls its configured simulation). Add a test-only `__status.aspx` to that copy which returns 403 or 500 based on `?code=` and has a `<head runat="server">`. It must not be published. Open the host in Playwright CLI, then run `tests/not-found.browser.js`. The test covers missing `.aspx`, extensionless and static paths; original URL and real status; separate 403/500/auth redirects; safe navigation; theme/language/viewport combinations; 200% text size; reduced motion; JavaScript disabled; unavailable canvas; missing logo; backgrounding; and JavaScript errors separately from expected failed HTTP requests. Run `tests/i18n-behaviour.browser.js` against the same host for normal-page localization/postback/unsaved-input regression checks.

Artifacts are written under ignored `tests/artifacts/`. No production data, user documents, Git commits or remote branches are changed by these checks.

### Verified locally on 2026-10-23

Debug rebuild and Release build succeeded. WebPublish staging succeeded and contained the error page, its scripts/styles, compiled application, resources and transformed configuration.

| Request | Status | Body / redirect |
| --- | --- | --- |
| `/missing-uims-page.aspx` | 404 | Custom HTML; no Location; original URL retained |
| `/missing-uims-route` | 404 | Custom HTML; no Location; original URL retained |
| `/Assets/js/not-a-real-file.js` | 404 | Empty failed resource; no HTML |
| `/missing-uims-script.js` | 404 | Custom HTML with nosniff; not a successful script |
| `/Pages/Public/NotFound.aspx` | 404 | Custom HTML, even for direct access |
| Test-only 403 and 500 | 403 / 500 | Remain separate errors, not the 404 page |
| Anonymous Student dashboard | 302 | Existing sign-in redirect preserved |

`not-found.browser.js`: 82 checks passed. `i18n-behaviour.browser.js`: 26 regression checks passed, including language persistence, postback behavior and dirty-form confirmation. Light/Dark and English/Arabic were checked at 1440, 390 and 320 pixels. The screenshot matrix, desktop recording and phone recording are available in `tests/artifacts/not-found-*`.

### Files for this change

- `Pages/Public/NotFound.aspx` and `NotFound.aspx.cs`: lightweight public document and response metadata.
- `Assets/css/not-found.css` and `Assets/js/not-found.js`: responsive composition, finite animation and safe history behavior.
- `Global.asax.cs` and `Web.config`: managed and native 404 execution, resource exclusions.
- `Common/Localization.cs`: original URL/query handling shared by the existing language switch.
- `App_GlobalResources/Public.resx`, `Public.ar.resx`, `Shared.resx`, `Shared.ar.resx`: message, action and title translations.
- `InternshipManagementSystem.csproj`: compile and publish registration.
- `tests/not-found.browser.js`, `tests/not-found-recording.browser.js`, and this document: verification and deployment notes.

Other uncommitted language/theme/navbar edits predate this 404 task and are retained.
