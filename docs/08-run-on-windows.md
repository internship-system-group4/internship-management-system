# Run on Windows

1. Install Visual Studio with **ASP.NET and web development** and the **.NET Framework
   4.7.2 targeting pack**. Open `InternshipManagementSystem/InternshipManagementSystem.sln`.
2. Right-click the solution → **Restore NuGet Packages**. This restores the existing
   CodeDom compiler package; add no new packages. Build the solution.
3. Nothing to copy: the Firebase database URL and API key are already in
   `Web.config`. Just make sure your branch has the latest `main`
   (`git fetch origin` then `git merge origin/main`).
4. Follow `05-firebase-setup.md` for the one-time Auth setup, rules and root import.
5. Set the web project as the startup project and press **F5** (IIS Express).
6. Once cards A01/A02 are implemented, open Login and sign in as
   `coordinator@gju.edu.jo` with the existing coordinator password. No password
   is stored in this repository.
7. Once A05 is implemented, open **Coordinator → Manage Students**, create the first
   new student with a temporary password, School of Computing, the selected program
   and 160 required hours. The page calls `AuthService.CreateAccount`, then
   `UserRepository.SavePerson` with the exact returned UID and
   `MustChangePassword = true`.

**Current scaffold:** Login and Manage Students are page stubs. F5/build is available,
but those two UI steps need their Trello cards completed. The seed provides profiles
for development; it does not create Firebase Authentication accounts.

| Failure | Fix |
| --- | --- |
| Missing `App_Secrets.config` | Copy it to the inner web-project folder beside `Web.config`; check it is not named `.config.txt`. It is intentionally absent from Git and the project file. |
| “Firebase is not configured” | Check the local XML has nonempty `Firebase.DatabaseUrl` and `Firebase.ApiKey`; restart IIS Express after changes. |
| TLS / secure-channel error | Confirm `Global.Application_Start` runs and selects TLS 1.2. Check the Windows clock, trusted certificates and network connection. |
| 401 / 403 | Database calls refresh once. If redirected with `error=expired`, sign in again. Persistent permission denial means check the rules, `users` casing, exact UID and Role. |
| Missing CodeDom package | Restore the existing `packages.config` dependency; check NuGet source/network access. |
| Missing framework reference assemblies | Install the .NET Framework 4.7.2 targeting pack through Visual Studio Installer. |
| Index not defined | Ask Ahmad to add the queried field's `.indexOn`; see the setup guide. |

For a command-line build, use Developer PowerShell for Visual Studio:

```powershell
msbuild InternshipManagementSystem/InternshipManagementSystem.sln /t:Build /p:Configuration=Debug
```
