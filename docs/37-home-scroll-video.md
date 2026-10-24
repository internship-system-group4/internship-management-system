# Home scroll-expanded video

The main **Bridge the Gap** video retains its existing local MP4 and native controls.
It defaults to muted audio; users can unmute it. There is no new autoplay behavior.

After valid media metadata loads, a native sticky stage reserves a short scroll
interval. Scroll progress expands the video frame from its centered 16:9 presentation
to the viewport, removing its rounded corners. Scrolling upward reverses the same
progress. The expanded inline view uses `object-fit: cover`, which can crop the edges
on tall screens; manually entering native fullscreen uses `contain` instead.

The navbar moves out of the expanded viewing interval and returns afterward. Keyboard
focus or an open navigation menu keeps it accessible. The code does not intercept
wheel/touch scrolling, force browser fullscreen, or change playback/audio choices.

Resize and content-size observers update cached geometry. Passive scroll events queue
a single animation frame; geometry is not remeasured for every scroll event. The
existing campus animation, examples strip, FAQ, and their navigation remain separate.

Reduced motion, unavailable media, and no JavaScript use the original inline video
without an extra sticky runway. The small scroll hint uses English/Arabic resources.

Validated on a disposable IIS host with the actual local MP4: compact/middle/full
viewport bounds, reverse scrolling, playback and controls, default muted audio and
unmuting, navigation focus, English/Arabic, Light/Dark, mobile/desktop, reduced-motion
changes, and no-JavaScript fallback. Source build, script syntax, and translations pass.
