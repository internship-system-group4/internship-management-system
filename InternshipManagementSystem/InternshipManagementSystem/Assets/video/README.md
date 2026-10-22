# Internship process video — missing asset

No actual university internship-process video was supplied or found in the project.
The homepage therefore displays a clearly marked development placeholder, with a
link to the readable internship steps rather than a fake play control.

Add the approved, actual video as `internship-process.mp4`. The homepage detects
the file and renders native HTML5 controls, inline playback and a fallback link.
It does not autoplay. Add matching English captions as
`internship-process.en.vtt`; absent captions produce an explicit development notice.
Use the actual video's transcript/timing, not invented captions. MP4/VTT files are
included by the web project's content globs. Confirm IIS serves VTT as `text/vtt`
when deploying the supplied asset. Keyboard playback, audio and caption timing
cannot be verified until the video and captions exist.
