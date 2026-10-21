# Approved UIMS visual theme

Osama supplied student-portal screenshots on 2026-10-21 as the visual authority
for O01 and future requested pages. Match this theme rather than inventing a
new visual direction.

- White sidebar and top bar; very pale blue content background `#f6f8ff`.
- Primary buttons and active navigation: `#264f73`; hover `#173f62`.
- Heading/text ink `#133d61`; secondary text `#58718a`.
- Quiet borders `#e4ebf4`; light blue badges `#e5efff`.
- Segoe UI/system sans typography. Small outline navigation icons.
- White form surfaces, 5–7px corners, no decorative shadows or gradients.
- GJU mark with university name, product name and Student role label.
- Top bar breadcrumb, authenticated user's real name and initials.
- Responsive stacked form with readable controls and no horizontal overflow.

The shared student shell now lives in `Layout/Student.master` and
`Assets/css/portal-layout.css` in the web project. Every page using the student
master inherits the logo, navigation, top bar, responsive styles and logout.
`Student.master.cs` renders the user's initials and determines active navigation
on the server, including mapping Apply to My Applications and Opportunity Details
to Explore Opportunities. Company.master now reuses the same portal CSS and
mobile navigation script with company-specific links and account details.
Academic.master and Coordinator.master also share the same theme and mobile
behavior, each with independent navigation. Shared Meetings pages select the
current role master after the normal authentication checks.

O01's form-only styles remain in `Assets/css/apply-theme.css`. Its script only
updates the cover-letter character counter; it does not construct the shell.

The GJU logo is the original downloaded PNG from the university website:
https://gju.edu.jo/sites/all/themes/bootstrap/images/GJU-LOGO2.png
Local asset: `Assets/images/gju-logo.png` within the web project. It has not been
redrawn or generated. Original screenshots guide visual styling only; example
people, hours, dates and company names are not product facts.

Student navigation collapses into a hamburger at 900px and below. The shared
portal-layout.js controls the drawer, focus trap, Escape/backdrop close, and
resize reset. The desktop sidebar stays visible. Without JavaScript, the
expanded responsive navigation remains available as a fallback.

Public.master provides a shared GJU Navbar and Footer in the same palette.
The Navbar is white with a logo/product lockup, quiet text links and one blue
Log in/My dashboard action. The footer uses three flat columns with product
context, navigation and support, collapsing to one column on phones. Public
navigation has its own lightweight mobile dropdown and no-JavaScript fallback.

O03 shows a white, green-outlined confirmed-placement summary above the student's
application list. Accepted offers offer an explicit one-internship acknowledgement
and Confirm offer action until a placement exists. Other offers then lose their
confirmation actions while their application statuses remain visible.

O06–O08 reuse Coordinator.master. The dashboard uses six flat metrics and a recent
placements table; monitoring uses labeled search/status controls and ten rows per
page. Detail panels keep task attempts, grading, hours and completion visibly
separate. Narrow screens stack panels and keep wide tables in their own horizontal
scroll areas. Page-specific styling lives in coordinator-monitoring.css.
