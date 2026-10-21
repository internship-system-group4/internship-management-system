# GitHub for beginners

`main` stays stable. Integration happens in `dev`; the team lead moves reviewed,
built integration changes into `main`. Use one branch per Trello card.

## Start and submit a card

From the existing repository folder, with a clean working tree:

```powershell
git switch dev
git pull --ff-only origin dev
git switch -c feature/A01-login-page
# Edit your page, then build the solution.
git status
git add InternshipManagementSystem/InternshipManagementSystem/Pages/Account/Login.aspx InternshipManagementSystem/InternshipManagementSystem/Pages/Account/Login.aspx.cs
git commit -m "A01: implement login page"
git push -u origin feature/A01-login-page
```

On GitHub, open a pull request with **base: dev**, **compare: your feature branch**.
Ask the owner/reviewer to check it; merge after review and a successful build.
If `dev` does not exist yet, the team lead creates it from the agreed stable base.
Never force-push a shared branch. Never commit `App_Secrets.config`.

## Integrate without overwriting teammates

Before merging the PR, commit your work, then bring in current `dev`:

```powershell
git fetch origin
git merge origin/dev
# Resolve conflicts, build, commit the resolution if needed, then push.
```

Read both sides of a conflict and combine the intended changes; do not blindly
choose “ours” or “theirs”. Ask the other file owner when intent is unclear.
For `.csproj` conflicts, keep both sets of independent file entries, remove
conflict markers and duplicate entries, preserve valid XML, then **build**.
Do not replace the whole project file with an older copy.

After your PR is merged, switch to `dev` and pull again before starting a new card.

## Apply an updated ZIP to a repository already on GitHub

1. Commit current work and push your feature branch as a backup. Fetch and merge
   current `origin/dev` before starting the ZIP update on a new branch.
2. Extract the ZIP to a temporary folder **outside** the repository. Do not extract
   its outer folder inside your project: that creates a duplicate nested project.
3. Compare matching relative paths with Visual Studio's diff or Git. Copy only
   intended source changes into the existing checkout. Preserve teammates' edits;
   merge shared-file changes rather than replacing them wholesale.
4. Never copy `.git`, `.vs`, `bin`, `obj`, `packages` or local secrets from the ZIP.
   Review intended deletions explicitly; a file absent from a ZIP is not automatically
   obsolete. Keep the existing repository's history and remote.
5. Review `git diff` and `git status`, build the existing `.sln`, commit the selected
   updates and open a PR into `dev`. Do not upload the ZIP as another project.
