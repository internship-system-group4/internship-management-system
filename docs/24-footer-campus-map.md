# Footer campus map: "From the sky to campus"

The public footer (`Layout/Public.master`) has a compact **University Location** column on the right: a 280 x 180 map beside the
link columns (`grid-template-columns: minmax(0,1fr) 280px`). Below 860px it stacks under the links (full width, max 280px, 180px high).
When it scrolls into view, a real map camera flies from the Amman–Madaba region down to the German Jordanian University main campus,
then shows a "German Jordanian University" marker, **Get directions**, **Google Maps** and **Replay flight**.
A `ResizeObserver` calls `map.resize()` whenever the container changes, so the canvas size and camera aspect stay correct.

## Location (verified)

- gju.edu.jo Contact page: *Main Campus Address: Amman Madaba Street, P.O. Box 35247, Amman 11180*, with an official map pin at **31.776843, 35.802555**.
- OpenStreetMap way 588418001 (`amenity=university`) centres about 120 m from that pin, so the two sources agree.
- The values are in `Common/Constants.cs` (`CampusLatitude`, `CampusLongitude`, `UniversityDirectionsUrl`, `UniversityMapEmbedUrl`).

## Provider: no key, no billing

| Piece | What it is | Licence / cost |
| --- | --- | --- |
| MapLibre GL JS 6.13.0 | WebGL map renderer, vendored in `Assets/js/vendor/maplibre/` | BSD-3, free |
| OpenFreeMap "Liberty" style | Vector tiles from `tiles.openfreemap.org` | Free, no API key, no account |
| Map data | OpenStreetMap | ODbL; attribution shown in the map's (i) control |
| Fallback | Keyless Google Maps embed + directions link | Free, no key |

No credentials are in the frontend because none are needed. The runtime (~1.6 MB) loads only when the footer comes near the viewport.

## What is real and what is presentation

- **Real map features:** the vector tiles, roads, labels, the camera's zoom/pitch/bearing flight, the marker's geographic position, and
  3D building extrusions where OpenStreetMap has building outlines (`building-3d` layer).
- **Not available:** satellite or aerial imagery. OpenFreeMap provides vector map tiles only. Adding imagery would need a provider with an
  API key and possibly billing (for example MapTiler, Mapbox, or Google Maps Platform), and that was deliberately not introduced.
- **Presentation only:** the 4.2 s timing, the ease-in-out curve, the start view, and the marker/label styling.

## Behaviour

- Plays once when at least 45% of the map is visible; scrolling away and back does not replay it.
- Dragging, touching or wheeling the map stops the flight and hands the map over.
- Page scrolling stays natural: Ctrl/Cmd + wheel zooms (or click the map first on desktop), and two fingers pan on touch screens.
- Leaving the viewport or hiding the tab mid-flight lands the camera on the final view.
- `prefers-reduced-motion: reduce` shows the final view at once, with no replay button.
- If WebGL, the runtime, or the tile service is unavailable (or loading takes over 20 s), the Google embed and directions link are shown.
  Without JavaScript the embed shows directly.

## Files

- `Assets/js/public-footer-map.js`, `Assets/css/public-footer.css`, `Layout/Public.master`, `Common/Constants.cs`
- `Assets/js/vendor/maplibre/` (unchanged upstream files and `LICENSE.txt`); `Web.config` maps `.mjs` to `text/javascript`
- Test: `tests/footer-campus-map.browser.js` (run against `tests/Start-LoginTestHost.ps1`, port 57992; needs network access to OpenFreeMap)
