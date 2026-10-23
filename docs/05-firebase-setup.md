# Firebase setup

<!-- First create the four development Auth accounts, copy each UID from Authentication (never retype it: I and l look identical), replace both matching placeholders, then import docs/dev-users.json ONCE at the database root. -->

## Local configuration

Use the team's existing Firebase project. Enable **Authentication → Email/Password**
and use **Realtime Database**, not Firestore. In
`InternshipManagementSystem/InternshipManagementSystem/`, copy the privately shared
`App_Secrets.config` into place (or fill a copy of `App_Secrets.config.example`).
Keep the database URL free of a trailing slash. `Web.config` merges this ignored
file through `appSettings file=`; never put real settings in a tracked file or
register the secrets file in the project.

Leave `Firebase.StorageBucket` empty. This project accepts file links only;
Firebase Storage requires the Blaze plan.

## One-time development import

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
      ".write": "auth != null && root.child('users/' + auth.uid + '/Role').val() !== 1",
      ".indexOn": ["PlacementId"]
    },
    "academicFinalEvaluations": {
      ".read":  "auth != null && root.child('users/' + auth.uid + '/Role').val() !== 1",
      ".write": "auth != null && root.child('users/' + auth.uid + '/Role').val() !== 1",
      ".indexOn": ["PlacementId"]
    },
    "contactMessages": {
      ".read":  "auth != null && root.child('users/' + auth.uid + '/Role').val() === 4",
      ".write": true
    },
    "companies":        { ".read": "auth != null", ".write": "auth != null" },
    "studentGroups":    { ".read": "auth != null", ".write": "auth != null && root.child('users/' + auth.uid + '/Role').val() === 4" },
    "opportunities":    { ".read": "auth != null", ".write": "auth != null" },
    "applications":     { ".read": "auth != null", ".write": "auth != null" },
    "placements":       { ".read": "auth != null", ".write": "auth != null", ".indexOn": ["CompanyId", "AcademicSupervisorId"] },
    "tasks":            { ".read": "auth != null", ".write": "auth != null", ".indexOn": ["PlacementId"] },
    "submissions":      { ".read": "auth != null", ".write": "auth != null", ".indexOn": ["PlacementId"] },
    "taskEvaluations":  { ".read": "auth != null", ".write": "auth != null", ".indexOn": ["StudentId", "PlacementId"] },
    "academicComments": { ".read": "auth != null", ".write": "auth != null", ".indexOn": ["PlacementId", "StudentId"] },
    "trainingHours":    { ".read": "auth != null", ".write": "auth != null", ".indexOn": ["PlacementId"] },
    "completions":      { ".read": "auth != null", ".write": "auth != null", ".indexOn": ["StudentId", "PlacementId"] },
    "meetings":         { ".read": "auth != null", ".write": "auth != null" }
  }
}
```

There is no blanket root rule: Firebase access grants cascade downward and cannot
be revoked deeper. A root `.read` would expose the two confidential evaluation
nodes to students. These are development permissions; `IsVisibleToStudent` on
academic comments must be checked by student pages, and is not enforced by these rules.

### Filtered queries

The rules above index the student progress queries as well as placements by
company and academic supervisor. Other
Firebase REST `GetWhere` queries need an `.indexOn` for each queried field, or
they can fail with `Index not defined`. Before using other filtered pages, add
indexes under the existing nodes without changing their access rules. For example, add
`".indexOn": ["PlacementId", "StudentId"]` to `academicComments`.
Use the repository's `GetWhere` field names for other collections; the main ones
are `CompanyId`, `AcademicSupervisorId`, `StudentId`, `PlacementId`, `TaskId`,
`OpportunityId`, `CreatedById` and `Status` where queried.

Placements use `placements/{studentUid}`. `Confirm` reads first and uses
Firebase's [conditional PUT](https://firebase.google.com/docs/reference/rest/database/)
with `if-match: null_etag` to prevent concurrent confirmations overwriting data.
Create placements only through `Confirm`; use `Update` for later field changes.

## Troubleshooting

### Completion review authorization update

The development grants above are insufficient for the corrected completion workflow.
Merge [the scoped rules fragment](firebase-completion-rules.patch.json) by replacing
the corresponding nodes, preserving unrelated rules/indexes. Do not upload the
fragment as an entire application's rules file. Follow the [migration and validation
notes](11-completion-review.md#additive-firebase-changes-and-deployment), including
testing the merged rules in Firebase's simulator/emulator before deployment.


| Symptom | Check |
| --- | --- |
| TLS secure-channel error | `Global.Application_Start` sets TLS 1.2; check Windows certificates and the clock. |
| Firebase is not configured | The local secrets file exists beside `Web.config`, with nonempty database URL and API key. |
| 401 / 403 | The client refreshes once using the [Auth REST endpoint](https://firebase.google.com/docs/reference/rest/auth#section-refresh-token); failed refresh signs out protected pages with `error=expired`. Sign in again. Persistent rejection after a successful refresh means check the rules and profile Role. |
| Index not defined | Add the queried field's index as described above. |
| Account not found | Auth UID and `users/{uid}/Id` must match exactly; check lowercase `users`. |
