# Firebase setup

<!-- First create the four development Auth accounts, copy each UID from Authentication (never retype it: I and l look identical), replace both matching placeholders, then import docs/dev-users.json ONCE at the database root. -->

## Local configuration

Use the team's existing Firebase project. Enable **Authentication → Email/Password**
and use **Realtime Database**, not Firestore. The database URL and Web API key
are already in `Web.config`, so a normal `git pull` / `git merge origin/main` is
all a teammate needs; no separate settings file is used. Keep the database URL
free of a trailing slash. The Web API key is not a password (Firebase expects it
in app code); the database rules below are what protect the data.

Leave `Firebase.StorageBucket` empty. This project accepts file links only;
Firebase Storage requires the Blaze plan.

## One-time development import

> **ALREADY DONE - DO NOT IMPORT ANYTHING.** The team's database and test accounts
> are set up (Ahmad, 21 Oct 2026). Importing a JSON file replaces existing data and
> breaks login for everyone. Ask Ahmad if an account is missing. The steps below are
> kept only as a record.

1. The coordinator already exists in Authentication:
   `coordinator@gju.edu.jo`, UID `YIswkxh3bBQqucIRH1gPRYWkmO33`. Keep this record.
2. Create four Email/Password accounts using the emails in `dev-users.json`:
   `student.ce@example.com`, `student.cs@example.com`,
   `company.supervisor@example.com`, `academic.supervisor@example.com`.
   Choose development passwords privately; the seed contains none.
3. **Copy** each UID from Authentication; never retype it (`I` and `l` look alike).
   Replace `PASTE_UID_HERE_1` through `_4`, respectively. Each placeholder occurs
   exactly twice: its node key and its `Id` value. Leave no placeholders.
4. Export a backup of any existing database data. In **Realtime Database → Data**,
   select the root and **Import JSON → docs/dev-users.json**, once.
   **A root import replaces all existing data.** The file includes the coordinator
   so this import does not delete him. Do not repeat it after the team starts work.

The companies and opportunities are fictional development fixtures. Program names
are provisional pending the official-study-plan check in X01. `Major` stores the
program; no track field is added to the data contract. Development users have
`MustChangePassword = false` for testing.

Paths are **case-sensitive**: the account node must be `users` (lowercase).
Fields are PascalCase, timestamps Unix milliseconds, and enums integer values.

## Database rules

Paste this exact development rule set into **Realtime Database → Rules**:

```json
{
  "rules": {
    "users": {
      ".read": "auth != null",
      "$uid": {
        ".write": "auth != null && ($uid === auth.uid || root.child('users/' + auth.uid + '/Role').val() === 4)",
        ".validate": "root.child('users/' + auth.uid + '/Role').val() === 4 || (newData.child('Role').val() === data.child('Role').val() && newData.child('IsActive').val() === data.child('IsActive').val())"
      }
    },
    "companyFinalEvaluations": {
      ".read":  "auth != null && root.child('users/' + auth.uid + '/Role').val() !== 1",
      ".write": "auth != null && root.child('users/' + auth.uid + '/Role').val() !== 1"
    },
    "academicFinalEvaluations": {
      ".read":  "auth != null && root.child('users/' + auth.uid + '/Role').val() !== 1",
      ".write": "auth != null && root.child('users/' + auth.uid + '/Role').val() !== 1"
    },
    "contactMessages": {
      ".read":  "auth != null && root.child('users/' + auth.uid + '/Role').val() === 4",
      ".write": true
    },
    "companies":        { ".read": "auth != null", ".write": "auth != null" },
    "studentGroups":    { ".read": "auth != null", ".write": "auth != null && root.child('users/' + auth.uid + '/Role').val() === 4" },
    "opportunities":    { ".read": "auth != null", ".write": "auth != null" },
    "applications":     { ".read": "auth != null", ".write": "auth != null", ".indexOn": ["StudentId", "CompanyId"] },
    "placements":       { ".read": "auth != null", ".write": "auth != null", ".indexOn": ["CompanyId", "AcademicSupervisorId"] },
    "tasks":            { ".read": "auth != null", ".write": "auth != null", ".indexOn": ["StudentId", "CompanyId", "PlacementId"] },
    "submissions":      { ".read": "auth != null", ".write": "auth != null", ".indexOn": ["StudentId", "TaskId", "PlacementId"] },
    "taskEvaluations":  { ".read": "auth != null", ".write": "auth != null", ".indexOn": ["StudentId", "PlacementId"] },
    "academicComments": { ".read": "auth != null", ".write": "auth != null" },
    "trainingHours":    { ".read": "auth != null", ".write": "auth != null", ".indexOn": ["StudentId", "PlacementId"] },
    "completions":      { ".read": "auth != null", ".write": "auth != null", ".indexOn": ["StudentId", "PlacementId"] },
    "meetings":         { ".read": "auth != null", ".write": "auth != null" },
    "notifications": {
      "$uid": {
        ".read":  "auth != null && auth.uid === $uid",
        ".write": "auth != null"
      }
    }
  }
}
```

`notifications/{uid}` feeds the bell in every portal's top bar. People can read
only their own list; any signed-in user can add to another person's list,
because the person who acts (for example a company supervisor creating a task)
is the one who notifies the student. Without this rule the bell shows
"Notifications are unavailable right now" and every other page keeps working.

There is no blanket root rule: Firebase access grants cascade downward and cannot
be revoked deeper. A root `.read` would expose the two confidential evaluation
nodes to students. These are development permissions; `IsVisibleToStudent` on
academic comments must be checked by student pages, and is not enforced by these rules.

### Filtered queries

The application node above indexes `StudentId` and `CompanyId` for O01's student
and company lists, plus placement queries by company or academic supervisor.
Apply these indexes to the team's database before testing those pages.
Other Firebase REST `GetWhere` queries need
an `.indexOn` for each queried field, or they can fail with `Index not defined`.
Before using filtered pages, have Ahmad add indexes under the existing nodes
without changing their access rules. For example, add
`".indexOn": ["PlacementId", "StudentId"]` to `academicComments`.
Use the repository's `GetWhere` field names for other collections; the main ones
are `CompanyId`, `AcademicSupervisorId`, `StudentId`, `PlacementId`, `TaskId`,
`OpportunityId`, `CreatedById` and `Status` where queried.

Placements use `placements/{studentUid}`. `Confirm` reads first and uses
Firebase's [conditional PUT](https://firebase.google.com/docs/reference/rest/database/)
with `if-match: null_etag` to prevent concurrent confirmations overwriting data.
Create placements only through `Confirm`; use `Update` for later field changes.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| TLS secure-channel error | `Global.Application_Start` sets TLS 1.2; check Windows certificates and the clock. |
| Firebase is not configured | The local secrets file exists beside `Web.config`, with nonempty database URL and API key. |
| 401 / 403 | The client refreshes once using the [Auth REST endpoint](https://firebase.google.com/docs/reference/rest/auth#section-refresh-token); failed refresh signs out protected pages with `error=expired`. Sign in again. Persistent rejection after a successful refresh means check the rules and profile Role. |
| Index not defined | Add the queried field's index as described above. |
| Account not found | Auth UID and `users/{uid}/Id` must match exactly; check lowercase `users`. |
