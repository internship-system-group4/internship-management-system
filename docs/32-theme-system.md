# Light / Dark / System theme

UIMS has three colour preferences: **Light**, **Dark** and **System**.

- **Light is the original appearance.** It is the default on a first visit, even when the operating system prefers dark.
- **Dark is a palette designed for UIMS.** It is derived from the GJU navy. It is not an inversion filter.

## How it works

| Piece | Where | What it does |
| --- | --- | --- |
| Init script | inline, first in `<head>` of all five masters | Reads `localStorage['uims-theme']` before any stylesheet loads and sets `<html data-theme data-bs-theme data-theme-preference style="color-scheme">`. A missing or invalid value, or blocked storage, gives Light. |
| `Assets/css/theme.css` | right after `ui-tokens.css` in every master | The Dark palette, Bootstrap 5.3 colour-mode variables, selector styles, the short transition, and the generated long-tail tokens. |
| `Assets/js/theme.js` | before the page scripts in every master | See the list below. |
| `Layout/ThemeSelector.ascx` | public navbar (desktop), public mobile menu, portal header | Plain `type="button"` controls: either a menu button with three `menuitemradio` items, or a labelled `radiogroup`. Hidden without JavaScript. |
| `tools/theme/convert-colors.py` | developer tool | Rewrites hard-coded colours as `var(--token, #original)` and regenerates the dark tokens. Idempotent; `--check` reports without writing. |
| `tools/theme/compare-light.py` | developer tool | Pixel comparison of the Light screenshots before and after the change. |

`theme.js` does the following:
- keeps the preference (`light`, `dark` or `system`) separate from the resolved theme (`light` or `dark`);
- follows `prefers-color-scheme` only while the preference is System;
- syncs other tabs through the `storage` event and handles back/forward cache restores;
- runs the selectors' keyboard behaviour;
- dispatches `uims:themechange`;
- exposes `window.UimsTheme`;
- binds idempotently: each selector is bound once (`data-theme-ready`) and only one controller exists per page.

### Light stays exactly as it was

Every converted colour becomes `var(--token, #original)`. Light never defines the generated `--th-*` tokens, so the original value is what renders.

Colours that already equalled a UIMS token use that token, for example `#fff` → `var(--ui-surface,#fff)` and `#133d61` → `var(--ui-ink,#133d61)`. Those tokens have the same value in Light.

Verified by pixel comparison of 102 screenshots (51 routes at 1440 and 390 px; see Verification below).

### Dark core palette (original Light value → Dark)

| Token | Light (original) | Dark |
| --- | --- | --- |
| `--ui-canvas` (page) | `#f6f8ff` | `#0e1823` |
| `--ui-nav` (sidebar) | `#f5f5f5` | `#111d29` |
| `--ui-surface` (cards) | `#fff` | `#152331` |
| `--ui-surface-raised` (menus, inputs on cards) | `#fff` | `#1b2c3d` |
| `--ui-neutral-soft` | `#f0f3f7` | `#1c2a38` |
| `--ui-ink` (main text) | `#133d61` | `#e6edf5` |
| `--ui-muted` (secondary text) | `#50657a` | `#a7b5c3` |
| `--ui-nav-text` / `--ui-nav-muted` | `#42474b` / `#565f69` | `#cfd8e2` / `#9eadbc` |
| `--ui-border` / `--ui-control-border` | `#e4ebf4` / `#7b8b9e` | `#273848` / `#5d7186` |
| `--ui-primary` (filled actions, white text ≥ 4.5:1) | `#264f73` | `#3b74a6` |
| `--ui-primary-hover` | `#173f62` | `#336897` |
| `--ui-primary-soft` (selected, tints) | `#e5efff` | `#1a344d` |
| `--ui-primary-text` (links, brand text) | = primary | `#93c2ea` |
| `--ui-focus` | `#315e8d` | `#93c2ea` |
| `--ui-accent` | `#c8a349` | `#d7b35c` |
| `--ui-success` / soft / strong | `#206044` / `#edf7f0` / — | `#6fcf9d` / `#12301f` / `#23704b` |
| `--ui-warning` / soft / strong | `#76500b` / `#fff5db` / — | `#e8b860` / `#332810` / `#8a5f12` |
| `--ui-danger` / soft / strong | `#a52c37` / `#fff0f1` / — | `#f2939b` / `#3a1b20` / `#b23c48` |
| `--ui-info` / soft | `#245979` / `#edf5fb` | `#86bfe6` / `#13293b` |
| Footer band | `--brand-dark` (`#173f62`) | `#0f2438` |
| Backdrop, elevation, skeleton | — | `rgb(3 9 15 / 72%)`, deep shadows, `#223345` / `#2c4054` |

**Status tokens.** Dark status colours are light tones for text, icons and chart series. The `*-strong` variants are for filled buttons that carry white text.

**Chart series** keep their hue and get one step lighter, for example blue `#315e8d` → `#6fa3d4` and red `#bc4b55` → `#e57d87`.

**Generated tokens.** The long tail of one-off colours (371 tokens) is derived in OKLCH according to the colour's role:
- **Backgrounds:** light backgrounds become dark surfaces in the same order, neutral greys take the navy hue, and vivid accents keep their identity.
- **Text:** dark text becomes light text, and status and brand text stays saturated.
- **Lines:** light dividers become quiet dark dividers.

The role comes from the CSS property:

| Role | Properties |
| --- | --- |
| Background | `background`, `fill` |
| Text | `color`, `stroke` |
| Line | `border`, `outline` |

Page-level variables are assigned a role by their name: `*-border`, `*-line`, `*-bg`, `*-muted`, `*-text` and `*-color`. Navy and blue variables used as text get the light link blue.

## Coverage

- **All 51 page routes** across the public area and all four roles were captured in both themes at 1440 and 390 px. Paired screenshots are in `tests/artifacts/theme/pairs/`; the full sets are in `light-after/` and `dark/`.
- **Bootstrap components** follow `data-bs-theme`: cards, modals, dropdowns, tables, forms, alerts and close buttons. Utilities that are always light (`.bg-white`, `.bg-light`, `.text-dark`, `.table-light`, `.btn-light` and others) are mapped in Dark.
- **Forms:** placeholders, autofill, and disabled and read-only states are covered.
- **Charts** are native SVG reading CSS variables. On a theme change they recolour in place, with the same nodes and no refetch or re-render; the range and selection state are kept.
- **Footer map:** OpenFreeMap "liberty" in Light and "dark" in Dark. On a theme change the style is swapped with `map.setStyle()`; the camera, marker and flight state are kept. The dark style has no 3D buildings, so Liberty's `building-3d` layer (same source) is added with a dark fill. The Google embed fallback cannot be themed and keeps its normal colours inside the themed frame.
- **Logos** keep their official colours on a white backing in Dark: navbar, sidebar and the footer tile.
- **Photos and video** are never filtered.
- **3D scenes:**
  - *Home:* the miniature's background follows the page ground through `scene.background.set()` and one re-render, with no rebuild; materials and lighting are unchanged.
  - *Login:* the daylight gate scene is kept as an intentional environment, and its form and caption overlays are themed.
  - *Powered by:* the hall is already a dark room; its glass panels, name markers and navbar become dark glass.
- **Transition:** only after a deliberate change. For 180 ms, `background-color`, `color`, `border-color`, `fill`, `stroke` and `outline-color` transition; video, canvas, iframes and images are excluded. The initial load and reduced-motion users get no transition.

### Exceptions and limits

- **IIS error pages** (for example a missing document on `CompletionReport` or `ApplicantDocument`) are served by IIS, not by the masters, and stay Light.
- **The Google Maps embed** (map fallback only) has no dark mode.
- **Login's 3D gate scene** stays in daylight by design.
- **Native file pickers, date pickers and select popups** are drawn by the browser. `color-scheme` is set so they follow the theme where the browser supports it.
- **Partial postbacks:** the project uses none, so there are no UpdatePanels to re-bind; full postbacks re-run the init script and `theme.js`.

## Verification (fixture only; no live Firebase writes)

- **`tests/theme.browser.js`:** 43/43. It covers:
  - the first-visit default;
  - menu and radio keyboard behaviour;
  - no form submissions from the controls;
  - the theme applied before first paint on four routes;
  - reload and navigation;
  - cross-tab sync;
  - System following the OS, while explicit choices hold;
  - invalid and blocked storage;
  - the mobile radio group;
  - no overflow on phones in Dark;
  - a portal full postback;
  - chart recolouring without re-rendering;
  - reduced motion, and no JavaScript.
- **`tools/theme/compare-light.py`** (Light before/after): every difference was located and explained:
  - 10 screenshots are identical;
  - 88 differ only in the new theme button's box;
  - 4 also differ elsewhere for load timing or live data: the footer map's load state (Login, Change Password), the gate image's reveal on About at 390 px, and the coordinator dashboard's "Updated on page load" timestamp.
- **Page suites** re-run with the theme in place: About, footer map, public footer, Contact, Login, Login lifecycle, Powered by and Home.
- **Recordings:** `tests/artifacts/theme/recording/theme-switching-desktop.webm` and `theme-switching-phone.webm`.
