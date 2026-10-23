# Export grades and results to Excel

Company supervisors, academic supervisors and coordinators can open **Grades & Results** from their portal navigation. Search by student name, student number or company, select a result, and apply the filters. **Export to Excel (.xlsx)** downloads the current selection. No Office installation is required on the server.

The preview and export use the same access checks:

- Company supervisors see internships assigned to them at their company. Their export includes task grades, their submitted company grade and approved final results. Academic grades are excluded.
- Academic supervisors see their assigned internships, including submitted company and academic grades.
- Coordinators see all confirmed internships, excluding cancelled placements.
- Students cannot access this page. Access is checked again for every download, including account deactivation and assignment changes.

Each workbook includes student numbers as text (preserving leading zeros), names, companies, placement status, graded/assigned task counts, approved hours, numeric percentage grades, review status and the released result. The header is frozen and filterable; an information sheet explains the scope, UTC export time and pending grades.

Missing, draft, invalid or outdated evaluations remain **Pending**. A task grade is available only when every assigned task has a valid evaluation covering its latest submission. Final grades and Pass/Fail results require coordinator approval and come from the saved completion record. Exporting does not approve or change results. The project's grading weights remain provisional.

## Verification

Build the solution with Visual Studio/MSBuild, then run:

```powershell
./tests/Run-GradesExportSmoke.ps1
```

The smoke test starts disposable IIS Express and Firebase fixture servers on local ports 19082 and 19081. It tests actual page requests and Excel downloads for all three roles, filters, empty/error states, access denial, deactivation, pending grades, Unicode, leading zeros and formula-like text. It never uses live Firebase settings. Generated workbooks and the isolated web root are under the ignored `tests/bin/grades-export` directory. IIS Express and .NET Framework 4.7.2 are required.
