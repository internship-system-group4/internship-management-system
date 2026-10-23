# University Internship Management System (UIMS)

An Orange Academy Group 4 course project for managing university internships. Students find opportunities and apply; company supervisors manage trainees and tasks; academic supervisors review progress and hours; coordinators manage accounts, placements, and completion.

## Technology and current state

| Part | Technology |
| --- | --- |
| Web UI | ASP.NET Web Forms, HTML, CSS, JavaScript, Bootstrap 5 |
| Server | C# on .NET Framework 4.7.2 |
| Identity | Firebase Authentication through REST |
| Data | Firebase Realtime Database through REST |
| Development | Visual Studio on Windows, IIS Express, NuGet |

The solution contains the shared architecture and 40 registered Web Forms pages. At present, the page code-behind files still contain `TODO` placeholders, so the folder and page names describe **intended features**, not completed screens. `StorageService.Upload` and the report/certificate generation methods also throw `NotImplementedException`. The grading, hours, authentication, repository, and access-control foundations have code, but a build or a rendered stub does not mean the full workflow is usable.

## Repository map

The two similarly named `InternshipManagementSystem` levels have different jobs: the outer one is the **Visual Studio solution folder**; the inner one is the **web application project**.

```text
internship-management-system/
├── .github/                         GitHub review ownership rules
├── .gitignore                       Local files and build outputs excluded from Git
├── .gitattributes                    Git file-handling settings
├── README.md                         Project overview and architecture (this file)
├── docs/                             Team, data, policy, and setup guides
└── InternshipManagementSystem/      Visual Studio solution
    ├── InternshipManagementSystem.sln
    ├── InternshipManagementSystem.slnx
    ├── packages/                     Restored NuGet packages; generated locally
    └── InternshipManagementSystem/  ASP.NET Web Forms web project
        ├── Assets/                   Browser-side CSS, JavaScript, and images
        ├── Common/                   Shared constants, enums, policy, utilities
        ├── Data/                     Firebase REST access and repositories
        ├── Layout/                   Web Forms master pages
        ├── Models/                   Users and internship domain records
        ├── Pages/                    Screens grouped by audience or feature
        ├── Properties/               Assembly metadata
        ├── Security/                 Session and page access checks
        ├── Services/                 Business operations shared by pages
        ├── bin/, obj/                Generated build output; ignored by Git
        ├── Default.aspx*             Public home page and its code-behind
        ├── Global.asax*              Application startup and error tracing
        ├── Web.config                ASP.NET and Firebase setting placeholders
        ├── Web.Debug.config          Debug configuration transform
        ├── Web.Release.config        Release configuration transform
        ├── App_Secrets.config.example Local Firebase settings template
        ├── packages.config           NuGet dependency list
        └── InternshipManagementSystem.csproj  Web project and file list
```

The `.sln` is the broadly compatible solution file; `.slnx` is its newer Visual Studio format. A local `internship-managment-system/` folder may also appear at the repository root. It is currently **untracked** and contains a `.slnx`, local `.vs/` state, a `packages/` restore, and generated `bin/`/`obj/` files; it is not the solution documented above. Visual Studio can also create `.vs/` folders beside a solution for machine-specific state.

### `docs/`: project and team reference

| File | Purpose |
| --- | --- |
| [01-university-rules.md](docs/01-university-rules.md) | Training requirements and grading assumptions; marks policy values still awaiting confirmation. |
| [02-data-model.md](docs/02-data-model.md) | Firebase node paths, fields, identifiers, relationships, and confidentiality rules. |
| [03-ownership.md](docs/03-ownership.md) | Developer ownership of pages and shared code. |
| [04-git-workflow.md](docs/04-git-workflow.md) | Branching, pull requests, and conflict handling. |
| [05-firebase-setup.md](docs/05-firebase-setup.md) | Firebase setup, database rules, indexes, and seed data. |
| [06-team-guide.md](docs/06-team-guide.md) | Team conventions and development guidance. |
| [07-github-for-beginners.md](docs/07-github-for-beginners.md) | Introductory GitHub workflow. |
| [08-run-on-windows.md](docs/08-run-on-windows.md) | Detailed Windows setup and troubleshooting. |
| [10-email-notifications.md](docs/10-email-notifications.md) | SMTP configuration, event recipients, delivery behavior, and offline notification checks. |
| [dev-users.json](docs/dev-users.json) | Example development database records; some IDs are placeholders, and this does not create Firebase Authentication accounts. |

### Web project folders

| Folder | What belongs there |
| --- | --- |
| `Assets/css/` | `site.css`, the shared styling used by the master pages and screens. |
| `Assets/js/` | `site.js`, shared browser behavior. |
| `Assets/images/` | Logo/favicon location; its `README.txt` explains the expected artwork. |
| `Common/` | `Constants` for routes, paths and session keys; `Enums` for stored statuses and roles; `GradingPolicy`, `Time`, and `Validators`. Enum numbers are persisted in Firebase, so changing their order changes stored meaning. |
| `Data/` | `FirebaseContext` makes authenticated REST calls; `Json` serializes data; `RepositoryBase<T>` supplies common CRUD; entity repositories own node paths and queries. `EvaluationRepository` handles task and final evaluation collections. |
| `Layout/` | `Public.master`, `Student.master`, `Company.master`, `Academic.master`, and `Coordinator.master` supply shared navigation and page chrome. |
| `Models/` | `Person` and its four role subclasses plus entities such as `Opportunity`, `InternshipApplication`, `Placement`, `InternshipTask`, `Submission`, `TrainingHoursEntry`, evaluations, and completion. `PersonFactory` reconstructs the correct subclass from a stored user record. |
| `Pages/` | The `.aspx` screens, grouped below. Each page generally has markup (`.aspx`), event-handling code (`.aspx.cs`), and a generated control declaration file (`.aspx.designer.cs`). |
| `Properties/` | `AssemblyInfo.cs`, the compiled assembly's identity and version metadata. |
| `Security/` | `SessionHelper` stores the signed-in user and token; `SecurePage` checks access during `OnPreInit`; role-specific base pages expose a typed current user. |
| `Services/` | `AuthService` calls Firebase Authentication; `GradingService` calculates scores; `HoursService` handles approval and totals. `StorageService` and `PdfReportService` define upload and document boundaries but their main generation methods are unfinished. |

### `Pages/`: screens by audience

| Folder | Intended screens and responsibility |
| --- | --- |
| `Public/` | About, contact form, and access-denied page for visitors. The root `Default.aspx` is the public home page. |
| `Account/` | Login, forgot password, and change password. |
| `Student/` | Dashboard, profile, opportunity list/details, application flow/history, assigned tasks, and progress. |
| `Company/` | Dashboard, company account, opportunities, applications, trainees, tasks/review, and final evaluation. |
| `Academic/` | Dashboard, account, student progress, and final academic evaluation. |
| `Coordinator/` | Dashboard, account, students, supervisors, groups, companies, placements, contact messages, and completion review. |
| `Meetings/` | Scheduling and listing meetings shared by signed-in roles; this feature is optional. |

`Pages/Student/` and similar folders use C# namespaces ending in `Area` (for example `StudentArea`). This prevents a page namespace from hiding a model class with the same name.

## How the application fits together

```text
Browser request to an .aspx page
    -> role page base in Security/ checks the session, current user, and role
    -> page code-behind handles the request and calls a Service or Repository
    -> Data/ repository maps a model to a Firebase node
    -> FirebaseContext sends JSON over the Realtime Database REST API
```

The `.aspx` file defines controls, its `.aspx.cs` handles events and data binding, and its `.designer.cs` declares controls for C#. A `Layout/*.master` file wraps pages with shared navigation. `Global.asax.cs` runs at application startup, selects TLS 1.2 for Firebase calls, and traces unhandled errors.

**Authentication and authorization:** `AuthService` talks to Firebase Authentication. Once login is implemented, the login page is intended to load `users/{uid}` through `UserRepository`, then store the person and ID token with `SessionHelper`. Protected pages inherit `StudentPage`, `CompanyPage`, `AcademicPage`, or `CoordinatorPage`; shared meeting pages use `AuthenticatedPage`. `SecurePage.OnPreInit` checks for a signed-in user, reloads the current account, checks whether it is active and must change its temporary password, then checks the allowed role before page handlers run. `Web.config` uses session-based application checks rather than ASP.NET Forms Authentication. Public and login pages inherit the normal `Page` class.

**Data access:** Firebase Realtime Database stores JSON under paths such as `users/{uid}`, `opportunities/{id}`, `applications/{id}`, and `placements/{studentUid}`. Pages should call a repository instead of writing Firebase paths themselves. `RepositoryBase<T>` handles common reads, inserts, updates, and deletes; specialized repositories add domain queries and constraints. `FirebaseContext` uses the session ID token for database requests and can retry once after token refresh. See [the data model](docs/02-data-model.md) for all collections, indexes, and field names.

**Internship lifecycle:** A student may submit multiple applications but has at most one placement. Confirming an accepted offer creates `placements/{studentUid}`; the placement ID links tasks, submissions, hours, evaluations, and completion. Submissions are separate attempts so revision history is preserved. `HoursService` approves or rejects reported hours and recomputes cached totals. `GradingService` combines task, company, and academic scores using `Common/GradingPolicy.cs`; those policy weights remain provisional. Final company and academic evaluations are confidential; the coordinator reviews completion and releases the outcome. The UI for many steps and report generation are still pending.

## Run locally

1. Install Visual Studio with **ASP.NET and web development** and the **.NET Framework 4.7.2 targeting pack**.
2. Open `InternshipManagementSystem/InternshipManagementSystem.sln` and restore NuGet packages. The existing `packages.config` lists the CodeDom compiler provider.
3. Copy `InternshipManagementSystem/InternshipManagementSystem/App_Secrets.config.example` to `App_Secrets.config` in the same folder and add your Firebase database URL and Web API key. Keep the real file out of Git. Follow [Firebase setup](docs/05-firebase-setup.md) for rules, indexes, and accounts.
4. Set the web project as the startup project and press **F5** to run with IIS Express. The entry page is `Default.aspx`.

The scaffold can build and render, but the login and many other page workflows still need implementation. Without Firebase settings, calls through `FirebaseContext` fail with “Firebase is not configured.” For setup details and common errors, use [Run on Windows](docs/08-run-on-windows.md).

## Working on this repository

Use [the ownership guide](docs/03-ownership.md) and [Git workflow](docs/04-git-workflow.md) when adding pages or changing shared code. `.github/CODEOWNERS` maps paths to reviewers. Keep `App_Secrets.config`, restored `packages/`, `.vs/`, `bin/`, and `obj/` out of commits. The `.csproj` explicitly lists Web Forms files, so new pages must also be added to the project.
