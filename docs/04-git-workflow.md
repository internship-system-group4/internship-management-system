# Git workflow

Seven people, one Web Forms solution, a few days. The rules below are short on
purpose - they exist to stop the two things that actually waste a team's time:
conflicts in shared files, and a broken `main` on demo day.

## Branches

```
main     demo-ready only. Never commit here directly.
dev      integration branch. Everyone's pull requests land here.
feature/<CARD>-<short-name>
```

One branch per Trello card, named after the card:

```
feature/A01-login-page
feature/F04-task-submission
feature/N03-create-company-accounts
```

```bash
git checkout dev
git pull
git checkout -b feature/A01-login-page
# ... work, commit ...
git push -u origin feature/A01-login-page
# open a pull request into dev
```

## Before you start work, every time

```bash
git checkout dev && git pull
git checkout your-branch
git merge dev
```

Merging `dev` into your branch daily turns one painful conflict at the end into
several trivial ones along the way.

## Pull requests

- Title: the card id and name, for example `A01 - Build Login Page UI`.
- Body: what the acceptance criteria are and that you checked them.
- One reviewer. `.github/CODEOWNERS` requests the right person automatically
  once the usernames in it are filled in.
- Merge into `dev`, not `main`. Osama merges `dev` into `main` when the demo
  path works end to end (card X06).

## Conflicts you will actually hit

**`InternshipManagementSystem.csproj`** - keep BOTH sides, delete the conflict
markers, then build once before pushing. The lines are independent, so both
sides are almost always right. `.gitattributes` sets `merge=union` on this file
so Git usually does it for you - but check for a duplicated line afterwards.
This should be rare: all 40 pages are already registered, so the file only
changes when someone adds a new file.

**`Assets/css/site.css`** - do not put page-specific CSS here. Each page has a
`head` content block; put it there. The shared stylesheet is for shared things.

**A master page in `Layout/`** - ask Ahmad instead of editing. A change here
affects every page that uses that master.

**Someone else's `.aspx`** - that is a sign the work drifted across an ownership
line. Stop and talk rather than merging it.

## Commits

Present tense, say what changed, mention the card:

```
A01: add login form with show/hide password
F06: keep earlier submissions when a revision is requested
N03: create company supervisor accounts from Manage Companies
```

## What never gets committed

`bin/`, `obj/`, `packages/`, `.vs/`, and above all `App_Secrets.config`, which
holds the Firebase keys. `.gitignore` covers all of it. If a secret does get
committed, say so immediately - rotating the key takes a minute, and quietly
deleting the file in a later commit does not remove it from history.

## Why there are no NuGet packages to restore

The data layer talks to Firebase over its REST API using `HttpWebRequest` and
`JavaScriptSerializer`, both of which ship inside .NET Framework. So a fresh
clone builds with nothing to install beyond the one package that was already
in `packages.config`.

That was a deliberate trade: `Newtonsoft.Json` and the Firebase community
libraries are more comfortable to write against, but every added package is
another thing that can fail differently on seven machines two days before a
deadline. If the team later wants Newtonsoft, install it and rewrite
`Data/Json.cs` - nothing else in the system touches a serializer.

## A note on the page namespaces

The page namespaces end in `Area` - `InternshipManagementSystem.Pages.StudentArea`,
not `...Pages.Student`. That is not decoration. A namespace called
`Pages.Student` would hide the `Student` model class, and every file in that
folder would fail to compile with *"Student is a namespace but is used like a
type"*. Same for `Company` and `Coordinator`. Keep the suffix; if Visual Studio
creates a new file in one of those folders it will get the namespace wrong, so
fix it by hand.
