# University Internship Management System (UIMS)

An electronic platform connecting a university with its students and with
companies: it publishes internship opportunities, handles applications, tracks
tasks, submissions, evaluations and training hours, and ends with the
university coordinator approving internship completion and issuing the official
report.

Course project — Orange Academy, Group 4, seven developers.

> **README owner: Sara Rajoub (card X05).** This file covers setup and running
> the project. Expand the feature sections as pages are completed.

---

## Technology

| Layer | Technology |
| --- | --- |
| Front end | HTML5, CSS3, JavaScript, Bootstrap 5 |
| Back end | C#, ASP.NET Web Forms, .NET Framework 4.7.2 |
| Database | Firebase Realtime Database (REST) |
| Authentication | Firebase Authentication (REST) |
| Design | Figma |
| Tasks | Trello |
| Version control | Git and GitHub |

No NuGet packages beyond the one already in `packages.config`: the Firebase
layer uses `HttpWebRequest` and `JavaScriptSerializer`, both built into .NET
Framework, so a fresh clone builds with nothing to install. The reasoning is in
[docs/04-git-workflow.md](docs/04-git-workflow.md).

## Roles

| Role | What they do |
| --- | --- |
| Student (trainee) | Browse eligible opportunities, apply, confirm one offer, receive and submit tasks, track grades, feedback and approved hours, download the completion report. |
| Company supervisor | Publish opportunities, accept or reject applications, assign and grade tasks, request revisions, complete the company's final evaluation. |
| Academic supervisor | Monitor assigned students, approve training hours, add academic comments, submit the final academic evaluation. |
| University coordinator | Create all accounts, assign students to academic supervisors, monitor everything, approve completion, issue the official report and certificate. |

## Running it

**Requirements:** Windows, Visual Studio 2019 or newer with the *ASP.NET and
web development* workload, .NET Framework 4.7.2 developer pack.

1. Clone the repository.
2. Open `InternshipManagementSystem/InternshipManagementSystem.sln`.
   (`InternshipManagementSystem.slnx` is the same solution in the newer format,
   which only recent Visual Studio versions can open — use the `.sln` if in
   doubt.)
3. Restore NuGet packages: right-click the solution → **Restore NuGet Packages**.
4. Configure Firebase — see [docs/05-firebase-setup.md](docs/05-firebase-setup.md).
   In short: copy `App_Secrets.config.example` to `App_Secrets.config` and fill
   in the database URL, the Web API key and the storage bucket.
5. Press **F5**. The site starts at `Default.aspx`.

Without step 4 the pages render but every Firebase call raises
*"Firebase is not configured"*.

## Project layout

```
InternshipManagementSystem/
└── InternshipManagementSystem/
    ├── Default.aspx              Home
    ├── Global.asax               app start-up (sets TLS 1.2 for Firebase)
    ├── Web.config                configuration; secrets live in App_Secrets.config
    ├── Layout/                   five master pages, one per audience
    ├── Security/                 SecurePage + one base class per role
    ├── Models/                   Person hierarchy and the domain entities
    ├── Data/                     Firebase REST client and the repositories
    ├── Services/                 auth, grading, hours, PDF, storage
    ├── Common/                   enums, constants, timestamps, validation
    ├── Pages/                    Public, Account, Student, Company, Academic,
    │                             Coordinator, Meetings
    └── Assets/                   css, js, images
docs/                             university rules, data model, workflow, setup
```

### How a page is protected

Pages inherit a role base class instead of `System.Web.UI.Page`:

```csharp
public partial class MyTasks : StudentPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // CurrentStudent is the signed-in trainee, already typed.
        // A supervisor who types this URL has already been redirected.
    }
}
```

`Security/SecurePage.cs` runs four checks before any page's `Page_Load`: signed
in, account active, temporary password changed, role allowed. Written once,
it protects all forty pages — which is what makes the requirement *"cannot open
another role's pages, including by typing a URL"* true everywhere rather than
in the places someone remembered.

### How a person is modelled

`Person` is abstract; `Student`, `CompanySupervisor`, `AcademicSupervisor` and
`Coordinator` inherit from it. Two members earn the hierarchy its place:
`DashboardUrl`, which turns post-login routing into one line, and `CanLogin()`.
All four are stored in one `users/{uid}` node and rebuilt into the right
subclass by `Models/PersonFactory.cs`.

## Documentation

| Document | Contents |
| --- | --- |
| [docs/01-university-rules.md](docs/01-university-rules.md) | The university's hours, approval process, evaluation criteria and weights. **Fill this in first** — the grading code reads its numbers from here. |
| [docs/02-data-model.md](docs/02-data-model.md) | Every Firebase collection and field. |
| [docs/03-ownership.md](docs/03-ownership.md) | Which developer owns which page. |
| [docs/04-git-workflow.md](docs/04-git-workflow.md) | Branching, pull requests, conflicts. |
| [docs/05-firebase-setup.md](docs/05-firebase-setup.md) | Console setup, security rules, indexes, seed accounts. |

## Working on this repository

- One page, one developer. See `docs/03-ownership.md`.
- One branch per Trello card: `feature/A01-login-page`.
- Pull requests go into `dev`; `main` stays demo-ready.
- Never commit `App_Secrets.config`, `bin/`, `obj/` or `packages/`.

## Status

Scaffold complete: solution, shared data model, role-based access control,
master pages, Firebase data layer, and all forty pages registered as stubs with
their owner and Trello card recorded in each file. Page implementation is in
progress — the placeholder block on a page means it has not been built yet.

[Trello board](https://trello.com/b/fUVGTBxk/internship-system-group4)
