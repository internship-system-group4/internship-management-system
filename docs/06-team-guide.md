# Team guide

| Folder | Purpose |
| --- | --- |
| `Pages/` | Role-based pages; `Default.aspx` is the public home page. |
| `Models/` | Shared PascalCase data contract. |
| `Data/` | Repositories and synchronous Firebase REST plumbing. |
| `Services/` | Authentication, grading, hours and report helpers. |
| `Security/` | Role base pages and session handling. |
| `Common/` | Constants, enums, time and validation helpers. |
| `Layout/` | Shared master pages and navigation. |
| `Assets/` | CSS, scripts and images. |
| `Properties/` | Assembly metadata. |
| `docs/` | Team guides and development seed data, outside the web project. |

**THE RULE:** write in exactly two files: your own `page.aspx` and `page.aspx.cs`.
If a query is missing, **add a new method** to the relevant repository; never
change an existing method. `Models`, `Security`, `Common` and `Layout` are
read-only to page owners. Ask Ahmad for foundation changes. All pages are already
registered: leave `.designer.cs` generation to Visual Studio and coordinate any
project-file changes.

## Repository calls

Example using `CompanyRepository`:

```csharp
var companies = new CompanyRepository();
string id = companies.Insert(new Company { Name = "Demo Company" });
Company company = companies.GetById(id);
var all = companies.GetAll();
var matching = companies.GetWhere("Name", "Demo Company"); // Needs a Name index.
companies.Update(id, new Dictionary<string, object> { { "Address", "Amman" } });
companies.Delete(id); // Only when the page's action is deletion.
```

Accounts use `AuthService.CreateAccount`, then `UserRepository.SavePerson` with
the returned UID. Placements use `Confirm(studentUid, placement)`,
`Exists(studentUid)` and `GetById(studentUid)`; never `Insert` or `Save`.
`AcademicCommentRepository` stores ongoing comments; final evaluation comments
remain the end-of-internship summary. Student pages show only visible comments.

## Empty page skeleton

Keep the existing markup's `Inherits` and the code-behind namespace identical.
Use `StudentPage`, `CompanyPage`, `AcademicPage` or `CoordinatorPage` as appropriate.

```csharp
using System;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class MyTasks : StudentPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            // Load this student's data using CurrentStudent.Id.
        }
    }
}
```

Login calls `AuthService.SignIn` (which stores both tokens), checks `Success`,
loads and validates the profile, then calls `SessionHelper.SignIn(person, result.IdToken)`.
Protected pages handle expired refresh tokens automatically. Keep page events synchronous.
