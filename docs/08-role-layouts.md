# Shared navigation for each role

Each role owns its navigation in a separate master page. Individual pages use
their role's master and do not duplicate the sidebar.

| Role | Master page | Page folder |
| --- | --- | --- |
| Student | `Layout/Student.master` | `Pages/Student` |
| Company supervisor | `Layout/Company.master` | `Pages/Company` |
| Academic supervisor | `Layout/Academic.master` | `Pages/Academic` |
| Coordinator | `Layout/Coordinator.master` | `Pages/Coordinator` |

Change a role's menu in its master. Each master's code-behind sets active links,
renders account information and handles logout. Apply highlights My Applications;
Opportunity Details highlights Explore Opportunities; Trainee Details highlights
My Trainees; Placement Details highlights Placements & Progress. Schedule a
Meeting highlights Meetings.

All four masters load `Assets/css/portal-layout.css` and
`Assets/js/portal-layout.js`. These are the renamed shared assets previously
called student-layout.css and student-layout.js. The approved GJU palette, logo,
typography and responsive behavior are consistent across roles. At 900px and
below, the hamburger opens an accessible drawer with focus trapping, Escape,
backdrop close and focus return. Without JavaScript, navigation stays expanded.

Meetings pages are shared by signed-in roles. After the normal authentication,
account and password checks, `AuthenticatedPage.OnPreInit` selects the current
role's master specifically for `Pages/Meetings/`. Change Password and public
pages keep the public layout. Page-role authorization is unchanged; hiding a
menu link does not grant access to another role's page.

## Local verification

Use the disposable test host and simulation described in 06-application-form.md.

```powershell
playwright-cli run-code --filename tests/role-layouts.browser.js
```

The test adds synthetic academic/coordinator profiles to the local simulation
only. Its 164 assertions cover 39 page visits across all roles, active links,
the correct role menu, shared meetings, desktop/mobile layouts, Escape close,
logout and wrong-role redirects. Screenshots are written to ignored
`tests/artifacts/`. Page bodies owned by teammates remain their existing
implementation or placeholder; this change provides their shared shell.

After running the test, local fixture entry points are:

- Student: `/__fixture.aspx?user=student-one`
- Company: `/__fixture.aspx?user=supervisor-one`
- Academic: `/__fixture.aspx?user=academic-one`
- Coordinator: `/__fixture.aspx?user=coordinator-one`

These sign-in fixtures exist only in the temporary test copy, not the real app.
Live Firebase integration still requires the team's configured accounts.
