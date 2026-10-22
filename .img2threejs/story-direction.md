# DIRECTION SHEET — The page is the object
seed 1140822654 · drawn 2026-10-21 · sector education · tone quiet
Brief: Gate 1 and two national flags become the spatial frame of a concise two-chapter identity story; approved GJU palette/type and accessible HTML govern

| | |
| --- | --- |
| Direction | The page is the object |
| Hero | Invitation card, cropped |
| Type | kept from the brand |
| Colour | kept from the brand |
| Sections | intro (Title, note, facts row) → how-it-works (Itinerary on a slip) → showcase (Square plate, spare text) |
| Motion | Curtain footer |
| Photographs | the "Architecture" set, as atmosphere |

This is the direction for this build. Adopt it. Do not blend it with the layout you would have made anyway,
and do not redraw because it is unfamiliar: unfamiliar is the point. Redraw a slot only when it conflicts
with a stated brand constraint or needs an asset that does not exist, and say why in your report.

The parts of this sheet were written separately and will disagree in small ways. Settle every disagreement in this order:
**house rules** (including type no smaller than 13px and body text of 16px or more) → **the direction** (the idea, the composition habits, where the
one accent goes) → **the type system and the palette** (which face does which job, the five size steps, which colour is the ground and where the
accent goes) → **the hero blueprint** → **the section blueprints**. Under each blueprint below, "Adjusted for this page" lists where it disagrees.
In practice: take geometry from blueprints (columns, proportions, what sits where) and take everything else from above them. Map every size a
blueprint names onto one of your five type steps instead of adding a sixth. Use one button shape, one corner radius and one pair of page margins on
the whole page, whatever individual blueprints say. If a blueprint names a kind of typeface (a light serif, a heavy grotesk), use the dealt face.

## 1. The idea
Find the printed or physical artefact that already exists in the subject's world and build the page as that thing. A wedding site is the invitation card. A restaurant is its menu. A conference is the ticket; a record is its sleeve; a shop is the receipt or the swing tag; an archive is a stack of tabbed folders; a course is the syllabus sheet. The artefact supplies everything a template would otherwise invent: its proportions, its typographic manners, its way of grouping information. Visitors recognise the object instantly, which is why these pages feel specific.

Before anything else, write one sentence in your notes: "On this page, <the subject's own material> becomes <the device>."
Fill the first blank from your inventory of what only this client has (its name and what it means, its street, its numbers, its
constraint), then put the nearest competitor in the sentence: if it still works, the idea is the category's, not the client's.
Then name the one live thing the visitor can do on the page (SKILL.md step 4).

## 2. Composition
The first screen shows the artefact as a single filled panel (paper colour on a contrasting ground) centred or offset, with believable proportions: a card at 5:7, a ticket at about 2.2:1 with a notch cut by `clip-path`, a menu as a tall sheet. All primary content lives on it, set the way that object is set: centred and symmetrical for an invitation, in tidy aligned columns for a menu or ticket. The ground behind is a flat colour or one full-bleed photograph. As the page continues, each section is another piece of the same stationery: a second card, a tear-off stub, a folded panel, always filled shapes with real edges (straight, notched, scalloped, perforated by a dotted `border` of round dots at 4px or more), never outlined boxes. The footer is the back of the object.

## 3. Type
Kept from the brand. Take the manners of the artefact: a bookish serif with small caps avoided, or a blunt condensed face for tickets and posters. Sizes stay within what print would use relative to the panel; the name is large on the panel, details are small and exact.

## 4. Colour
Kept from the brand. Paper and ink plus the ground the paper sits on. Two or three flat colours in total, like a two-colour print job.

## 5. Imagery
**Use the images that belong to the project in every picture slot.** For slots they cannot fill, real pictures of the subject's world from the open collections come next (start with `node C:/Users/user/.agents/skills/design-taste-frontend/scripts/assets.mjs "identity story"`, then queries from your inventory (its street, its materials, its trade's tools and history); credit them on the page), then the dealt photographs.

Optional. One photograph behind the object, or small photographs placed on it like tipped-in plates. The object itself is the image.

**Floor (the inspector checks it):** at least four real pictures on the page, usually six to twelve; SVG drawings do not count. One moving picture where an honest clip exists: `node <skill>/scripts/assets.mjs --video "<query>"`, used as a muted loop with a poster frame. Whatever this direction says about pictures, it is carried out with real ones.

Photographs dealt for this build, from the "Architecture" set (structure, lines, bridges, facades and building interiors)
Order of preference for imagery: (1) the project's own photographs and product shots; (2) images you generate, if an image tool is
available; (3) real pictures of the subject's world found in the open collections (assets.mjs, downloaded and credited on the page);
(4) drawings of the subject in code; (5) these. They are real photographs (Unsplash licence, served by picsum.photos) of places, light and
texture. They are atmosphere, never a stand-in for a specific product, dish, person or interface. List the ones you use in your report so
they can be replaced.
- `https://picsum.photos/id/331/1600/1000` — Silhouette of a person standing beneath a steel-framed roof · dark tone · black, white, grey · black-and-white · calm area: bottom · native landscape · photo: Thong Vo
- `https://picsum.photos/id/520/1600/1000` — Suspension bridge tower framed between red brick buildings · mid tone · brick red, sky blue, steel grey · native portrait · photo: Dorothee Hübner
- `https://picsum.photos/id/860/1600/1000` — Bridge walkway framed by a web of suspension cables · mid tone · warm grey, pale beige, brown · native landscape · photo: Skyler Smith
- `https://picsum.photos/id/887/1600/1000` — White apartment block facade with repeating balconies and windows · light tone · white, pale grey, soft red · native landscape · photo: Roman Kraft
- `https://picsum.photos/id/618/1600/1000` — Curving glass and steel lattice roof in black and white · light tone · white, grey, black · black-and-white · native landscape · photo: Mika Ruusunen
- `https://picsum.photos/id/954/1600/1000` — Narrow opening in a white wall revealing a white staircase · light tone · off-white, pale beige · calm area: left · native landscape · photo: Todd Quackenbush
- `https://picsum.photos/id/508/1600/1000` — Tall pointed vaults and pale columns of a church interior · light tone · cream, warm grey, soft orange · native portrait · photo: Jeff Sheldon
- `https://picsum.photos/id/855/1600/1000` — Small figure walking past a huge bright yellow wall · light tone · bright yellow, black · calm area: left · native landscape · photo: Rodion Kutsaev
The last two path numbers are width and height: request the exact crop you render (`/1200/1500` for a 4:5 portrait, `/2400/1350` for a hero) and
add `?grayscale` to desaturate. Use three to six of them, not all eight. Always set `width`, `height`, `alt` and `loading="lazy"` (not on the hero image).
Other sets that fit this brief: people, mountain, city-day, object-still — `node draw.mjs --photos <set>` prints one in full; `--photos list` shows all sets. Taking photographs from another set is your call and is not a redraw; keep them to one light and one treatment.

## 6. Hero — Invitation card, cropped
A flat field of one soft colour fills the viewport. Centred on it is a single portrait card in paper colour, 5:7, on columns 4–9, its top edge 190px down and its lower third cut off by the bottom of the viewport, so the page visibly continues as the rest of the card. The card is a filled shape with scalloped inner corners, made with `clip-path` or with four corner circles in the field colour, and no outline. Inside, with 56px padding, everything is centred and symmetrical like letterpress stationery. The two names, or the title, are set in a large italic serif at clamp(56px, 5.6vw, 88px) on two lines, staggered so line one sits left of centre and line two right. Between and beneath them, date, time and place appear as short lines at 15px in sentence case, separated by space and by one solid 10px diamond. The top row sits on the field above the card at 28px margins: a small monogram top-left, three text links centred, and the single action, a solid rectangular button in the ink colour, top-right.

On a phone: The card becomes full width minus 12px margins, starts 96px down and is still cropped by the bottom edge, with its scalloped top corners kept. The names stay on two lines at 12vw, centred without the stagger, and the details follow at 15px. The monogram sits top-left and the action button top-right on the field; the three links move onto the card's lower part, below the fold.
Headline: The two names or the title on two lines, up to about 12 characters per line, set as they would be printed on the card.

Adjusted for this page:
- It sets text at 10px: use your small step (13px or more) instead.
- It names a kind of typeface: use the brand faces.

## 7. Sections, in order
Each is a composition to rebuild with this project's content. Keep the geometry; change the subject. Re-order or drop a
section when the argument of the page needs it (see references/copy.md), never to fall back to a card grid.

### 1. intro — Title, note, facts row (split)
First row: a heading of two to four words in a light weight at clamp(44px, 5vw, 76px) sits on the left margin in columns 1–6; a three-line paragraph at 16px, 260px wide, sits in columns 10–12 with its last line on the heading's baseline. Columns 7–9 stay empty. 120px lower, a second row sets three or four facts (a date, a time, a place, a price) as large light text at clamp(28px, 3vw, 44px), spread across the 12 columns with `justify-content: space-between`. Each fact has a one-line explanation at 14px directly under it in the soft ink, left-aligned to the fact. Facts are separated only by the space between them, so the row reads like the line of times on a printed programme. A photograph may start under the right half of the facts row, 5 columns wide at 4:3. Padding 140px top, 120px bottom.
On a phone: Heading at 11vw on the left margin; the note follows directly under it at 16px, full width. The facts become a two-column grid with a 32px row gap, each fact at 26px with its explanation beneath. Any photograph goes last, full width.

### 2. how-it-works — Itinerary on a slip (table)
The process is printed as an itinerary or receipt. One paper-coloured slip 420–480px wide stands on a contrasting flat ground at columns 7–11; its bottom edge is a zigzag cut with clip-path and its top edge is straight. The heading, two to four words at clamp(40px, 4.4vw, 68px), sits in columns 1–5 with a 30ch paragraph, top-aligned with the slip. On the slip, in the text face at 16px with tabular figures: stages grouped under time headings that carry the order ('Monday', 'Midweek', 'Friday'), each heading in bold with 28px above it. Under a heading, two to four rows; each row has what happens on the left, a duration or time on the right, and a leader of round 4px dots between. The final row is inverted, paper-coloured text on a full-width ink bar 44px tall, and states the result: what the reader holds at the end and the total time.
On a phone: The heading and paragraph come first. The slip follows at full width minus 16px margins, keeping its zigzag bottom edge. Rows keep left text, dots and right value on one line; long descriptions wrap under the left text. The inverted final row stays full width.

### 3. showcase — Square plate, spare text (split)
One flat field split 50/50, at least 88svh tall. Left half: a single square photograph filling the half's width minus 40px margins, vertically centred, square corners. A large simple shape may be laid over it to turn the photograph into the object it stands for: a ring 86% of its width with a 6px stroke and a small solid dot at the centre makes a record; a notch cut by clip-path makes a ticket stub. Right half, a flex column with space-between: at the top a row of three plain text tabs at 18px (editions, years, variants), the active one in full ink and the others at 40%; in the middle the title, two to four words at 32–40px bold, with a 34ch description 48px below; along the bottom two filled rectangular cells side by side, each half the column wide and 72px tall, acting as the two actions, one in ink and one a tone off the field.
On a phone: The square photograph comes first at full width with 16px margins. The tabs sit under it as one row at 17px. Then the title at 28px, the description, and the two action cells stacked, each full width and 60px tall.

Adjusted for this page:
- It fades text: anything a visitor reads, inactive items of a list included, is `--ink` or `--muted` at full strength (contrast 4.5:1 or more). The active item is told apart by `--ink` against `--muted`, weight or the accent, not by fading the rest.

## 8. Motion — Curtain footer
The page content slides up like a sheet to uncover the footer waiting beneath it, so the last screen is revealed rather than scrolled to. Build with a sticky footer at the bottom and a main element with its own background and a higher stacking order. No JavaScript.
This is the signature move, the one loud moment. Around it the page still needs the rest of the motion layer (SKILL.md step 9): an entrance for the parts of every section, feedback on every control, and one moving picture. The inspector fails a page that barely moves. Recipes: references/motion.md.

## 10. Where the richness comes from
Recognition. The shaped edges, the print-like alignment and the limited inks make a familiar object out of plain HTML.

## 11. How this direction goes wrong
Choose an artefact that truly belongs to the subject, or it becomes costume. Shape the edges with fills and `clip-path`; an outlined rectangle with a thin border is not an object. Keep text sizes readable on a phone, where the object becomes full width with its shaped edge kept at top and bottom.

## 12. Real references
Studied sites that work this way. Take the principle, never the specifics: no names, copy, images or signature assets of theirs.
- **The Deep End** (One Page Love, studied score 7.5) `opl-the-deep-end`
  Idea: The whole site is one invitation card floating over ambient footage, which shrinks into a pinned corner ticket as scattered stills scroll past.
  Hero: Full-bleed, dim, amber-toned video of a listening room: a modular synth and speaker at top, a person lying on a silk cushion in soft focus. Centred over it is a square-cornered panel about 55% of the viewport wide and 62% tall, a blurred brown-to-taupe wash. Inside, the three words of the title are spread along the top edge at left, centre and right in bold condensed caps. A small line-diagram logo sits below. Two left-aligned text blocks at 2.5vw in the same heavy condensed face, tightly leaded: five lines of event details, four of description. Bottom edge: credits left, an RSVP box centre, a small link right. No navigation.
  Worth taking: Spread the words of a short title to the left, centre and right of a card's top edge so the name becomes its frame.
- **ARCHIV** (One Page Love, studied score 7.2) `opl-archiv`
  Idea: A waitlist page as a museum plinth: one cut-out everyday object at a time, centred on off-white beneath a heavy serif wordmark.
  Hero: Off-white single screen with no scroll. A heavy high-contrast serif wordmark in black caps sits top-left at a 56px margin, about 410px wide (28% of the viewport) and 80px tall. Opposite, top-right at the same margin, one line of 14px sans description aligns with the wordmark's top. Dead centre, one photographed object (a painted wooden pepper mill about 140px wide and 440px tall) stands on a barely visible lighter rounded square with a soft contact shadow; other objects replace it in turn. Below, a centred 11px grey line, then a white rounded email field 236px wide with a circled arrow inside its right end. Roughly 80% is empty.
  Worth taking: Build a pre-launch page from four elements only (wordmark top-left, one-line description top-right, a single centred object, an email field) and leave the rest of the screen empty.
Full notes on any of them: `node draw.mjs --site <id>`.

## Always
Headlines two lines or fewer at every width. No eyebrow labels, no monospace, no 01/02/03, no thin rules, no gradients, no shadows at rest,
no cream-and-terracotta, no violet. The frame: one h1 on the first screen that says what this is, equal outer margins, no
section huddled on one side with the other half empty, no blank stretch over half a screen, a heading on every section.
`inspect.mjs` measures all of it.

Saved to C:/Users/user/Desktop/Project3/internship-management-system/.taste-skill/direction.json · reprint with `node draw.mjs --show`
