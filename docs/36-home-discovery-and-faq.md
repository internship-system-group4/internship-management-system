# Home internship examples and closing FAQ

Home intentionally displays six localized, illustrative internship examples. They
are labeled as examples, rather than current vacancies. Cards contain a title,
fictional example team, description, location, and field of study. They have no real
opportunity IDs, seats, deadlines, or application actions.

Every **More details** link and the current-opportunities CTA goes directly to
`Pages/Account/Login.aspx`, without a sample ID or return URL. After authentication,
the normal role portal provides access to actual opportunities. Home does not query
Firebase or depend on the public publication node to show these examples.

With JavaScript and normal motion preferences, the cards repeat in a full-viewport
strip moving physically right to left in both languages. The section has a continuous
full-width background, larger cards, short descriptions, role-specific icons, and
compact location/study metadata. Hover pauses the track and
raises the card; keyboard focus pauses and positions an original card within view.
A pause/resume button provides an explicit motion control. Touching card content
pauses and highlights it. Visual copies are excluded from assistive-technology/tab
navigation; More details remains a normal login link. Offscreen/hidden tabs pause
the animation. Reduced motion and no JavaScript retain the six static originals.

Actual student details and applications retain their server-side role, eligibility,
deadline, and availability checks. The earlier fixed-route login continuation and
public-projection safeguards remain separate from these illustrative Home cards;
no live Firebase records or rules are changed.

The six-question FAQ is the last Home section before the footer. Its centered title,
navy typography, full-width surface, generous spacing, rounded disclosures, and
contact link follow the existing Home composition. The first answer explains the
illustrative cards and the transition to live opportunities after sign-in.

Native `details`/`summary` works without JavaScript. Enhancement adds interruptible
height transitions and a single quiet line reveal on entry. Reduced motion removes
the animations. All new example and FAQ copy uses English/Arabic resources.

Verification uses a disposable IIS host. Checks cover responsive Light/Dark and
English/Arabic rendering, direct login navigation, keyboard/native FAQ interaction,
rapid animation reversal, reduced motion, source build, and resource completeness.
