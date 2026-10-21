# Firebase setup

Do this once as a team, then each member copies the keys into their own local
`App_Secrets.config`.

## 1. Create the project

1. <https://console.firebase.google.com> → **Add project**.
2. Name it something like `uims-group4`. Analytics is not needed.

## 2. Authentication

**Build → Authentication → Get started → Email/Password → Enable.**

Leave email link (passwordless) off. Password reset emails work out of the box,
which is all card A03 needs.

## 3. Realtime Database

**Build → Realtime Database → Create database.** Pick the region closest to
you and start in **test mode**, then replace the rules with the set below.

Copy the URL shown above the data tree — that is `Firebase.DatabaseUrl`.

## 4. Storage (only if you choose file uploads)

**Build → Storage.** The bucket name without the `gs://` prefix is
`Firebase.StorageBucket`. `Services/StorageService.cs` lists three options for
handling CVs and submissions, one of which is links only and needs no Storage
at all.

## 5. The Web API key

**Project settings → General → Web API Key** — that is `Firebase.ApiKey`.

## 6. Local configuration

In `InternshipManagementSystem/InternshipManagementSystem/`, copy
`App_Secrets.config.example` to `App_Secrets.config` and fill in the three
values. That file is git-ignored, so it never reaches GitHub. `Web.config` picks
it up automatically through the `appSettings file=` attribute, and simply
ignores it when it is absent.

## 7. Database rules

Paste this into **Realtime Database → Rules**. It is a development rule set: any
signed-in user can read and write, which is enough for the demo, and the
`.indexOn` entries are what the system actually needs to query without warnings.

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null",

    "users": {
      ".indexOn": ["Role", "GroupId", "AcademicSupervisorId", "CompanyId"],
      "$uid": {
        "ConfirmedPlacementId": {
          ".validate": "!data.exists() || data.val() === newData.val()"
        }
      }
    },

    "opportunities":           { ".indexOn": ["CompanyId", "Status", "EligibleCollege"] },
    "applications":            { ".indexOn": ["StudentId", "OpportunityId", "CompanyId", "Status"] },
    "placements":              { ".indexOn": ["StudentId", "CompanyId", "AcademicSupervisorId", "Status"] },
    "tasks":                   { ".indexOn": ["PlacementId", "StudentId", "CompanyId"] },
    "submissions":             { ".indexOn": ["TaskId", "PlacementId", "StudentId"] },
    "taskEvaluations":         { ".indexOn": ["TaskId", "PlacementId", "StudentId"] },
    "companyFinalEvaluations": { ".indexOn": ["PlacementId", "StudentId"] },
    "academicFinalEvaluations":{ ".indexOn": ["PlacementId", "StudentId"] },
    "trainingHours":           { ".indexOn": ["PlacementId", "StudentId", "Status"] },
    "completions":             { ".indexOn": ["PlacementId", "StudentId", "Status"] },
    "studentGroups":           { ".indexOn": ["AcademicSupervisorId"] },
    "meetings":                { ".indexOn": ["CreatedById", "PlacementId"] },
    "contactMessages":         { ".indexOn": ["Status"] }
  }
}
```

The `ConfirmedPlacementId` rule is worth understanding. It allows the field to
be written while it is empty and refuses any later change, which is what makes
"a student cannot confirm more than one offer" (card O03) genuinely true. The
C# check in `PlacementRepository.TryConfirm` narrows the race window; only this
rule closes it, because only it runs on Google's side.

`contactMessages` needs public write if visitors submit without signing in.
Either add `"contactMessages": { ".write": true }` or, cleaner, keep write
restricted and let card D01 post through an authenticated path.

> These are development rules. A production system would scope reads per role —
> above all the two confidential evaluation collections. Note this in the
> presentation if the markers ask about security.

## 8. Seed accounts for the demo

Create the first coordinator by hand, because every other account is created
*by* a coordinator:

1. **Authentication → Users → Add user**, with an email and password.
2. Copy the generated **User UID**.
3. **Realtime Database → users →** add a child whose key is that UID:

```json
{
  "Id": "<the UID>",
  "FullName": "Internship Coordinator",
  "Email": "coordinator@example.edu",
  "Role": 4,
  "IsActive": true,
  "MustChangePassword": false,
  "CreatedAt": 1761000000000
}
```

Sign in as that coordinator and create everything else through the system —
which is also exactly the opening of the live demo (card X06).

## 9. If Firebase calls fail

| Symptom | Cause |
| --- | --- |
| "Could not create SSL/TLS secure channel" | TLS 1.2 not set. `Global.asax.cs` already does this in `Application_Start`; make sure it runs. |
| "Firebase is not configured" | `App_Secrets.config` missing or empty. |
| 401 / "Permission denied" | Rules reject the call, or the ID token in session expired — sign in again. |
| Query returns everything, with an index warning in the response | A missing `.indexOn` above. |
| 404 on every call | `DatabaseUrl` has a trailing slash or is the Firestore URL rather than the Realtime Database one. |
