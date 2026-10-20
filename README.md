# University Internship Management System (UIMS)

UIMS is a university team project intended to connect students, company supervisors, academic supervisors, and university internship coordinators throughout the internship process.

## Project overview

The repository currently contains an initial C# ASP.NET Web Forms project targeting .NET Framework 4.7.2. It is a project scaffold; internship workflows and user-facing pages are not yet present in the version-controlled source.

## Project objectives

- Provide a shared place for the four internship roles to participate in the process.
- Support coordination and progress tracking as the application is developed.
- Build the planned experience on the existing Web Forms project without changing its current structure.

## User roles

| Role | Planned involvement |
| --- | --- |
| Student | Participate in and track an internship. |
| Company Supervisor | Supervise the student's work at the company. |
| Academic Supervisor | Provide academic oversight. |
| University Internship Coordinator | Coordinate the university internship process. |

These roles describe the project scope; role-based functionality has not yet been implemented in this repository.

## Main features

The intended areas are internship coordination, supervision, and progress tracking. Specific workflows and screens are still to be designed and implemented. No completed internship management feature is claimed at this stage.

## Technology stack

| Area | Technology | Current repository status |
| --- | --- | --- |
| Backend and web application | C#, ASP.NET Web Forms, .NET Framework 4.7.2 | Initial project present |
| Frontend | HTML5, CSS3, JavaScript, Bootstrap 5 | Planned; no application pages or frontend assets present |
| Backend services | Firebase, Firebase Authentication | Planned; no integration present |
| Design and collaboration | Figma, Git, GitHub, Trello | Project tools; Git repository present |

The project also references `Microsoft.CodeDom.Providers.DotNetCompilerPlatform` version 2.0.1 through `packages.config`.

## Project status

**Early scaffold.** The solution, project configuration, assembly metadata, and NuGet package manifest are present. Application pages, role workflows, Firebase integration, and Bootstrap styling are not yet in the repository.

## Getting started

1. Use Windows with a Visual Studio installation that supports ASP.NET Web Forms, .NET Framework 4.7.2, and `.slnx` solution files.
2. Open [`internship-managment-system/internship-managment-system.slnx`](internship-managment-system/internship-managment-system.slnx). The existing folder spelling is intentional here because it matches the checked-in path.
3. Restore the NuGet packages listed in `packages.config` before building. The restored `packages/` directory is excluded from Git.
4. Build or launch the project with Visual Studio and IIS Express. The project is configured for IIS Express, but the current scaffold has no application page to demonstrate.

The build and launch steps have not been verified in this repository maintenance pass.

## Team collaboration

Keep source, the solution and project files, and `packages.config` under version control. Keep generated output, restored packages, local IDE settings, and secrets out of commits. Review changes before committing and use descriptive commit messages when sharing work on GitHub.
