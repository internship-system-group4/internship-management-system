# Configured Groups design verification

Date: 2026-10-24

Source visual truth: `C:/Users/user/AppData/Local/Temp/codex-clipboard-a3b09966-9fcd-4940-808e-3a878f3d7165.png`

Implementation: `http://localhost:57994/Pages/Coordinator/ConfiguredGroups.aspx` in an isolated IIS Express copy with synthetic Firebase data.

## Evidence

- Desktop screenshot: `tests/bin/configured-groups-desktop.jpg`.
- Full-view comparison: `tests/bin/configured-groups-comparison.jpg`.
- Readable filter/table comparison: `tests/bin/configured-groups-detail-comparison.jpg`.
- Mobile screenshot: `tests/bin/configured-groups-mobile.jpg`.
- Dark screenshot: `tests/bin/configured-groups-dark.jpg`.
- Arabic screenshot: `tests/bin/configured-groups-arabic.jpg`.
- Desktop CSS viewport: 1810 x 1050. Browser full-page screenshot: 1795 x 1085 pixels (scrollbar excluded). Source: 1576 x 998 pixels. No device-density multiplication was applied.
- Comparison normalization: excluded the existing portal sidebar from the implementation, cropped the content region to 1544 x 1000, and displayed both content regions at 788 x 499. Focused crops compare the filter row and first table row at readable scale.
- State: English, light theme, three groups with the reference names, supervisors, years, and student counts. Fixtures were restored after testing twelve-group pagination.

## Findings and comparison history

1. Initial browser review found a P2 search icon/placeholder overlap caused by the shared input padding rule, a P2 medium-width filter grid that placed Search on its own third row, and an incorrect fallback icon for Clear.
   - Fixed the scoped input padding, changed medium-width filters to a two-row grid, and added locally hosted Bootstrap icons with the package license.
   - Reopened the rendered page and compared the desktop screenshot against the source in `configured-groups-comparison.jpg` and `configured-groups-detail-comparison.jpg`. The overlap, extra filter row, and incorrect Clear icon are resolved.
2. Mobile review found a P2 active-tab label clipped at 390 pixels.
   - Allowed both tabs to share the available width and wrap their labels. The final mobile screenshot shows readable tabs; document scroll width equals the 390-pixel viewport. The wide data table scrolls within its own region and retains its existing accessible scroll hint.
3. Supplemental dark-mode review found low-contrast blue tab text and red Delete text.
   - Increased the dark-theme text colors while retaining the saturated primary-button fill. Saved the revised dark screenshot.
4. Supplemental Arabic review verified localized labels, right-aligned filters, mirrored table ordering, and readable Arabic content. Updated the previous-page library icon to mirror alongside the next-page icon.

## Required fidelity surfaces

- Typography: uses the application's locally hosted Noto Sans/Noto Sans Arabic. The bold navy title, strong group names, compact uppercase table headings, and muted helper text reproduce the reference hierarchy. Slight differences from the reference typeface are acceptable P3 polish.
- Spacing/layout: title icon, primary CTA, underlined tabs, rounded white card, total summary, filter controls, bordered rows, badges, and footer match the reference composition. The existing portal navigation remains outside the redesigned content. Medium/mobile layouts adapt to available width.
- Colors/tokens: page-scoped navy, blue, pale blue, mint, purple, gray borders, and red destructive actions follow the supplied design. Dark mode has separate readable foreground colors.
- Images/icons: the reference contains UI icons and initials, with no photographic or illustrative assets. Filled group/person and reset/previous icons use licensed local Bootstrap SVG assets. Other actions retain the application's existing shared icon system. The library group silhouette differs slightly from the reference; acceptable P3.
- Copy/content: screenshot labels and sample group data match where applicable. Added labels, placeholders, counts, filters, and pagination are translated into English and Arabic. Live data continues to come from the existing repository.

## Functional checks

- MSBuild Debug build passed.
- Year filter returned G22 for year 3.
- Supervisor filter returned G34 for test57.
- Enter submitted search; an unmatched query displayed the empty result state and `Showing 0 to 0 of 0 groups`.
- Clear restored all groups and reset the selections.
- Twelve fixture groups produced ten rows on page 1 and rows 11–12 on page 2.
- Selecting Fall while on page 2 reset the list to page 1 and returned only G22.
- View opened the existing details modal with the correct group, supervisor, and members; Close dismissed it.
- Edit navigated to the populated existing group form; Create Group navigated to the creation form.
- No delete operation was performed. Existing confirmation and server-side deletion behavior are retained.
- In-app browser console error check returned no errors.
- Mobile, dark, and Arabic states were visually inspected. Temporary viewport override was reset.

## Follow-up polish

- P3: exact reference font and group silhouette differ slightly from the existing font and Bootstrap icon library.
- Artifacts in `tests/bin` are local verification output and are ignored by Git.

final result: passed
