# Homepage — initial visual implementation

Historical first pass. The public redesign in `13-public-redesign.md` supersedes
this layout and replaces example vacancies with actual program information.
Photo provenance below remains current.

Owner: Osama (reassigned by the user). `Default.aspx` uses the existing shared
Public.master Navbar and Footer and adds page-only styling in `Assets/css/home.css`.
The user's supplied full-page reference guides the composition: split campus hero,
four internship steps, three study/guidance columns, photo guide, opportunity
previews, support points and a blue closing section. GJU palette, Segoe UI,
quiet borders and compact corners follow DESIGN.md.

This first version is a public informational page, with no Firebase requests or
writes and no new API. Opportunity previews are explicitly illustrative rather
than invented live vacancies. Full opportunities retain the existing protected
student route. No placeholder company names, seat counts or deadlines are shown.
The two programs match the current project configuration; the third column is
guidance, not an invented college. Official program/policy verification remains X01.

No process video was supplied. The guide links to the working process section
rather than presenting a nonfunctional play control. Login, About and Contact use
the existing team routes, whose implementation status is separate from this page.

## Image provenance

Both photos were downloaded from GJU's public campus-life gallery for this local
project preview. They depict campus life, not internship placements or partners.
They are not generated images or images of fictitious companies.

- `Assets/images/home-students.jpg`: https://www.gju.edu.jo/sites/default/files/campus-life-gallery-17.jpg
- `Assets/images/home-campus.jpg`: https://www.gju.edu.jo/sites/default/files/campus-life-gallery-3.jpg
- Source gallery: https://www.gju.edu.jo/capmus-life

The existing university logo is reused without alteration. Desktop, tablet and
phone layouts retain the shared navigation and footer; page sections stack and
the process steps become a single column on narrow phones.
